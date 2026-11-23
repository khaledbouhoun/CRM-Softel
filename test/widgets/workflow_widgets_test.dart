import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/app/l10n/l10n.dart';
import 'package:softel_crm/app/theme/app_theme.dart';
import 'package:softel_crm/core/widgets/workflow_widgets.dart';
import 'package:softel_crm/features/customers/presentation/dialogs/customer_dialogs.dart';
import 'package:softel_crm/features/prospects/data/models/prospect.dart';
import 'package:softel_crm/features/scheduling/data/models/appointment.dart';
import 'package:softel_crm/features/scheduling/data/models/calendar_item.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_env.dart';
import '../helpers/workflow_fixtures.dart';

import 'package:hugeicons/hugeicons.dart';
void main() {
  setUp(() {
    Get.testMode = true;
    L10n.current = AppLocales.french;
  });

  tearDown(() {
    Get.reset();
    L10n.current = AppLocales.french;
  });

  CalendarItem item({
    String status = 'confirmed',
    String kind = 'appointment',
  }) => CalendarItem.fromJson({
    'kind': kind,
    'id': 7,
    'title': 'Formation GestCom',
    'starts_at': '2026-11-03T10:00:00+01:00',
    'ends_at': '2026-11-03T11:30:00+01:00',
    'status': status,
    'color': '#10B981',
    'prospect': {'id': 42, 'name': 'SARL Exemple'},
    'product': {'id': 1, 'name': 'GestCom'},
    'assigned_employee': 'salim',
    'conflicts': <Object>[],
  });

  Widget host(Locale locale, Widget child) => MaterialApp(
    locale: locale,
    theme: AppTheme.light(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocales.supported,
    home: Scaffold(
      body: Center(child: SizedBox(width: 320, child: child)),
    ),
  );

  group('CalendarEventCard', () {
    testWidgets('shows time range, customer, product and status in English', (
      tester,
    ) async {
      L10n.current = AppLocales.english;
      await tester.pumpWidget(
        host(AppLocales.english, CalendarEventCard(item: item())),
      );
      expect(find.text('Formation GestCom'), findsOneWidget);
      expect(find.textContaining('SARL Exemple'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCalendar03), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(CalendarEventCard))),
        TextDirection.ltr,
      );
    });

    testWidgets(
      'lays out right-to-left in Arabic with the accent on the leading side',
      (tester) async {
        L10n.current = AppLocales.arabic;
        await tester.pumpWidget(
          host(AppLocales.arabic, CalendarEventCard(item: item())),
        );
        final context = tester.element(find.byType(CalendarEventCard));
        expect(Directionality.of(context), TextDirection.rtl);
        expect(find.text('مؤكد'), findsOneWidget);
        final card = tester.getRect(find.byType(CalendarEventCard));
        // In RTL the kind icon sits on the right half of the card.
        expect(
          tester.getCenter(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCalendar03)).dx,
          greaterThan(card.center.dx),
        );
      },
    );

    testWidgets('left-to-right puts the same icon on the left half', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(AppLocales.french, CalendarEventCard(item: item())),
      );
      final card = tester.getRect(find.byType(CalendarEventCard));
      expect(
        tester.getCenter(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCalendar03)).dx,
        lessThan(card.center.dx),
      );
    });

    testWidgets(
      'a completed appointment looks different from a scheduled one',
      (tester) async {
        L10n.current = AppLocales.english;
        await tester.pumpWidget(
          host(
            AppLocales.english,
            Column(
              children: [
                CalendarEventCard(item: item()),
                CalendarEventCard(item: item(status: 'completed')),
              ],
            ),
          ),
        );
        // Scheduled: kind icon. Completed: check mark + "Completed" badge.
        expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCheckmarkCircle02), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCalendar03), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('Confirmed'), findsOneWidget);
      },
    );

    testWidgets('a recorded activity is drawn as completed history', (
      tester,
    ) async {
      L10n.current = AppLocales.english;
      final activity = item(kind: 'activity', status: 'recorded');
      expect(activity.isCompleted, isTrue);
      await tester.pumpWidget(
        host(
          AppLocales.english,
          CalendarEventCard(item: activity, compact: true),
        ),
      );
      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCheckmarkCircle02), findsOneWidget);
    });

    testWidgets('flags conflicts with a visible explanation', (tester) async {
      L10n.current = AppLocales.english;
      final clash = CalendarItem.fromJson({
        'kind': 'appointment',
        'id': 8,
        'title': 'Démo',
        'starts_at': '2026-11-03T10:00:00+01:00',
        'ends_at': '2026-11-03T11:00:00+01:00',
        'status': 'confirmed',
        'conflicts': [
          {'appointment_id': 9, 'reason': 'same_employee'},
        ],
      });
      await tester.pumpWidget(
        host(AppLocales.english, CalendarEventCard(item: clash)),
      );
      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedAlert02), findsWidgets);
      expect(find.textContaining('Employee already busy'), findsOneWidget);
    });

    testWidgets('onTap is called', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          AppLocales.french,
          CalendarEventCard(item: item(), onTap: () => taps++),
        ),
      );
      await tester.tap(find.byType(CalendarEventCard));
      expect(taps, 1);
    });
  });

  group('badges', () {
    testWidgets('AppointmentStatusBadge is localized in each language', (
      tester,
    ) async {
      for (final (locale, label) in [
        (AppLocales.english, 'Held'),
        (AppLocales.french, 'En attente'),
        (AppLocales.arabic, 'محجوز مؤقتًا'),
      ]) {
        L10n.current = locale;
        await tester.pumpWidget(
          host(
            locale,
            const AppointmentStatusBadge(status: AppointmentStatus.held),
          ),
        );
        expect(find.text(label), findsOneWidget, reason: locale.languageCode);
      }
    });

    testWidgets('StatusBadge and PriorityChip use the configured color', (
      tester,
    ) async {
      L10n.current = AppLocales.english;
      await tester.pumpWidget(
        host(
          AppLocales.english,
          const Column(
            children: [
              StatusBadge(label: 'Open', color: Colors.green),
              PriorityChip(priority: null),
            ],
          ),
        ),
      );
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('No priority'), findsOneWidget);
      expect(hexColor('#FF0000', Colors.black), const Color(0xFFFF0000));
      expect(hexColor('nonsense', Colors.black), Colors.black);
      expect(hexColor(null, Colors.blue), Colors.blue);
    });

    testWidgets(
      'VisibilityBadge separates internal notes from customer replies',
      (tester) async {
        L10n.current = AppLocales.english;
        await tester.pumpWidget(
          host(
            AppLocales.english,
            const Column(
              children: [
                VisibilityBadge(internal: true),
                VisibilityBadge(internal: false),
              ],
            ),
          ),
        );
        expect(find.text('Internal note'), findsOneWidget);
        expect(find.text('Customer reply'), findsOneWidget);
      },
    );

    testWidgets('HoldCountdown shows time left, then expired', (tester) async {
      L10n.current = AppLocales.english;
      final now = DateTime(2026, 11, 1, 9);
      await tester.pumpWidget(
        host(
          AppLocales.english,
          HoldCountdown(
            expiresAt: now.add(const Duration(hours: 3, minutes: 20)),
            clock: () => now,
          ),
        ),
      );
      expect(find.textContaining('3h 20m'), findsOneWidget);
      await tester.pumpWidget(
        host(
          AppLocales.english,
          HoldCountdown(
            expiresAt: now.subtract(const Duration(minutes: 1)),
            clock: () => now,
          ),
        ),
      );
      expect(find.text('Expired'), findsOneWidget);
      // Unmount so the periodic timer is cancelled.
      await tester.pumpWidget(const SizedBox());
    });

    test('HoldCountdown formats days, hours, minutes', () {
      L10n.current = AppLocales.english;
      expect(HoldCountdown.format(const Duration(days: 2, hours: 3)), '2d 3h');
      expect(HoldCountdown.format(const Duration(minutes: 45)), '45m');
      expect(HoldCountdown.format(const Duration(seconds: 20)), '20s');
      expect(HoldCountdown.format(Duration.zero), 'Expired');
    });

    testWidgets('ConflictList names the occurrence and the reason', (
      tester,
    ) async {
      L10n.current = AppLocales.english;
      await tester.pumpWidget(
        host(
          AppLocales.english,
          const ConflictList(
            conflicts: [
              ScheduleConflict(occurrence: 2, reason: 'holiday'),
              ScheduleConflict(occurrence: 4, reason: 'employee_busy'),
            ],
          ),
        ),
      );
      expect(find.textContaining('Session 2'), findsOneWidget);
      expect(find.textContaining('Holiday'), findsOneWidget);
      expect(find.textContaining('Employee already busy'), findsOneWidget);
    });
  });

  group('convert prospect dialog', () {
    late TestEnv base;
    late WorkflowTestEnv env;

    setUp(() {
      base = TestEnv()
        ..stubReferenceData()
        ..registerInGet();
      env = WorkflowTestEnv(base);
      Get.put(env.customers);
    });

    Future<Prospect?> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Prospect? result;
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (_) => TextButton(
                onPressed: () async => result = await showConvertProspectDialog(
                  Prospect.fromJson(prospectJson()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('lists the products and converts with the chosen ones', (
      tester,
    ) async {
      base.adapter.reply(
        'POST',
        '/prospects/42/convert',
        wrap(prospectJson()..['is_customer'] = true),
      );
      await open(tester);
      expect(find.text(tr.wfConvertTitle), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsWidgets);
      await tester.tap(find.text(tr.actionConfirm).last);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      final sent = base.adapter.lastTo('POST', '/prospects/42/convert').json;
      expect(sent['product_ids'], [1]);
    });

    testWidgets('ALREADY_CUSTOMER shows the message and disables the action', (
      tester,
    ) async {
      base.adapter.reply(
        'POST',
        '/prospects/42/convert',
        errorBody('This prospect is already a customer.', 'ALREADY_CUSTOMER'),
        status: 409,
      );
      await open(tester);
      await tester.tap(find.text(tr.actionConfirm).last);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(find.text(tr.wfAlreadyCustomer), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.byType(FilledButton).last,
      );
      expect(button.onPressed, isNull);
    });
  });
}
