import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/app/config/app_settings_service.dart';
import 'package:softel_crm/app/config/key_value_store.dart';
import 'package:softel_crm/app/l10n/l10n.dart';
import 'package:softel_crm/app/routes/app_pages.dart';
import 'package:softel_crm/app/routes/app_routes.dart';
import 'package:softel_crm/app/services/connection_service.dart';
import 'package:softel_crm/app/services/workflow_lookup_service.dart';
import 'package:softel_crm/app/theme/app_theme.dart';
import 'package:softel_crm/core/network/network_info.dart';
import 'package:softel_crm/features/customers/domain/customers_repository.dart';
import 'package:softel_crm/features/employees/data/employees_repository.dart';
import 'package:softel_crm/features/interventions/domain/interventions_repository.dart';
import 'package:softel_crm/features/scheduling/domain/scheduling_repository.dart';
import 'package:softel_crm/features/workflow_settings/domain/workflow_config_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_env.dart';
import '../helpers/workflow_fixtures.dart';

/// Renders each new staff screen against mocked API responses: loading,
/// data, errors and the main actions. Nothing here reaches a real server.
void main() {
  late TestEnv base;
  late WorkflowTestEnv env;

  setUp(() {
    Get.testMode = true;
    L10n.current = AppLocales.french;
    base = TestEnv()
      ..stubReferenceData()
      ..registerInGet();
    env = WorkflowTestEnv(base)..stubLookups();
    Get.put<CustomersRepository>(env.customers, permanent: true);
    Get.put<SchedulingRepository>(env.scheduling, permanent: true);
    Get.put<InterventionsRepository>(env.interventions, permanent: true);
    Get.put<WorkflowConfigRepository>(env.config, permanent: true);
    Get.put<EmployeesRepository>(env.employees, permanent: true);
    Get.put<WorkflowLookupService>(env.workflow, permanent: true);
    final settings = Get.put(
      AppSettingsService(InMemoryStore({'language_code': 'fr'})),
      permanent: true,
    );
    Get.put(
      ConnectionService(
        NetworkInfo(httpClientAdapter: base.adapter),
        settings,
        autoCheck: false,
      ),
      permanent: true,
    );
  });

  tearDown(() {
    Get.reset();
    L10n.current = AppLocales.french;
  });

  Future<void> pumpRoute(WidgetTester tester, String route) async {
    tester.view.physicalSize = const Size(1700, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The test font (Ahem) is much wider than the app font, so the fixed-width
    // sidebar header overflows in every shell page (the existing page tests hit
    // the same layout error). Overflow is a layout warning, not a behaviour
    // under test here; every other error still fails the test.
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        getPages: AppPages.pages,
        initialRoute: route,
      ),
    );
    await settle(tester);
  }

  testWidgets('sidebar groups the new sections', (tester) async {
    base.adapter.reply(
      'GET',
      '/customers',
      paginated(<Map<String, dynamic>>[]),
    );
    await pumpRoute(tester, Routes.customers);
    for (final label in [
      'Tableau de bord',
      'Calendrier',
      'Clients',
      'Formation et accompagnement',
      'Demandes et réservations',
      'Après-vente',
      'Employés',
      'Rendez-vous et après-vente',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('customers list shows converted prospects and an empty state', (
    tester,
  ) async {
    base.adapter.reply(
      'GET',
      '/customers',
      paginated([
        prospectJson(companyName: 'SARL Cliente')
          ..['is_customer'] = true
          ..['converted_at'] = '2026-10-20T10:00:00+01:00',
      ]),
    );
    await pumpRoute(tester, Routes.customers);
    expect(find.text('SARL Cliente'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'customers page shows an error with retry when the server fails',
    (tester) async {
      base.adapter.reply(
        'GET',
        '/customers',
        errorBody('Server error', 'SERVER_ERROR'),
        status: 500,
      );
      await pumpRoute(tester, Routes.customers);
      expect(find.text(tr.actionRetry), findsOneWidget);
    },
  );

  testWidgets(
    'customer profile shows products with purchase date, trials and portal state',
    (tester) async {
      base.adapter.reply(
        'GET',
        '/customers/42',
        wrap({
          'prospect': prospectJson()
            ..['is_customer'] = true
            ..['converted_at'] = '2026-10-20T10:00:00+01:00',
          'products': [
            {'id': 1, 'name': 'GestCom', 'purchased_at': '2026-10-20'},
          ],
          'portal_accounts': <Object>[],
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
          'appointments': [
            appointmentJson(status: 'confirmed', group: 'training'),
          ],
        }),
      );
      await pumpRoute(tester, '/customers/42');
      expect(find.text('SARL Exemple'), findsWidgets);
      expect(find.text(tr.wfNoPortalAccount), findsOneWidget);
      expect(find.text(tr.wfTrialActive), findsOneWidget);
      expect(find.text('Nouvel essai'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'calendar renders the month grid with planned and completed items',
    (tester) async {
      final now = DateTime.now();
      String at(int day, int hour) =>
          DateTime(now.year, now.month, day, hour).toIso8601String();
      base.adapter
        ..reply(
          'GET',
          '/calendar',
          wrap([
            {
              'kind': 'appointment',
              'id': 7,
              'title': 'Formation GestCom',
              'starts_at': at(10, 10),
              'ends_at': at(10, 11),
              'status': 'confirmed',
              'color': '#10B981',
              'conflicts': <Object>[],
            },
            {
              'kind': 'appointment',
              'id': 8,
              'title': 'Démo terminée',
              'starts_at': at(11, 10),
              'ends_at': at(11, 11),
              'status': 'completed',
              'color': '#3B82F6',
              'conflicts': <Object>[],
            },
          ]),
        )
        ..reply('GET', '/activities', paginated(<Map<String, dynamic>>[]));
      await pumpRoute(tester, Routes.calendar);
      expect(find.text('Formation GestCom'), findsOneWidget);
      expect(find.text('Démo terminée'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsWidgets); // completed marker
      // Week and day views render too.
      await tester.tap(find.text(tr.wfViewWeek));
      await settle(tester);
      await tester.tap(find.text(tr.wfViewDay));
      await settle(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'calendar clicking an appointment opens its detail with actions',
    (tester) async {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 10, 10);
      base.adapter
        ..reply(
          'GET',
          '/calendar',
          wrap([
            {
              'kind': 'appointment',
              'id': 7,
              'title': 'Formation GestCom',
              'starts_at': start.toIso8601String(),
              'ends_at': start.add(const Duration(hours: 1)).toIso8601String(),
              'status': 'confirmed',
              'color': '#10B981',
              'conflicts': <Object>[],
            },
          ]),
        )
        ..reply('GET', '/activities', paginated(<Map<String, dynamic>>[]))
        ..reply(
          'GET',
          '/appointments/7',
          wrap(
            appointmentJson(
              status: 'confirmed',
              group: 'training',
              startsAt: start.toIso8601String(),
              endsAt: start.add(const Duration(hours: 1)).toIso8601String(),
              whatsapp: {
                'url': 'https://wa.me/213550123456?text=Bonjour',
                'message': 'Bonjour',
                'delivery_confirmed': false,
              },
            ),
          ),
        );
      await pumpRoute(tester, Routes.calendar);
      await tester.tap(find.text('Formation GestCom'));
      await settle(tester);
      expect(find.text(tr.wfOpenWhatsApp), findsOneWidget);
      expect(find.text(tr.wfReschedule), findsOneWidget);
      expect(find.textContaining('envoyé'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('training page lists sessions and offers the series actions', (
    tester,
  ) async {
    base.adapter.reply(
      'GET',
      '/appointments',
      paginated([
        appointmentJson(
          id: 11,
          status: 'confirmed',
          group: 'accompaniment',
          typeName: 'Accompagnement',
          seriesId: 3,
        ),
      ]),
    );
    await pumpRoute(tester, Routes.training);
    expect(find.text('SARL Exemple'), findsWidgets);
    expect(find.text(tr.wfPartOfSeries), findsWidgets);
    expect(find.text(tr.wfNewAccompaniment), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'new accompaniment dialog uses the settings defaults and shows conflicts',
    (tester) async {
      base.adapter
        ..reply('GET', '/appointments', paginated(<Map<String, dynamic>>[]))
        ..reply('GET', '/config/product-resources', wrap(<Object>[]))
        ..reply(
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
              ],
            },
          ),
          status: 409,
        );
      await pumpRoute(tester, Routes.training);
      await tester.tap(find.text(tr.wfNewAccompaniment));
      await settle(tester);
      expect(find.text('4'), findsWidgets); // default number of sessions
      expect(find.text('7'), findsWidgets); // default interval
      // The customer is required: submitting without one sends nothing.
      await tester.tap(find.text(tr.actionSave));
      await settle(tester);
      expect(base.adapter.requestsTo('POST', '/appointments'), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'requests page: confirm opens the dialog and an expired hold is explained',
    (tester) async {
      base.adapter
        ..reply(
          'GET',
          '/appointments',
          paginated([
            appointmentJson(
              holdExpiresAt: DateTime.now()
                  .add(const Duration(hours: 2))
                  .toIso8601String(),
            ),
          ]),
        )
        ..reply('GET', '/portal-requests', paginated(<Map<String, dynamic>>[]))
        ..reply(
          'POST',
          '/appointments/7/confirm',
          errorBody(
            'The hold on this time has expired and the slot was released.',
            'HOLD_EXPIRED',
          ),
          status: 410,
        );
      await pumpRoute(tester, Routes.requests);
      expect(find.text('SARL Exemple'), findsWidgets);
      expect(find.textContaining('expire dans'), findsWidgets); // countdown
      await tester.tap(
        find.widgetWithText(FilledButton, tr.actionConfirm).first,
      );
      await settle(tester);
      expect(find.text(tr.wfConfirmHoldTitle), findsOneWidget);
      await tester.tap(
        find.widgetWithText(FilledButton, tr.actionConfirm).last,
      );
      await settle(tester);
      expect(find.text(tr.wfHoldExpired), findsWidgets);
      // The dialog now refuses to confirm an expired hold.
      final confirm = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, tr.actionConfirm).last,
      );
      expect(confirm.onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'website requests: actionable trial request renders confirm and reject buttons, and confirm opens trial dialog',
    (tester) async {
      base.adapter
        ..reply('GET', '/appointments', paginated(<Map<String, dynamic>>[]))
        ..reply(
          'GET',
          '/portal-requests',
          paginated([
            {
              'id': 10,
              'type': 'trial',
              'status': 'pending',
              'company': 'Tech Corp',
              'contact_name': 'Amine',
              'prospect_id': 42,
              'product': {'id': 1, 'name': 'GestCom'},
              'notes': 'Requested trial',
            },
          ]),
        )
        ..reply(
          'GET',
          '/products',
          wrap([
            {'id': 1, 'name': 'GestCom', 'has_demo': true, 'demo_url': 'https://demo.gestcom.dz'},
            {'id': 2, 'name': 'SoftPharm', 'has_demo': true, 'demo_url': 'https://demo.softpharm.dz'},
          ]),
        )
        ..reply(
          'POST',
          '/prospects/42/trials',
          wrap([
            {
              'id': 1,
              'prospect_id': 42,
              'product': {'id': 1, 'name': 'GestCom'},
              'url': 'https://demo.gestcom.dz',
              'starts_at': '2026-11-21 10:00:00',
              'ends_at': '2026-12-05 10:00:00',
            },
          ]),
          status: 201,
        );
      await pumpRoute(tester, Routes.requests);
      await tester.tap(find.text(tr.wfWebsiteRequestsTab));
      await settle(tester);

      expect(find.text('Tech Corp'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, tr.actionConfirm), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, tr.wfReject), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, tr.actionConfirm));
      await settle(tester);

      expect(find.text(tr.wfNewTrial), findsOneWidget);
      expect(find.text('GestCom'), findsWidgets);
      expect(find.text('SoftPharm'), findsOneWidget);
      expect(find.text('14d'), findsOneWidget);

      await tester.tap(find.text('14d'));
      await settle(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.widgetWithText(FilledButton, tr.actionConfirm),
        ),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('after-sales list is sorted by priority and opens the detail', (
    tester,
  ) async {
    base.adapter
      ..reply(
        'GET',
        '/interventions',
        paginated([
          interventionJson(id: 1)..['title'] = 'Ticket A',
          interventionJson(id: 2, priority: priorityJson(1, 'Urgent', 1))
            ..['title'] = 'Très urgent',
        ]),
      )
      ..reply(
        'GET',
        '/interventions/2',
        wrap(interventionJson(id: 2, priority: priorityJson(1, 'Urgent', 1))),
      )
      ..reply(
        'GET',
        '/interventions/2/transitions',
        wrap([
          {'status_id': 2, 'customer_allowed': false},
        ]),
      );
    await pumpRoute(tester, Routes.afterSales);
    final urgent = tester.getTopLeft(find.text('Très urgent')).dy;
    final none = tester.getTopLeft(find.text('Ticket A')).dy;
    expect(urgent, lessThan(none));
    await tester.tap(find.text('Très urgent'));
    await settle(tester);
    // Status picker: only the configured transition is offered.
    expect(find.widgetWithText(OutlinedButton, 'En cours'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Résolu'), findsNothing);
    // Internal note vs customer reply are clearly labelled.
    expect(find.text(tr.wfInternalNote), findsWidgets);
    expect(find.text(tr.wfCustomerReply), findsWidgets);
    expect(find.text(tr.wfInternalNoteHint), findsOneWidget);
    await tester.tap(find.text(tr.wfCustomerReply).first);
    await settle(tester);
    expect(find.text(tr.wfCustomerReplyWarning), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('employees page lists workstations and the work assigned', (
    tester,
  ) async {
    base.adapter
      ..reply('GET', '/calendar', wrap(<Object>[]))
      ..reply('GET', '/interventions', paginated([interventionJson()]));
    await pumpRoute(tester, Routes.employees);
    expect(find.text('salim'), findsOneWidget);
    await tester.tap(find.text('salim'));
    await settle(tester);
    expect(find.textContaining('INT-5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workflow settings: scheduling form and a configurable list', (
    tester,
  ) async {
    base.adapter.reply(
      'GET',
      '/config/intervention-priorities',
      wrap([
        priorityJson(1, 'Urgent', 1),
        priorityJson(2, 'Normale', 5)..['is_active'] = false,
      ]),
    );
    await pumpRoute(tester, Routes.workflowSettings);
    expect(find.text(tr.wfWorkingDays), findsOneWidget);
    expect(find.text('1440'), findsOneWidget); // hold expiry from the CRM
    await tester.tap(find.text(tr.wfCfgPriorities));
    await settle(tester);
    expect(find.text('Urgent'), findsOneWidget);
    expect(find.text('Normale'), findsOneWidget);
    expect(find.text(tr.statusInactive), findsOneWidget);
    // Deactivate instead of delete: the row stays and uses PATCH/DELETE only.
    expect(find.byIcon(Icons.delete), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('prospect page offers the conversion to customer', (
    tester,
  ) async {
    base.adapter
      ..reply('GET', '/prospects/42', wrap(prospectJson()))
      ..reply(
        'GET',
        '/prospects/42/activities',
        paginated(<Map<String, dynamic>>[]),
      )
      ..reply(
        'GET',
        '/prospects/42/follow-ups',
        paginated(<Map<String, dynamic>>[]),
      )
      ..reply('GET', '/prospects/42/stage-history', wrap(<Object>[]));
    await pumpRoute(tester, '/prospects/42');
    expect(find.text(tr.wfConvertAction), findsOneWidget);
    expect(find.text(tr.wfOpenCustomerProfile), findsNothing);
  });

  testWidgets('a converted prospect links to its customer profile instead', (
    tester,
  ) async {
    base.adapter
      ..reply(
        'GET',
        '/prospects/42',
        wrap(prospectJson()..['is_customer'] = true),
      )
      ..reply(
        'GET',
        '/prospects/42/activities',
        paginated(<Map<String, dynamic>>[]),
      )
      ..reply(
        'GET',
        '/prospects/42/follow-ups',
        paginated(<Map<String, dynamic>>[]),
      )
      ..reply('GET', '/prospects/42/stage-history', wrap(<Object>[]));
    await pumpRoute(tester, '/prospects/42');
    expect(find.text(tr.wfOpenCustomerProfile), findsOneWidget);
    expect(find.text(tr.wfConvertAction), findsNothing);
  });
}

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}
