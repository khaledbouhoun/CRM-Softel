import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/core/network/api_client.dart';
import 'package:softel_crm/core/network/api_exceptions.dart';
import 'package:softel_crm/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:softel_crm/features/customers/data/models/customer_models.dart';
import 'package:softel_crm/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:softel_crm/features/interventions/data/models/intervention.dart';
import 'package:softel_crm/features/scheduling/data/models/appointment.dart';
import 'package:softel_crm/features/scheduling/data/models/calendar_item.dart';
import 'package:softel_crm/features/workflow_settings/domain/workflow_config_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/mock_http_adapter.dart';
import '../helpers/test_env.dart';
import '../helpers/workflow_fixtures.dart';

void main() {
  late TestEnv base;
  late WorkflowTestEnv env;

  setUp(() {
    base = TestEnv();
    env = WorkflowTestEnv(base);
  });

  group('employee name header', () {
    test('is sent on writes only, never on reads', () async {
      final adapter = MockHttpAdapter()
        ..reply('POST', '/prospects/42/convert', wrap(prospectJson()))
        ..reply('GET', '/customers', paginated([prospectJson()]));
      final api = ApiClient(
        baseUrl: testBaseUrl,
        timeout: const Duration(seconds: 2),
        httpClientAdapter: adapter,
        enableLogging: false,
        employeeName: () => 'salim',
      );
      final repo = CustomersRepositoryImpl(CustomersRemoteDataSource(api));
      await repo.getCustomers();
      await repo.convertProspect(42, const ConvertPayload());
      expect(
        adapter
            .lastTo('GET', '/customers')
            .headers
            .containsKey('X-Employee-Name'),
        isFalse,
      );
      expect(
        adapter
            .lastTo('POST', '/prospects/42/convert')
            .headers['X-Employee-Name'],
        'salim',
      );
    });

    test('a blank name sends no header', () async {
      final adapter = MockHttpAdapter()
        ..reply(
          'POST',
          '/trials/1/revoke',
          wrap({
            'id': 1,
            'product': {'id': 1, 'name': 'X'},
            'state': 'revoked',
          }),
        );
      final api = ApiClient(
        baseUrl: testBaseUrl,
        timeout: const Duration(seconds: 2),
        httpClientAdapter: adapter,
        enableLogging: false,
        employeeName: () => null,
      );
      await CustomersRepositoryImpl(CustomersRemoteDataSource(api))
          .revokeTrial(1);
      expect(
        adapter
            .lastTo('POST', '/trials/1/revoke')
            .headers
            .containsKey('X-Employee-Name'),
        isFalse,
      );
    });
  });

  group('customers', () {
    test(
      'convert posts the purchased products and returns the customer',
      () async {
        base.adapter.reply(
          'POST',
          '/prospects/42/convert',
          wrap(prospectJson()..['is_customer'] = true),
        );
        final customer = await env.customers.convertProspect(
          42,
          const ConvertPayload(productIds: [1, 2], note: 'Signé'),
        );
        expect(customer.isCustomer, isTrue);
        final sent = base.adapter.lastTo('POST', '/prospects/42/convert').json;
        expect(sent['product_ids'], [1, 2]);
        expect(sent['note'], 'Signé');
      },
    );

    test('409 ALREADY_CUSTOMER surfaces as a conflict with its code', () async {
      base.adapter.reply(
        'POST',
        '/prospects/42/convert',
        errorBody('This prospect is already a customer.', 'ALREADY_CUSTOMER'),
        status: 409,
      );
      await expectLater(
        env.customers.convertProspect(42, const ConvertPayload()),
        throwsA(
          isA<ConflictException>().having(
            (e) => e.errorCode,
            'errorCode',
            'ALREADY_CUSTOMER',
          ),
        ),
      );
    });

    test('profile and trials use the documented routes', () async {
      base.adapter
        ..reply(
          'GET',
          '/customers/42',
          wrap({
            'prospect': prospectJson(),
            'products': [
              {'id': 1, 'name': 'GestCom', 'purchased_at': '2026-10-01'},
            ],
            'portal_accounts': <Object>[],
            'trials': <Object>[],
            'appointments': <Object>[],
          }),
        )
        ..reply(
          'POST',
          '/prospects/42/trials',
          wrap({
            'id': 5,
            'product': {'id': 1, 'name': 'GestCom'},
            'state': 'active',
            'url': 'https://trial.example',
          }),
          status: 201,
        );
      final profile = await env.customers.getCustomer(42);
      expect(profile.products.single.name, 'GestCom');
      final trial = await env.customers.activateTrial(
        42,
        TrialPayload(productId: 1, url: ' https://trial.example '),
      );
      expect(trial.isActive, isTrue);
      expect(
        base.adapter.lastTo('POST', '/prospects/42/trials').json['url'],
        'https://trial.example',
      );
    });
  });

  group('appointments', () {
    test('an accompaniment series is created in a single request', () async {
      base.adapter.reply(
        'POST',
        '/appointments',
        wrap({
          'series_id': 3,
          'appointments': [
            appointmentJson(
              id: 1,
              status: 'confirmed',
              group: 'accompaniment',
              seriesId: 3,
            ),
            appointmentJson(
              id: 2,
              status: 'confirmed',
              group: 'accompaniment',
              seriesId: 3,
            ),
          ],
        }),
        status: 201,
      );
      final result = await env.scheduling.schedule(
        SchedulePayload(
          prospectId: 42,
          appointmentTypeId: 2,
          startsAt: DateTime(2026, 11, 3, 9),
          occurrences: 2,
          intervalDays: 7,
        ),
      );
      expect(result.isSeries, isTrue);
      expect(result.appointments, hasLength(2));
      expect(base.adapter.requestsTo('POST', '/appointments'), hasLength(1));
    });

    test('409 APPOINTMENT_CONFLICT exposes the per-occurrence list', () async {
      base.adapter.reply(
        'POST',
        '/appointments',
        errorBody(
          'The schedule conflicts with existing appointments or a holiday. Nothing was saved.',
          'APPOINTMENT_CONFLICT',
          errors: {
            'conflicts': [
              {
                'occurrence': 2,
                'starts_at': '2026-11-10T09:00:00+01:00',
                'reason': 'holiday',
              },
            ],
          },
        ),
        status: 409,
      );
      try {
        await env.scheduling.schedule(
          SchedulePayload(
            prospectId: 42,
            appointmentTypeId: 2,
            startsAt: DateTime(2026, 11, 3, 9),
            occurrences: 4,
          ),
        );
        fail('expected a conflict');
      } on ConflictException catch (e) {
        expect(e.isScheduleConflict, isTrue);
        final conflicts = ScheduleConflict.listFrom(e.details);
        expect(conflicts.single.occurrence, 2);
        expect(conflicts.single.reason, 'holiday');
      }
    });

    test('410 HOLD_EXPIRED becomes a GoneException', () async {
      base.adapter.reply(
        'POST',
        '/appointments/7/confirm',
        errorBody(
          'The hold on this time has expired and the slot was released.',
          'HOLD_EXPIRED',
        ),
        status: 410,
      );
      await expectLater(
        env.scheduling.confirm(7, meetingUrl: 'https://meet.example/x'),
        throwsA(
          isA<GoneException>().having(
            (e) => e.isHoldExpired,
            'isHoldExpired',
            true,
          ),
        ),
      );
    });

    test('confirm, reject and propose send only the provided fields', () async {
      base.adapter
        ..reply(
          'POST',
          '/appointments/7/confirm',
          wrap(appointmentJson(status: 'confirmed')),
        )
        ..reply(
          'POST',
          '/appointments/7/reject',
          wrap(appointmentJson(status: 'rejected')),
        )
        ..reply(
          'POST',
          '/appointments/7/propose',
          wrap(appointmentJson(status: 'proposed')),
        );
      await env.scheduling.confirm(
        7,
        meetingUrl: ' https://meet.example/x ',
        assignedEmployee: '',
      );
      final confirm = base.adapter
          .lastTo('POST', '/appointments/7/confirm')
          .json;
      expect(confirm['meeting_url'], 'https://meet.example/x');
      expect(confirm.containsKey('assigned_employee'), isFalse);
      await env.scheduling.reject(7, reason: 'Créneau indisponible');
      expect(
        base.adapter.lastTo('POST', '/appointments/7/reject').json['reason'],
        'Créneau indisponible',
      );
      await env.scheduling.reject(7);
      expect(
        base.adapter.lastTo('POST', '/appointments/7/reject').json,
        isEmpty,
      );
      await env.scheduling.propose(
        7,
        DateTime(2026, 11, 5, 14),
        message: 'Jeudi ?',
      );
      final propose = base.adapter
          .lastTo('POST', '/appointments/7/propose')
          .json;
      expect(propose['starts_at'], startsWith('2026-11-05T14:00:00'));
      expect(propose['message'], 'Jeudi ?');
    });

    test('complete records the outcome; series cancel targets the remaining sessions', () async {
      base.adapter
        ..reply(
          'POST',
          '/appointments/7/complete',
          wrap(appointmentJson(status: 'completed', activityId: 99)),
        )
        ..reply('POST', '/appointment-series/3/cancel', wrap({'cancelled': 2}));
      final done = await env.scheduling.complete(7, ' Très bien ');
      expect(done.activityId, 99);
      expect(
        base.adapter.lastTo('POST', '/appointments/7/complete').json['outcome'],
        'Très bien',
      );
      final count = await env.scheduling.cancelSeries(3, fromAppointmentId: 11);
      expect(count, 2);
      final req = base.adapter.lastTo('POST', '/appointment-series/3/cancel');
      expect(req.query['from_appointment_id'], '11');
    });

    test('the calendar asks for a range, filters and kinds', () async {
      base.adapter.reply(
        'GET',
        '/calendar',
        wrap([
          {
            'kind': 'appointment',
            'id': 7,
            'title': 'Formation',
            'starts_at': '2026-11-03T10:00:00+01:00',
            'ends_at': '2026-11-03T11:00:00+01:00',
            'status': 'confirmed',
            'color': '#10B981',
            'conflicts': <Object>[],
          },
        ]),
      );
      final items = await env.scheduling.getCalendar(
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 30),
        const CalendarFilter(employee: 'salim', productId: 1),
      );
      expect(items.single.color, '#10B981');
      final q = base.adapter.lastTo('GET', '/calendar').query;
      expect(q['from'], '2026-11-01');
      expect(q['employee'], 'salim');
      expect(q['product_id'], '1');
    });

    test('holds are listed by status', () async {
      base.adapter.reply(
        'GET',
        '/appointments',
        paginated([appointmentJson()]),
      );
      final page = await env.scheduling.getAppointments(
        const AppointmentFilter(status: AppointmentStatus.held),
      );
      expect(page.items.single.status, AppointmentStatus.held);
      expect(
        base.adapter.lastTo('GET', '/appointments').query['status'],
        'held',
      );
    });

    test(
      'website requests are updated with a status and optional message',
      () async {
        base.adapter.reply(
          'PATCH',
          '/portal-requests/4',
          wrap({
            'id': 4,
            'type': 'quotation',
            'status': 'handled',
            'company': 'ACME',
            'contact_name': 'Nadia',
          }),
        );
        final r = await env.scheduling.updatePortalRequest(
          4,
          'handled',
          customerMessage: ' ',
        );
        expect(r.status, 'handled');
        expect(base.adapter.lastTo('PATCH', '/portal-requests/4').json, {
          'status': 'handled',
        });
      },
    );
  });

  group('interventions', () {
    test('messages are sent with an explicit visibility', () async {
      base.adapter.reply(
        'POST',
        '/interventions/5/messages',
        wrap(interventionJson()),
        status: 201,
      );
      await env.interventions.addMessage(
        5,
        customerVisible: false,
        body: ' note ',
      );
      expect(base.adapter.lastTo('POST', '/interventions/5/messages').json, {
        'visibility': 'internal',
        'body': 'note',
      });
      await env.interventions.addMessage(
        5,
        customerVisible: true,
        body: 'Bonjour',
      );
      expect(
        base.adapter
            .lastTo('POST', '/interventions/5/messages')
            .json['visibility'],
        'customer',
      );
    });

    test('transitions, status change, triage update and publish', () async {
      base.adapter
        ..reply(
          'GET',
          '/interventions/5/transitions',
          wrap([
            {'status_id': 2, 'customer_allowed': false},
          ]),
        )
        ..reply('POST', '/interventions/5/transition', wrap(interventionJson()))
        ..reply('PATCH', '/interventions/5', wrap(interventionJson()))
        ..reply(
          'POST',
          '/interventions/5/publish',
          wrap(interventionJson(published: true)),
        )
        ..reply('POST', '/interventions/5/unpublish', wrap(interventionJson()));
      final transitions = await env.interventions.getTransitions(5);
      expect(transitions.single.statusId, 2);
      await env.interventions.transition(5, 2, customerMessage: 'On traite');
      expect(base.adapter.lastTo('POST', '/interventions/5/transition').json, {
        'status_id': 2,
        'customer_message': 'On traite',
      });
      await env.interventions.updateIntervention(
        5,
        priorityId: 1,
        assignedEmployee: 'salim',
      );
      expect(base.adapter.lastTo('PATCH', '/interventions/5').json, {
        'intervention_priority_id': 1,
        'assigned_employee': 'salim',
      });
      await env.interventions.updateIntervention(5, clearPriority: true);
      expect(base.adapter.lastTo('PATCH', '/interventions/5').json, {
        'intervention_priority_id': null,
      });
      final published = await env.interventions.publish(5, 'Corrigé en v2');
      expect(published.isPublished, isTrue);
      await env.interventions.unpublish(5);
    });

    test(
      '422 INVALID_STATUS_TRANSITION is a validation failure with its message',
      () async {
        base.adapter.reply(
          'POST',
          '/interventions/5/transition',
          errorBody(
            'This status change is not allowed.',
            'INVALID_STATUS_TRANSITION',
          ),
          status: 422,
        );
        await expectLater(
          env.interventions.transition(5, 3),
          throwsA(
            isA<ValidationException>()
                .having(
                  (e) => e.message,
                  'message',
                  'This status change is not allowed.',
                )
                .having(
                  (e) => e.errorCode,
                  'errorCode',
                  'INVALID_STATUS_TRANSITION',
                ),
          ),
        );
      },
    );

    test('the list is requested with its filters', () async {
      base.adapter.reply(
        'GET',
        '/interventions',
        paginated([interventionJson()]),
      );
      await env.interventions.getInterventions(
        const InterventionFilter(
          open: true,
          priorityId: 1,
          assignedEmployee: 'salim',
        ),
      );
      final q = base.adapter.lastTo('GET', '/interventions').query;
      expect(q['open'], '1');
      expect(q['priority_id'], '1');
      expect(q['assigned_employee'], 'salim');
    });
  });

  group('configuration', () {
    test(
      'rows are listed, deactivated by DELETE and reactivated by PATCH',
      () async {
        base.adapter
          ..reply(
            'GET',
            '/config/intervention-priorities',
            wrap([priorityJson(1, 'Urgent', 1)]),
          )
          ..reply(
            'DELETE',
            '/config/intervention-priorities/1',
            wrap(priorityJson(1, 'Urgent', 1)..['is_active'] = false),
          )
          ..reply(
            'PATCH',
            '/config/intervention-priorities/1',
            wrap(priorityJson(1, 'Urgent', 1)),
          );
        final rows = await env.config.getRows(
          ConfigEntities.interventionPriorities,
        );
        expect(rows.single.name, 'Urgent');
        final off = await env.config.deactivate(
          ConfigEntities.interventionPriorities,
          1,
        );
        expect(off.isActive, isFalse);
        await env.config.reactivate(ConfigEntities.interventionPriorities, 1);
        expect(
          base.adapter
              .lastTo('PATCH', '/config/intervention-priorities/1')
              .json,
          {'is_active': true},
        );
      },
    );

    test('scheduling settings are read and saved with PUT', () async {
      base.adapter
        ..reply('GET', '/settings/scheduling', wrap(schedulingJson()))
        ..reply(
          'PUT',
          '/settings/scheduling',
          wrap(schedulingJson()..['hold_expiry_minutes'] = 60),
        );
      final s = await env.config.getScheduling();
      final saved = await env.config.updateScheduling(s);
      expect(saved.holdExpiryMinutes, 60);
      expect(
        base.adapter.lastTo('PUT', '/settings/scheduling').json['work_start'],
        '09:00',
      );
    });
  });

  group('employees', () {
    test('lists employees and sends the heartbeat', () async {
      env.stubLookups();
      base.adapter.reply(
        'POST',
        '/system/heartbeat',
        wrap({'status': 'active'}),
      );
      final overview = await env.employees.getEmployees();
      expect(overview.employees.single.username, 'salim');
      await env.employees.sendHeartbeat(
        employeeId: 'salim@PC1',
        username: 'salim',
        deviceName: 'PC1',
      );
      expect(
        base.adapter.lastTo('POST', '/system/heartbeat').json['employee_id'],
        'salim@PC1',
      );
    });

    test('network failure surfaces as a typed exception', () async {
      base.adapter.fail(
        'GET',
        '/system/employees',
        DioExceptionType.connectionError,
      );
      await expectLater(
        env.employees.getEmployees(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
