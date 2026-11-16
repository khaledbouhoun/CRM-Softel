import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/core/network/api_exceptions.dart';
import 'package:softel_crm/features/customers/presentation/controllers/customers_controllers.dart';
import 'package:softel_crm/features/interventions/presentation/controllers/interventions_controllers.dart';
import 'package:softel_crm/features/prospects/data/models/prospect.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_ref.dart';
import 'package:softel_crm/features/scheduling/data/models/appointment.dart';
import 'package:softel_crm/features/scheduling/data/models/calendar_item.dart';
import 'package:softel_crm/features/scheduling/presentation/controllers/appointment_action_controller.dart';
import 'package:softel_crm/features/scheduling/presentation/controllers/calendar_controller.dart';
import 'package:softel_crm/features/scheduling/presentation/controllers/schedule_session_controller.dart';
import 'package:softel_crm/features/scheduling/presentation/controllers/scheduling_lists_controllers.dart';

import '../helpers/fixtures.dart';
import '../helpers/mock_http_adapter.dart';
import '../helpers/test_env.dart';
import '../helpers/workflow_fixtures.dart';

void main() {
  late TestEnv base;
  late WorkflowTestEnv env;

  setUp(() {
    Get.testMode = true;
    base = TestEnv();
    env = WorkflowTestEnv(base)..stubLookups();
  });

  tearDown(Get.reset);

  MockHttpAdapter adapter() => base.adapter;

  group('ConvertProspectController', () {
    Prospect prospect() => Prospect.fromJson(prospectJson());

    test(
      'preselects the interested products and sends the chosen ones',
      () async {
        adapter().reply(
          'POST',
          '/prospects/42/convert',
          wrap(prospectJson()..['is_customer'] = true),
        );
        final c = Get.put(
          ConvertProspectController(
            repository: env.customers,
            prospect: prospect(),
          ),
        );
        expect(c.selectedProductIds, {1});
        c.toggleProduct(2, true);
        c.toggleProduct(1, false);
        c.note.text = ' Contrat signé ';
        final converted = await c.submit();
        expect(converted!.isCustomer, isTrue);
        final sent = adapter().lastTo('POST', '/prospects/42/convert').json;
        expect(sent['product_ids'], [2]);
        expect(sent['note'], 'Contrat signé');
        expect(c.errorMessage.value, isNull);
      },
    );

    test(
      'ALREADY_CUSTOMER is reported and blocks a second conversion',
      () async {
        adapter().reply(
          'POST',
          '/prospects/42/convert',
          errorBody('This prospect is already a customer.', 'ALREADY_CUSTOMER'),
          status: 409,
        );
        final c = Get.put(
          ConvertProspectController(
            repository: env.customers,
            prospect: prospect(),
          ),
        );
        expect(await c.submit(), isNull);
        expect(c.alreadyCustomer.value, isTrue);
        expect(c.errorMessage.value, isNotNull);
        expect(c.isSubmitting.value, isFalse);
      },
    );

    test('a double tap sends one request', () async {
      adapter().reply('POST', '/prospects/42/convert', wrap(prospectJson()));
      final c = Get.put(
        ConvertProspectController(
          repository: env.customers,
          prospect: prospect(),
        ),
      );
      final first = c.submit();
      final second = await c.submit();
      await first;
      expect(second, isNull);
      expect(
        adapter().requestsTo('POST', '/prospects/42/convert'),
        hasLength(1),
      );
    });
  });

  group('AppointmentActionController', () {
    Appointment held() => Appointment.fromJson(appointmentJson());

    AppointmentActionController build(
      AppointmentActionKind kind, [
      Appointment? a,
    ]) => Get.put(
      AppointmentActionController(
        repository: env.scheduling,
        kind: kind,
        appointment: a ?? held(),
        clock: () => DateTime(2026, 11, 1, 9),
      ),
      tag: '${kind.name}-${DateTime.now().microsecondsSinceEpoch}',
    );

    test('confirming a hold sends the meeting link and employee', () async {
      adapter().reply(
        'POST',
        '/appointments/7/confirm',
        wrap(
          appointmentJson(
            status: 'confirmed',
            meetingUrl: 'https://meet.example/x',
          ),
        ),
      );
      final c = build(AppointmentActionKind.confirm);
      c.meetingUrl.text = 'https://meet.example/x';
      c.employee.value = 'salim';
      final done = await c.submit();
      expect(done!.status, AppointmentStatus.confirmed);
      final sent = adapter().lastTo('POST', '/appointments/7/confirm').json;
      expect(sent['meeting_url'], 'https://meet.example/x');
      expect(sent['assigned_employee'], 'salim');
    });

    test('an invalid meeting link is refused before any request', () async {
      final c = build(AppointmentActionKind.confirm);
      c.meetingUrl.text = 'not a url';
      expect(await c.submit(), isNull);
      expect(adapter().requests, isEmpty);
      expect(c.errorMessage.value, isNotNull);
    });

    test(
      '410 HOLD_EXPIRED marks the hold as expired and saves nothing',
      () async {
        adapter().reply(
          'POST',
          '/appointments/7/confirm',
          errorBody(
            'The hold on this time has expired and the slot was released.',
            'HOLD_EXPIRED',
          ),
          status: 410,
        );
        final c = build(AppointmentActionKind.confirm);
        expect(await c.submit(), isNull);
        expect(c.holdExpired.value, isTrue);
        expect(c.errorMessage.value, isNotNull);
        expect(c.isSubmitting.value, isFalse);
      },
    );

    test('rejecting sends the customer-visible reason', () async {
      adapter().reply(
        'POST',
        '/appointments/7/reject',
        wrap(appointmentJson(status: 'rejected')),
      );
      final c = build(AppointmentActionKind.reject);
      c.text.text = 'Aucun formateur disponible';
      final done = await c.submit();
      expect(done!.status, AppointmentStatus.rejected);
      expect(
        adapter().lastTo('POST', '/appointments/7/reject').json['reason'],
        'Aucun formateur disponible',
      );
    });

    test('proposing another time needs a future start', () async {
      final c = build(AppointmentActionKind.propose);
      expect(c.startsAt.value, isNull);
      expect(await c.submit(), isNull);
      c.startsAt.value = DateTime(2026, 10, 1, 9); // before the clock
      expect(await c.submit(), isNull);
      expect(adapter().requests, isEmpty);
      adapter().reply(
        'POST',
        '/appointments/7/propose',
        wrap(appointmentJson(status: 'proposed')),
      );
      c.startsAt.value = DateTime(2026, 11, 5, 9);
      expect((await c.submit())!.status, AppointmentStatus.proposed);
    });

    test('recording an outcome requires text and records it once', () async {
      final a = Appointment.fromJson(
        appointmentJson(
          status: 'confirmed',
          startsAt: '2026-10-30T10:00:00+01:00',
          endsAt: '2026-10-30T11:00:00+01:00',
        ),
      );
      final c = build(AppointmentActionKind.complete, a);
      expect(await c.submit(), isNull);
      expect(adapter().requests, isEmpty);
      adapter().reply(
        'POST',
        '/appointments/7/complete',
        wrap(appointmentJson(status: 'completed', activityId: 55)),
      );
      c.text.text = 'Démo réussie';
      expect((await c.submit())!.activityId, 55);
      expect(
        adapter().lastTo('POST', '/appointments/7/complete').json['outcome'],
        'Démo réussie',
      );
    });

    test(
      'a reschedule conflict keeps the dialog open with the explanation',
      () async {
        adapter().reply(
          'POST',
          '/appointments/7/reschedule',
          errorBody(
            'conflict',
            'APPOINTMENT_CONFLICT',
            errors: {
              'conflicts': [
                {
                  'occurrence': 1,
                  'starts_at': '2026-11-05T09:00:00+01:00',
                  'reason': 'customer_busy',
                },
              ],
            },
          ),
          status: 409,
        );
        final a = Appointment.fromJson(
          appointmentJson(status: 'confirmed', group: 'training'),
        );
        final c = build(AppointmentActionKind.reschedule, a);
        c.setStart(DateTime(2026, 11, 5, 9));
        expect(
          c.endsAt.value,
          DateTime(2026, 11, 5, 10),
          reason: 'duration is kept',
        );
        expect(await c.submit(), isNull);
        expect(c.conflicts.single.reason, 'customer_busy');
        expect(c.holdExpired.value, isFalse);
      },
    );
  });

  group('ScheduleSessionController', () {
    Future<ScheduleSessionController> build(SessionMode mode) async {
      await env.workflow.refresh();
      return Get.put(
        ScheduleSessionController(
          repository: env.scheduling,
          workflow: env.workflow,
          mode: mode,
          customer: const ProspectRef(id: 42, companyName: 'SARL Exemple'),
          clock: () => DateTime(2026, 11, 1, 9),
        ),
        tag: 'session-${mode.name}',
      );
    }

    test('accompaniment defaults come from the scheduling settings', () async {
      final c = await build(SessionMode.accompaniment);
      expect(c.occurrences.text, '4');
      expect(c.interval.text, '7');
      expect(c.type.value!.isAccompaniment, isTrue);
      // The end follows the type's configured duration (60 min).
      expect(c.endTime.value, const TimeOfDay(hour: 10, minute: 0));
      expect(c.plannedStarts, hasLength(4));
      expect(c.plannedStarts[1].difference(c.plannedStarts[0]).inDays, 7);
    });

    test('training offers only training types and no series fields', () async {
      final c = await build(SessionMode.training);
      expect(c.types.map((t) => t.code), ['training']);
      expect(c.endTime.value, const TimeOfDay(hour: 10, minute: 30));
      expect(c.buildPayload().occurrences, isNull);
    });

    test('a 409 lists every clashing occurrence and creates nothing', () async {
      adapter().reply(
        'POST',
        '/appointments',
        errorBody(
          'conflict',
          'APPOINTMENT_CONFLICT',
          errors: {
            'conflicts': [
              {
                'occurrence': 2,
                'starts_at': '2026-11-10T09:00:00+01:00',
                'reason': 'holiday',
              },
              {
                'occurrence': 4,
                'starts_at': '2026-11-24T09:00:00+01:00',
                'reason': 'employee_busy',
                'conflicting_appointment_id': 9,
              },
            ],
          },
        ),
        status: 409,
      );
      final c = await build(SessionMode.accompaniment);
      expect(await c.submit(), isNull);
      expect(c.conflicts.map((e) => e.occurrence), [2, 4]);
      expect(c.errorMessage.value, isNotNull);
      // One atomic request: no per-session retries.
      expect(adapter().requestsTo('POST', '/appointments'), hasLength(1));
      expect(adapter().lastTo('POST', '/appointments').json['occurrences'], 4);
    });

    test('a valid series is sent in one request', () async {
      adapter().reply(
        'POST',
        '/appointments',
        wrap({
          'series_id': 3,
          'appointments': [
            appointmentJson(
              id: 1,
              group: 'accompaniment',
              status: 'confirmed',
              seriesId: 3,
            ),
          ],
        }),
        status: 201,
      );
      final c = await build(SessionMode.accompaniment);
      c.occurrences.text = '6';
      c.sendWhatsapp.value = true;
      final result = await c.submit();
      expect(result!.seriesId, 3);
      final sent = adapter().lastTo('POST', '/appointments').json;
      expect(sent['occurrences'], 6);
      expect(sent['send_whatsapp'], true);
      expect(sent['prospect_id'], 42);
    });

    test(
      'missing customer, bad series size or past date never reach the server',
      () async {
        final c = await build(SessionMode.accompaniment);
        c.customer.value = null;
        expect(await c.submit(), isNull);
        c.customer.value = const ProspectRef(id: 42, companyName: 'X');
        c.occurrences.text = '0';
        expect(await c.submit(), isNull);
        c.occurrences.text = '3';
        c.date.value = DateTime(2026, 10, 1);
        expect(await c.submit(), isNull);
        expect(
          adapter().requests.where((r) => r.path == '/appointments'),
          isEmpty,
        );
      },
    );
  });

  group('InterventionDetailController', () {
    Future<InterventionDetailController> build() async {
      await env.workflow.refresh();
      adapter()
        ..reply('GET', '/interventions/5', wrap(interventionJson()))
        ..reply(
          'GET',
          '/interventions/5/transitions',
          wrap([
            {'status_id': 2, 'customer_allowed': false},
          ]),
        );
      final c = Get.put(
        InterventionDetailController(
          interventionId: 5,
          repository: env.interventions,
          workflow: env.workflow,
        ),
      );
      await c.load();
      return c;
    }

    test('the status picker only offers the configured transitions', () async {
      final c = await build();
      expect(c.allowedStatuses.map((s) => s.code), ['in_progress']);
      expect(c.canTransitionTo(2), isTrue);
      expect(c.canTransitionTo(3), isFalse);
    });

    test(
      'a status outside the transitions is refused without calling the API',
      () async {
        final c = await build();
        final result = await c.changeStatus(3);
        expect(result.isSuccess, isFalse);
        expect(result.error, isA<ValidationException>());
        expect(
          adapter().requestsTo('POST', '/interventions/5/transition'),
          isEmpty,
        );
      },
    );

    test(
      'an allowed change is sent with the customer-visible explanation',
      () async {
        final c = await build();
        adapter().reply(
          'POST',
          '/interventions/5/transition',
          wrap(interventionJson(status: WorkflowTestEnv.progressStatus)),
        );
        adapter().reply(
          'GET',
          '/interventions/5/transitions',
          wrap([
            {'status_id': 3, 'customer_allowed': false},
          ]),
        );
        final result = await c.changeStatus(
          2,
          customerMessage: 'Nous traitons votre demande',
        );
        expect(result.isSuccess, isTrue);
        expect(c.intervention.value!.status!.code, 'in_progress');
        expect(c.allowedStatuses.map((s) => s.code), [
          'resolved',
        ], reason: 'transitions are reloaded');
        expect(
          adapter()
              .lastTo('POST', '/interventions/5/transition')
              .json['customer_message'],
          'Nous traitons votre demande',
        );
      },
    );

    test(
      'the server refusing a transition leaves the status unchanged',
      () async {
        final c = await build();
        adapter().reply(
          'POST',
          '/interventions/5/transition',
          errorBody(
            'This status change is not allowed.',
            'INVALID_STATUS_TRANSITION',
          ),
          status: 422,
        );
        final result = await c.changeStatus(2);
        expect(result.isSuccess, isFalse);
        expect(c.intervention.value!.status!.code, 'new');
        expect(c.isBusy.value, isFalse);
      },
    );

    test(
      'notes are internal by default; customer replies are explicit',
      () async {
        final c = await build();
        adapter().reply(
          'POST',
          '/interventions/5/messages',
          wrap(interventionJson()),
          status: 201,
        );
        expect(c.customerVisible.value, isFalse);
        c.message.text = 'Voir le journal serveur';
        await c.sendMessage();
        expect(
          adapter()
              .lastTo('POST', '/interventions/5/messages')
              .json['visibility'],
          'internal',
        );
        expect(
          c.message.text,
          isEmpty,
          reason: 'composer is cleared after saving',
        );
        c.customerVisible.value = true;
        c.message.text = 'Pouvez-vous réessayer ?';
        await c.sendMessage();
        expect(
          adapter()
              .lastTo('POST', '/interventions/5/messages')
              .json['visibility'],
          'customer',
        );
      },
    );

    test('an empty message or empty release note is not sent', () async {
      final c = await build();
      c.message.text = '   ';
      expect((await c.sendMessage()).isSuccess, isFalse);
      expect((await c.publish(' ')).isSuccess, isFalse);
      expect(
        adapter().requestsTo('POST', '/interventions/5/messages'),
        isEmpty,
      );
      expect(adapter().requestsTo('POST', '/interventions/5/publish'), isEmpty);
    });

    test(
      'the list sorts by configured priority order, unprioritised last',
      () async {
        await env.workflow.refresh();
        adapter().reply(
          'GET',
          '/interventions',
          paginated([
            interventionJson(id: 1),
            interventionJson(id: 2, priority: priorityJson(2, 'Normale', 5)),
            interventionJson(id: 3, priority: priorityJson(1, 'Urgent', 1)),
            interventionJson(id: 4, priority: priorityJson(1, 'Urgent', 1)),
          ]),
        );
        final c = Get.put(
          InterventionsController(
            repository: env.interventions,
            workflow: env.workflow,
          ),
        );
        await c.load();
        expect(c.sorted.map((i) => i.id), [4, 3, 2, 1]);
        expect(adapter().lastTo('GET', '/interventions').query['open'], '1');
      },
    );
  });

  group('CalendarController', () {
    Future<CalendarController> build() async {
      final c = Get.put(
        CalendarController(
          repository: env.scheduling,
          activities: base.activities,
          clock: () => DateTime(2026, 11, 15, 10),
          weekStartsOn: DateTime.monday,
        ),
      );
      await settle(); // let the initial load triggered by onInit finish
      return c;
    }

    void stub({
      List<Map<String, dynamic>> items = const [],
      bool activitiesFail = false,
    }) {
      adapter().reply('GET', '/calendar', wrap(items));
      if (activitiesFail) {
        adapter().reply(
          'GET',
          '/activities',
          errorBody('boom', 'SERVER_ERROR'),
          status: 500,
        );
      } else {
        adapter().reply('GET', '/activities', paginated([activityJson(id: 3)]));
      }
    }

    test('month view spans six whole weeks around the anchor', () async {
      stub();
      final c = await build();
      await c.load();
      final (from, to) = c.range;
      expect(from, DateTime(2026, 10, 26)); // Monday before 1 Nov 2026
      expect(to.difference(from).inDays, 41);
      expect(c.days, hasLength(42));
      expect(adapter().lastTo('GET', '/calendar').query['from'], '2026-10-26');
    });

    test('week and day navigation move the range and reload', () async {
      stub();
      final c = await build();
      await c.setView(CalendarView.week);
      expect(c.range.$1, DateTime(2026, 11, 9));
      await c.next();
      expect(c.range.$1, DateTime(2026, 11, 16));
      await c.setView(CalendarView.day);
      await c.previous();
      expect(c.anchor.value, DateTime(2026, 11, 21));
      expect(
        adapter().requestsTo('GET', '/calendar').length,
        greaterThanOrEqualTo(4),
      );
    });

    test(
      'completed activities are merged in and flagged as completed',
      () async {
        stub(
          items: [
            {
              'kind': 'appointment',
              'id': 7,
              'title': 'Formation',
              'starts_at': '2026-11-10T10:00:00+01:00',
              'ends_at': '2026-11-10T11:00:00+01:00',
              'status': 'confirmed',
              'color': '#10B981',
              'conflicts': <Object>[],
            },
          ],
        );
        final c = await build();
        await c.load();
        final planned = c.items.where(
          (i) => i.kind == CalendarKind.appointment,
        );
        final done = c.items.where((i) => i.kind == CalendarKind.activity);
        expect(planned.single.isCompleted, isFalse);
        expect(done.single.isCompleted, isTrue);
      },
    );

    test('a failing activities overlay keeps the plans visible', () async {
      stub(
        items: [
          {
            'kind': 'appointment',
            'id': 7,
            'title': 'Formation',
            'starts_at': '2026-11-10T10:00:00+01:00',
            'ends_at': '2026-11-10T11:00:00+01:00',
            'status': 'confirmed',
            'conflicts': <Object>[],
          },
        ],
        activitiesFail: true,
      );
      final c = await build();
      await c.load();
      expect(c.items, hasLength(1));
      expect(c.activitiesError.value, isNotNull);
      expect(c.state.hasError, isFalse);
    });

    test('server errors show an error state', () async {
      adapter().fail('GET', '/calendar', DioExceptionType.connectionError);
      final c = await build();
      await c.load();
      expect(c.state.hasError, isTrue);
      expect(c.state.isConnectionError, isTrue);
    });

    test('filters are sent to the server; activities are skipped for employee filters', () async {
      stub();
      final c = await build();
      final before = adapter().requestsTo('GET', '/activities').length;
      await c.setFilter(
        const CalendarFilter(employee: 'salim', productId: 1, type: 'training'),
      );
      final q = adapter().lastTo('GET', '/calendar').query;
      expect(q['employee'], 'salim');
      expect(q['product_id'], '1');
      expect(q['type'], 'training');
      expect(adapter().requestsTo('GET', '/activities').length, before);
    });
  });

  group('PendingRequestsController', () {
    test(
      'holds and proposals are listed with the soonest expiry first',
      () async {
        adapter()
          ..on('GET', '/appointments', (r) {
            final status = r.query['status'];
            return MockResponse(
              200,
              paginated(
                status == 'held'
                    ? [
                        appointmentJson(
                          id: 1,
                          holdExpiresAt: '2026-11-04T10:00:00+01:00',
                        ),
                        appointmentJson(
                          id: 2,
                          holdExpiresAt: '2026-11-02T10:00:00+01:00',
                        ),
                      ]
                    : [
                        appointmentJson(
                          id: 3,
                          status: 'proposed',
                          holdExpiresAt: '2026-11-03T10:00:00+01:00',
                        ),
                      ],
              ),
            );
          })
          ..reply(
            'GET',
            '/portal-requests',
            paginated(<Map<String, dynamic>>[]),
          );
        final c = Get.put(
          PendingRequestsController(repository: env.scheduling),
        );
        await c.loadAll();
        expect(c.holds.map((a) => a.id), [2, 3, 1]);
        expect(c.holds[1].status, AppointmentStatus.proposed);
      },
    );

    test('closing a request refreshes the list once', () async {
      adapter()
        ..reply('GET', '/appointments', paginated(<Map<String, dynamic>>[]))
        ..reply(
          'GET',
          '/portal-requests',
          paginated([
            {
              'id': 4,
              'type': 'quotation',
              'status': 'pending',
              'company': 'ACME',
              'contact_name': 'Nadia',
            },
          ]),
        )
        ..reply(
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
      final c = Get.put(PendingRequestsController(repository: env.scheduling));
      await settle();
      final before = adapter().requestsTo('GET', '/portal-requests').length;
      final result = await c.updateRequest(
        c.requests.value.items.single,
        'handled',
      );
      expect(result.isSuccess, isTrue);
      expect(
        adapter().requestsTo('GET', '/portal-requests'),
        hasLength(before + 1),
      );
    });
  });

  group('TrainingController', () {
    test(
      'cancelling the remaining series targets this session onwards',
      () async {
        adapter()
          ..reply(
            'GET',
            '/appointments',
            paginated([
              appointmentJson(
                id: 11,
                status: 'confirmed',
                group: 'accompaniment',
                seriesId: 3,
              ),
            ]),
          )
          ..reply(
            'POST',
            '/appointment-series/3/cancel',
            wrap({'cancelled': 2}),
          );
        final c = Get.put(
          TrainingController(
            repository: env.scheduling,
            clock: () => DateTime(2026, 11, 1),
          ),
        );
        await settle();
        final session = c.sessions.first;
        final before = adapter().requestsTo('GET', '/appointments').length;
        final result = await c.cancelRemainingSeries(session);
        expect(result.value, 2);
        expect(
          adapter()
              .lastTo('POST', '/appointment-series/3/cancel')
              .query['from_appointment_id'],
          '11',
        );
        // Reloaded afterwards (training + accompaniment).
        expect(adapter().requestsTo('GET', '/appointments').length, before + 2);
      },
    );

    test('cancelling one session leaves the series alone', () async {
      adapter()
        ..reply(
          'GET',
          '/appointments',
          paginated([
            appointmentJson(
              id: 11,
              status: 'confirmed',
              group: 'training',
              seriesId: 3,
            ),
          ]),
        )
        ..reply(
          'POST',
          '/appointments/11/cancel',
          wrap(appointmentJson(id: 11, status: 'cancelled')),
        );
      final c = Get.put(TrainingController(repository: env.scheduling));
      await settle();
      final r = await c.cancelSession(c.sessions.first);
      expect(r.isSuccess, isTrue);
      expect(
        adapter().requestsTo('POST', '/appointment-series/3/cancel'),
        isEmpty,
      );
    });
  });
}
