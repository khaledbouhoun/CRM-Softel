import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/core/network/api_exceptions.dart';
import 'package:softel_crm/features/customers/data/models/customer_models.dart';
import 'package:softel_crm/features/employees/data/models/employee_session.dart';
import 'package:softel_crm/features/interventions/data/models/intervention.dart';
import 'package:softel_crm/features/prospects/data/models/prospect.dart';
import 'package:softel_crm/features/scheduling/data/models/appointment.dart';
import 'package:softel_crm/features/scheduling/data/models/calendar_item.dart';
import 'package:softel_crm/features/scheduling/data/models/portal_request.dart';
import 'package:softel_crm/features/scheduling/data/models/scheduling_settings.dart';
import 'package:softel_crm/features/workflow_settings/data/models/config_models.dart';

import '../helpers/fixtures.dart';
import '../helpers/workflow_fixtures.dart';

void main() {
  hotfixAttachmentTests();
  group('Appointment', () {
    test('parses a held demo with its hold and contact data', () {
      final a = Appointment.fromJson(appointmentJson());
      expect(a.status, AppointmentStatus.held);
      expect(a.type.isDemo, isTrue);
      expect(a.prospect.name, 'SARL Exemple');
      expect(a.product!.name, 'GestCom');
      expect(a.holdExpiresAt, isNotNull);
      expect(a.isAwaitingDecision, isTrue);
      expect(a.whatsapp, isNull);
    });

    test('tolerates nulls and unknown statuses', () {
      final json = appointmentJson(status: 'something_new')
        ..['product'] = null
        ..['hold_expires_at'] = null
        ..['ends_at'] = null;
      final a = Appointment.fromJson(json);
      expect(a.status, AppointmentStatus.unknown);
      expect(a.product, isNull);
      expect(a.endsAt, isNull);
      expect(a.holdRemaining(), isNull);
      expect(a.displayTitle, 'Démo');
    });

    test('an expired hold is no longer awaiting a decision', () {
      final a = Appointment.fromJson(appointmentJson(holdExpired: true));
      expect(a.isAwaitingDecision, isFalse);
    });

    test('exposes the prefilled WhatsApp link without claiming delivery', () {
      final a = Appointment.fromJson(
        appointmentJson(
          status: 'confirmed',
          group: 'training',
          whatsapp: {
            'url': 'https://wa.me/213550123456?text=Bonjour',
            'message': 'Bonjour',
            'delivery_confirmed': false,
          },
        ),
      );
      expect(a.whatsapp!.url, startsWith('https://wa.me/'));
      expect(a.whatsapp!.deliveryConfirmed, isFalse);
    });

    test('a completed appointment is a record, not a plan', () {
      expect(AppointmentStatus.completed.isDone, isTrue);
      expect(AppointmentStatus.noShow.isDone, isTrue);
      expect(AppointmentStatus.confirmed.isDone, isFalse);
      expect(AppointmentStatus.held.isLive, isTrue);
      expect(AppointmentStatus.expired.isLive, isFalse);
    });

    test('schedule payload sends series parameters only when given', () {
      final single = SchedulePayload(
        prospectId: 42,
        appointmentTypeId: 1,
        startsAt: DateTime(2026, 11, 3, 9),
        assignedEmployee: '  ',
      ).toJson();
      expect(single.containsKey('occurrences'), isFalse);
      expect(single.containsKey('assigned_employee'), isFalse);
      expect(single['starts_at'], startsWith('2026-11-03T09:00:00'));
      final series = SchedulePayload(
        prospectId: 42,
        appointmentTypeId: 2,
        startsAt: DateTime(2026, 11, 3, 9),
        occurrences: 4,
        intervalDays: 7,
      ).toJson();
      expect(series['occurrences'], 4);
      expect(series['interval_days'], 7);
    });
  });

  group('schedule conflicts', () {
    test('parses errors.conflicts of a 409', () {
      final list = ScheduleConflict.listFrom({
        'conflicts': [
          {
            'occurrence': 2,
            'starts_at': '2026-11-10T09:00:00+01:00',
            'reason': 'holiday',
          },
          {
            'occurrence': 3,
            'starts_at': '2026-11-17T09:00:00+01:00',
            'reason': 'employee_busy',
            'conflicting_appointment_id': 9,
          },
        ],
      });
      expect(list, hasLength(2));
      expect(list.first.occurrence, 2);
      expect(list.last.conflictingAppointmentId, 9);
      expect(ScheduleConflict.listFrom(const {}), isEmpty);
    });

    test('ApiException keeps the error code and raw errors', () {
      const e = ConflictException(
        'x',
        statusCode: 409,
        errorCode: 'APPOINTMENT_CONFLICT',
        details: {'conflicts': []},
      );
      expect(e.isScheduleConflict, isTrue);
      const gone = GoneException(
        'x',
        statusCode: 410,
        errorCode: 'HOLD_EXPIRED',
      );
      expect(gone.isHoldExpired, isTrue);
    });

    test('ScheduleResult reads a single session or a series', () {
      final single = ScheduleResult.fromBody(appointmentJson(id: 1));
      expect(single.isSeries, isFalse);
      expect(single.appointments.single.id, 1);
      final series = ScheduleResult.fromBody({
        'series_id': 3,
        'appointments': [appointmentJson(id: 1), appointmentJson(id: 2)],
      });
      expect(series.seriesId, 3);
      expect(series.appointments, hasLength(2));
    });
  });

  group('CalendarItem', () {
    final json = {
      'kind': 'appointment',
      'id': 7,
      'title': 'Formation',
      'starts_at': '2026-11-03T10:00:00+01:00',
      'ends_at': '2026-11-03T11:30:00+01:00',
      'status': 'confirmed',
      'color': '#10B981',
      'type_code': 'training',
      'group': 'training',
      'prospect': {'id': 42, 'name': 'SARL Exemple'},
      'product': null,
      'assigned_employee': 'salim',
      'conflicts': [
        {'appointment_id': 9, 'reason': 'same_employee'},
      ],
    };

    test('parses colors and conflicts from the API', () {
      final item = CalendarItem.fromJson(json);
      expect(item.kind, CalendarKind.appointment);
      expect(item.color, '#10B981');
      expect(item.hasConflict, isTrue);
      expect(item.conflicts.single.appointmentId, 9);
      expect(item.isCompleted, isFalse);
      expect(item.endsAt.isAfter(item.startsAt), isTrue);
    });

    test('completed appointments and activities are history', () {
      expect(
        CalendarItem.fromJson({...json, 'status': 'completed'}).isCompleted,
        isTrue,
      );
      expect(
        CalendarItem.fromJson({...json, 'kind': 'follow_up'}).isCompleted,
        isFalse,
      );
    });

    test('missing end and optional fields do not break parsing', () {
      final item = CalendarItem.fromJson({
        'kind': 'follow_up',
        'id': 1,
        'title': 'Rappeler',
        'starts_at': '2026-11-03T10:00:00+01:00',
        'status': 'pending',
      });
      expect(item.endsAt, item.startsAt);
      expect(item.prospect, isNull);
      expect(item.conflicts, isEmpty);
    });

    test('the filter asks the server for the selected kinds only', () {
      final query = const CalendarFilter(
        employee: 'salim',
        kinds: [CalendarKind.appointment, CalendarKind.activity],
      ).toQuery(DateTime(2026, 11, 1), DateTime(2026, 11, 30));
      expect(query['employee'], 'salim');
      expect(query['kinds[]'], ['appointment']);
      expect(query['from'], '2026-11-01');
    });
  });

  group('settings and requests', () {
    test('SchedulingSettings round-trips', () {
      final s = SchedulingSettings.fromJson(schedulingJson());
      expect(s.workingDays, [0, 1, 2, 3, 4]);
      expect(s.holdExpiryMinutes, 1440);
      expect(SchedulingSettings.fromJson(s.toJson()).toJson(), s.toJson());
    });

    test('SchedulingSettings falls back on empty data', () {
      final s = SchedulingSettings.fromJson(const {});
      expect(s.workingDays, isEmpty);
      expect(s.whatsappCountryCode, '');
    });

    test('PortalRequest: only quotation and trial requests are actionable', () {
      PortalRequest make(String type, String status) => PortalRequest.fromJson({
        'id': 1,
        'type': type,
        'status': status,
        'company': 'ACME',
        'contact_name': 'Nadia',
        'product': null,
        'phone': null,
      });
      expect(make('quotation', 'pending').isActionable, isTrue);
      expect(make('demo', 'pending').isActionable, isFalse);
      expect(make('trial', 'handled').isActionable, isFalse);
      expect(make('trial', 'pending').product, isNull);
    });

    test('config models read colors, flags and ids', () {
      final status = InterventionStatus.fromJson(
        statusJson(3, 'resolved', 'Résolu', closed: true, label: 'Terminé'),
      );
      expect(status.isClosed, isTrue);
      expect(status.customerLabel, 'Terminé');
      final type = AppointmentType.fromJson({
        'id': 2,
        'code': 'acc',
        'name': 'Acc',
        'group': 'accompaniment',
      });
      expect(type.isAccompaniment, isTrue);
      expect(type.defaultDurationMinutes, 60);
      final priority = InterventionPriority.fromJson({
        'id': 1,
        'code': 'low',
        'name': 'Basse',
        'response_target_hours': null,
      });
      expect(priority.responseTargetHours, isNull);
      expect(ConfigRow.fromJson({'id': 4, 'title': 'Guide'}).name, 'Guide');
    });
  });

  group('customers', () {
    test('Prospect reads the customer conversion fields (and defaults)', () {
      final plain = Prospect.fromJson(prospectJson());
      expect(plain.isCustomer, isFalse);
      expect(plain.convertedAt, isNull);
      final customer = Prospect.fromJson(
        prospectJson()
          ..['is_customer'] = true
          ..['converted_at'] = '2026-10-20T10:00:00+01:00'
          ..['converted_by'] = 'salim'
          ..['conversion_note'] = 'Signé',
      );
      expect(customer.isCustomer, isTrue);
      expect(customer.convertedBy, 'salim');
      expect(customer.conversionNote, 'Signé');
    });

    test(
      'CustomerProfile parses products with purchase date, accounts and trials',
      () {
        final profile = CustomerProfile.fromJson({
          'prospect': prospectJson()..['is_customer'] = true,
          'products': [
            {'id': 1, 'name': 'GestCom', 'purchased_at': '2026-10-20'},
            {'id': 2, 'name': 'Paie', 'purchased_at': null},
          ],
          'portal_accounts': [
            {
              'id': 3,
              'name': 'Amine',
              'email': 'a@x.dz',
              'is_active': true,
              'last_login_at': null,
            },
          ],
          'trials': [
            {
              'id': 9,
              'product': {'id': 1, 'name': 'GestCom'},
              'state': 'active',
              'url': 'https://trial.example/x',
              'starts_at': '2026-11-01T09:00:00+01:00',
              'ends_at': '2026-11-15T09:00:00+01:00',
            },
          ],
          'appointments': [appointmentJson(status: 'confirmed')],
        });
        expect(profile.products.first.purchasedAt, isNotNull);
        expect(profile.products.last.purchasedAt, isNull);
        expect(profile.hasPortalAccount, isTrue);
        expect(profile.trials.single.isActive, isTrue);
        expect(profile.trials.single.canRevoke, isTrue);
        expect(profile.appointments.single.status, AppointmentStatus.confirmed);
      },
    );

    test('ConvertPayload only carries what was chosen', () {
      expect(const ConvertPayload().toJson(), {'product_ids': <int>[]});
      expect(
        const ConvertPayload(
          productIds: [1, 2],
          note: ' ok ',
          wonStageId: 5,
        ).toJson(),
        {
          'product_ids': [1, 2],
          'note': 'ok',
          'won_stage_id': 5,
        },
      );
    });
  });

  group('interventions', () {
    test('parses status, priority, customers and the two message kinds', () {
      final i = Intervention.fromJson(
        interventionJson(
          priority: priorityJson(1, 'Urgent', 1),
          messages: [
            {
              'id': 1,
              'author_type': 'employee',
              'author_name': 'salim',
              'visibility': 'internal',
              'body': 'Piste base de données',
              'status_id': null,
              'created_at': '2026-11-01T10:00:00+01:00',
            },
            {
              'id': 2,
              'author_type': 'employee',
              'author_name': 'salim',
              'visibility': 'customer',
              'body': 'Nous regardons',
              'status_id': 2,
              'created_at': '2026-11-01T11:00:00+01:00',
            },
          ],
        ),
      );
      expect(i.status!.code, 'new');
      expect(i.priority!.name, 'Urgent');
      expect(i.customers.single.id, 42);
      expect(i.messages.first.isInternal, isTrue);
      expect(i.messages.last.isInternal, isFalse);
      expect(i.isFromCustomer, isTrue);
    });

    test('tolerates a missing priority, status and messages', () {
      final json = interventionJson()
        ..['status'] = null
        ..['messages'] = null
        ..['customers'] = null;
      final i = Intervention.fromJson(json);
      expect(i.status, isNull);
      expect(i.priority, isNull);
      expect(i.messages, isEmpty);
      expect(i.isClosed, isFalse);
    });

    test('filter query only carries chosen fields', () {
      final q = const InterventionFilter(open: true, statusId: 2).toQuery();
      expect(q['open'], true);
      expect(q['status_id'], 2);
      expect(q['priority_id'], isNull);
    });

    test('payload for employee-created work', () {
      final p = InterventionPayload(
        typeId: 2,
        title: ' Correctif ',
        description: 'Détail',
        customerIds: const [42],
        assignedEmployee: ' ',
      ).toJson();
      expect(p['title'], 'Correctif');
      expect(p['customer_ids'], [42]);
      expect(p.containsKey('assigned_employee'), isFalse);
    });
  });

  group('employees', () {
    test('parses sessions and the summary', () {
      final overview = EmployeesOverview.fromJson({
        'summary': {'active_employees': 2},
        'employees': [
          {'employee_id': 'a@PC', 'username': 'a', 'status': 'Online'},
          {'employee_id': 'b@PC', 'username': 'b', 'status': 'Offline'},
        ],
      });
      expect(overview.activeCount, 2);
      expect(overview.employees.first.isOnline, isTrue);
      expect(overview.employees.last.isOnline, isFalse);
      expect(EmployeesOverview.fromJson(const {}).employees, isEmpty);
    });
  });
}

void hotfixAttachmentTests() {
  group('InterventionAttachment hotfix flag', () {
    test('is_hotfix is parsed and defaults to false', () {
      final patch = InterventionAttachment.fromJson({'id': 1, 'name': 'patch.zip', 'is_hotfix': true});
      final plain = InterventionAttachment.fromJson({'id': 2, 'name': 'screen.png'});
      expect(patch.isHotfix, isTrue);
      expect(plain.isHotfix, isFalse);
    });
  });
}
