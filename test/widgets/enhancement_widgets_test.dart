import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/app/config/app_settings_service.dart';
import 'package:softel_crm/app/config/key_value_store.dart';
import 'package:softel_crm/app/l10n/l10n.dart';
import 'package:softel_crm/app/routes/app_pages.dart';
import 'package:softel_crm/app/routes/app_routes.dart';
import 'package:softel_crm/app/services/connection_service.dart';
import 'package:softel_crm/app/theme/app_theme.dart';
import 'package:softel_crm/core/network/network_info.dart';
import 'package:softel_crm/features/activities/data/models/activity.dart';
import 'package:softel_crm/core/widgets/confirm_dialog.dart';
import 'package:softel_crm/features/activities/domain/activities_repository.dart';
import 'package:softel_crm/features/activities/presentation/controllers/activity_link_controller.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_ref.dart';
import 'package:softel_crm/features/prospects/presentation/dialogs/prospect_dialogs.dart';
import 'package:softel_crm/features/prospects/presentation/dialogs/prospect_search_dialog.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_env.dart';

/// The activity -> prospect link flow (search, confirm a move, link in place)
/// rebuilt from the current building blocks: the UI function that used to
/// orchestrate it no longer exists in lib, only its controller does.
Future<Activity?> linkActivityToProspect(Activity activity) async {
  final controller = ActivityLinkController(
    repository: Get.find<ActivitiesRepository>(),
  );
  if (activity.isFromFollowUp) return null;
  final target = await showProspectSearchDialog();
  if (target == null) return null;
  final confirm = controller.needsConfirmation(activity, target);
  if (confirm) {
    final ok = await showConfirmDialog(
      title: tr.relinkTitle,
      message: tr.relinkBody(
        activity.prospect!.companyName,
        target.companyName,
      ),
      confirmLabel: tr.relinkConfirm,
    );
    if (!ok) return null;
  }
  final result = await controller.link(
    activity,
    target,
    confirmRelink: confirm,
  );
  return result.value;
}

void main() {
  late TestEnv env;

  setUp(() {
    Get.testMode = true;
    L10n.current = AppLocales.french;
    env = TestEnv()
      ..stubReferenceData()
      ..registerInGet();
  });

  tearDown(() {
    Get.reset();
    L10n.current = AppLocales.french;
  });

  void useDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  Widget host(Future<void> Function() onOpen) => GetMaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Builder(
        builder: (_) =>
            TextButton(onPressed: onOpen, child: const Text('open')),
      ),
    ),
  );

  Future<void> typeQuery(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField).last, query);
    await tester.pump(const Duration(milliseconds: 350)); // debounce
    await settle(tester);
  }

  group('shared prospect search dialog', () {
    testWidgets('searches every stage and shows each prospect with its stage', (
      tester,
    ) async {
      useDesktopSize(tester);
      env.adapter.reply(
        'GET',
        '/prospects',
        paginated([
          prospectJson(id: 42, companyName: 'SARL Exemple', stage: openStage),
          prospectJson(
            id: 43,
            companyName: 'EURL Atlas',
            stage: lostStage,
            lossReason: tooExpensive,
          ),
          prospectJson(id: 44, companyName: 'Sté Gagnée', stage: wonStage),
        ], total: 3),
      );
      ProspectRef? picked;
      await tester.pumpWidget(
        host(() async => picked = await showProspectSearchDialog()),
      );
      await tester.tap(find.text('open'));
      await settle(tester);

      await typeQuery(tester, '0550');

      final request = env.adapter.lastTo('GET', '/prospects');
      expect(request.query['search'], '0550');
      // No stage filter: lost and won prospects are found like the others.
      expect(request.query.containsKey('sales_stage_id'), isFalse);
      expect(request.query.containsKey('stage_type'), isFalse);

      expect(find.text('SARL Exemple'), findsOneWidget);
      expect(find.text('EURL Atlas'), findsOneWidget);
      expect(find.text('Sté Gagnée'), findsOneWidget);
      // The current stage of each result is displayed.
      expect(find.text(lostStage['name'] as String), findsWidgets);
      expect(find.text(wonStage['name'] as String), findsWidgets);
      expect(find.text(openStage['name'] as String), findsWidgets);

      await tester.tap(find.text('EURL Atlas'));
      await settle(tester);
      expect(picked!.id, 43);
      expect(picked!.stage!.isLost, isTrue);
    });

    testWidgets(
      'an unknown query shows the empty state, a failure shows the error',
      (tester) async {
        useDesktopSize(tester);
        env.adapter.reply(
          'GET',
          '/prospects',
          paginated(<Map<String, dynamic>>[], total: 0),
        );
        await tester.pumpWidget(host(() async => showProspectSearchDialog()));
        await tester.tap(find.text('open'));
        await settle(tester);
        expect(find.text(tr.searchProspectIdle), findsOneWidget);

        await typeQuery(tester, 'zzz');
        expect(find.text(tr.searchProspectEmpty), findsOneWidget);
      },
    );
  });

  group('linking an activity to a prospect', () {
    Map<String, dynamic> linkedTo43() => activityJson(id: 9, linked: true)
      ..['prospect_id'] = 43
      ..['prospect'] = (prospectSummaryJson(id: 43)..['name'] = 'EURL Atlas');

    setUp(() {
      env.adapter.reply(
        'GET',
        '/prospects',
        paginated([
          prospectJson(
            id: 43,
            companyName: 'EURL Atlas',
            stage: lostStage,
            lossReason: tooExpensive,
          ),
        ], total: 1),
      );
    });

    testWidgets(
      'an unlinked activity is linked in place, without confirmation',
      (tester) async {
        useDesktopSize(tester);
        env.adapter.reply(
          'POST',
          '/activities/9/link-prospect',
          wrap(linkedTo43()),
        );
        Activity? result;
        await tester.pumpWidget(
          host(() async {
            result = await linkActivityToProspect(
              Activity.fromJson(activityJson(id: 9, linked: false)),
            );
          }),
        );
        await tester.tap(find.text('open'));
        await settle(tester);

        await typeQuery(tester, 'atlas');
        await tester.tap(find.text('EURL Atlas'));
        await settle(tester);

        final sent = env.adapter
            .lastTo('POST', '/activities/9/link-prospect')
            .json;
        expect(sent, {'prospect_id': 43});
        expect(
          env.adapter.requestsTo('POST', '/activities'),
          isEmpty,
        ); // nothing duplicated
        expect(result!.id, 9);
        expect(result!.isLinked, isTrue);
        expect(result!.prospect!.id, 43);
      },
    );

    testWidgets(
      'moving an already linked activity asks for confirmation first',
      (tester) async {
        useDesktopSize(tester);
        env.adapter.reply(
          'POST',
          '/activities/9/link-prospect',
          wrap(linkedTo43()),
        );
        Activity? result;
        await tester.pumpWidget(
          host(() async {
            result = await linkActivityToProspect(
              Activity.fromJson(activityJson(id: 9, linked: true)),
            );
          }),
        );
        await tester.tap(find.text('open'));
        await settle(tester);
        await typeQuery(tester, 'atlas');
        await tester.tap(find.text('EURL Atlas'));
        await settle(tester);

        // Confirmation dialog names both prospects; nothing was sent yet.
        expect(find.text(tr.relinkTitle), findsOneWidget);
        expect(find.textContaining('SARL Exemple'), findsWidgets);
        expect(
          env.adapter.requestsTo('POST', '/activities/9/link-prospect'),
          isEmpty,
        );

        await tester.tap(find.text(tr.relinkConfirm));
        await settle(tester);
        expect(env.adapter.lastTo('POST', '/activities/9/link-prospect').json, {
          'prospect_id': 43,
          'confirm_relink': true,
        });
        expect(result!.prospect!.id, 43);
      },
    );

    testWidgets('declining the confirmation keeps the current prospect', (
      tester,
    ) async {
      useDesktopSize(tester);
      Activity? result = Activity.fromJson(activityJson(id: 9, linked: true));
      await tester.pumpWidget(
        host(() async {
          result = await linkActivityToProspect(
            Activity.fromJson(activityJson(id: 9, linked: true)),
          );
        }),
      );
      await tester.tap(find.text('open'));
      await settle(tester);
      await typeQuery(tester, 'atlas');
      await tester.tap(find.text('EURL Atlas'));
      await settle(tester);
      await tester.tap(find.text(tr.actionCancel));
      await settle(tester);

      expect(result, isNull);
      expect(
        env.adapter.requestsTo('POST', '/activities/9/link-prospect'),
        isEmpty,
      );
    });

    testWidgets('an activity converted from a follow-up cannot be moved', (
      tester,
    ) async {
      useDesktopSize(tester);
      Activity? result = Activity.fromJson(activityJson(id: 9));
      await tester.pumpWidget(
        host(() async {
          result = await linkActivityToProspect(
            Activity.fromJson(
              activityJson(id: 9, origin: 'follow_up', followUpId: 4),
            ),
          );
        }),
      );
      await tester.tap(find.text('open'));
      await settle(tester);
      expect(result, isNull);
      expect(
        find.text(tr.searchProspectTitle),
        findsNothing,
      ); // search never opened
      expect(env.adapter.requestsTo('GET', '/prospects'), isEmpty);
    });
  });

  group('prospect form', () {
    testWidgets(
      'saves business activity, source (+ detail) and previous software as stable codes',
      (tester) async {
        useDesktopSize(tester);
        env.adapter.reply(
          'POST',
          '/prospects',
          wrap(prospectJson()),
          status: 201,
        );
        await tester.pumpWidget(host(() async => showProspectFormDialog()));
        await tester.tap(find.text('open'));
        await settle(tester);

        expect(find.text(tr.fieldBusinessActivity), findsOneWidget);
        expect(find.text(tr.fieldSource), findsOneWidget);
        expect(find.text(tr.fieldPreviousSoftware), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, tr.fieldCompanyRequired),
          'Alpha SARL',
        );

        // Business activity: pick a suggestion (stored as a code).
        await tester.tap(find.byTooltip(tr.fieldBusinessActivity));
        await tester.pumpAndSettle();
        await tester.tap(find.text(tr.baWholesale).last);
        await tester.pumpAndSettle();

        // Previous software: free text that is not in the catalogue.
        await tester.enterText(
          find.widgetWithText(TextFormField, tr.fieldPreviousSoftware),
          'Logiciel maison',
        );

        // Source "Other" reveals the detail field.
        await tester.tap(
          find.byWidgetPredicate((w) => w is DropdownButtonFormField<String?>),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(tr.optionOther).last);
        await tester.pumpAndSettle();
        expect(find.text(tr.fieldSourceOther), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextFormField, tr.fieldSourceOther),
          'Salon professionnel',
        );

        await tester.tap(find.text(tr.createProspect));
        await settle(tester);

        final body = env.adapter.lastTo('POST', '/prospects').json;
        expect(body['name'], 'Alpha SARL');
        expect(
          body['business_activity'],
          'wholesale',
        ); // a code, not "Commerce de gros"
        expect(body['source'], 'other');
        expect(body['source_other'], 'Salon professionnel');
        expect(body['previous_software'], 'Logiciel maison');
      },
    );

    testWidgets('the same code is saved whatever the interface language', (
      tester,
    ) async {
      useDesktopSize(tester);
      L10n.current = AppLocales.arabic;
      env.adapter.reply(
        'POST',
        '/prospects',
        wrap(prospectJson()),
        status: 201,
      );
      await tester.pumpWidget(host(() async => showProspectFormDialog()));
      await tester.tap(find.text('open'));
      await settle(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, tr.fieldCompanyRequired),
        'ألفا',
      );
      await tester.tap(find.byTooltip(tr.fieldBusinessActivity));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tr.baWholesale).last); // Arabic label
      await tester.pumpAndSettle();
      await tester.tap(find.text(tr.createProspect));
      await settle(tester);

      expect(
        env.adapter.lastTo('POST', '/prospects').json['business_activity'],
        'wholesale',
      );
    });
  });

  group('languages', () {
    Future<void> pumpProspects(
      WidgetTester tester,
      AppSettingsService settings,
    ) async {
      env.adapter.reply(
        'GET',
        '/prospects',
        paginated([prospectJson()], total: 1),
      );
      Get.put(
        ConnectionService(
          NetworkInfo(httpClientAdapter: env.adapter),
          settings,
          autoCheck: false,
        ),
        permanent: true,
      );
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          locale: settings.locale.value,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          getPages: AppPages.pages,
          initialRoute: Routes.prospects,
        ),
      );
      await settle(tester);
    }

    testWidgets('Arabic is the default, laid out right-to-left', (
      tester,
    ) async {
      useDesktopSize(tester);
      final settings = Get.put(
        AppSettingsService(InMemoryStore()),
        permanent: true,
      );
      expect(settings.locale.value, AppLocales.arabic);
      await pumpProspects(tester, settings);

      expect(find.text('لوحة التحكم'), findsOneWidget); // dashboard (sidebar)
      expect(find.text('عميل محتمل جديد'), findsOneWidget); // "New prospect"
      final direction = Directionality.of(
        tester.element(find.text('عميل محتمل جديد')),
      );
      expect(direction, TextDirection.rtl);
      // The sidebar sits on the right in RTL.
      final sidebar = tester.getRect(find.text('لوحة التحكم'));
      expect(sidebar.center.dx, greaterThan(1600 / 2));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'French and English are left-to-right; switching needs no restart',
      (tester) async {
        useDesktopSize(tester);
        final settings = Get.put(
          AppSettingsService(InMemoryStore({'language_code': 'fr'})),
          permanent: true,
        );
        await pumpProspects(tester, settings);
        expect(find.text('Nouveau prospect'), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.text('Nouveau prospect'))),
          TextDirection.ltr,
        );
        final sidebarFr = tester.getRect(find.text('Tableau de bord'));
        expect(sidebarFr.center.dx, lessThan(1600 / 2));

        await settings.saveLocale(AppLocales.english);
        await settle(tester);
        expect(find.text('New prospect'), findsOneWidget);
        expect(find.text('Nouveau prospect'), findsNothing);
        expect(
          Directionality.of(tester.element(find.text('New prospect'))),
          TextDirection.ltr,
        );

        await settings.saveLocale(AppLocales.arabic);
        await settle(tester);
        expect(find.text('عميل محتمل جديد'), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.text('عميل محتمل جديد'))),
          TextDirection.rtl,
        );

        // User data is untouched by the language switch.
        expect(find.text('SARL Exemple'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('the chosen language is remembered after a restart', (
      tester,
    ) async {
      final store = InMemoryStore();
      final first = AppSettingsService(store);
      expect(first.locale.value, AppLocales.arabic);
      await first.saveLocale(AppLocales.english);
      await tester.pump();
      final afterRestart = AppSettingsService(store);
      expect(afterRestart.locale.value, AppLocales.english);
      expect(L10n.current, AppLocales.english);
    });
  });

  group('themes', () {
    for (final (name, theme) in [
      ('light', AppTheme.light()),
      ('dark', AppTheme.dark()),
    ]) {
      testWidgets(
        'prospects page renders in the $name theme with the brand accent',
        (tester) async {
          useDesktopSize(tester);
          env.adapter.reply(
            'GET',
            '/prospects',
            paginated([prospectJson()], total: 1),
          );
          final settings = Get.put(
            AppSettingsService(InMemoryStore({'language_code': 'fr'})),
            permanent: true,
          );
          Get.put(
            ConnectionService(
              NetworkInfo(httpClientAdapter: env.adapter),
              settings,
              autoCheck: false,
            ),
            permanent: true,
          );
          await tester.pumpWidget(
            GetMaterialApp(
              theme: theme,
              getPages: AppPages.pages,
              initialRoute: Routes.prospects,
            ),
          );
          await settle(tester);

          expect(find.text('SARL Exemple'), findsOneWidget);
          expect(find.text('Nouveau prospect'), findsOneWidget);
          // Primary actions use the accent color through the theme.
          final context = tester.element(find.text('Nouveau prospect'));
          final background = Theme.of(context)
              .filledButtonTheme
              .style!
              .backgroundColor!
              .resolve(<WidgetState>{});
          expect(background, BrandColors.accent);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'light and dark themes keep readable contrast on the main surfaces',
      (tester) async {
        double contrast(Color a, Color b) {
          final la = a.computeLuminance();
          final lb = b.computeLuminance();
          final hi = la > lb ? la : lb;
          final lo = la > lb ? lb : la;
          return (hi + 0.05) / (lo + 0.05);
        }

        for (final theme in [AppTheme.light(), AppTheme.dark()]) {
          final s = theme.colorScheme;
          expect(
            contrast(s.onSurface, s.surface),
            greaterThan(7),
            reason: 'body text',
          );
          expect(
            contrast(s.onSurface, s.surfaceContainerLowest),
            greaterThan(7),
            reason: 'card text',
          );
          expect(
            contrast(s.onSurfaceVariant, s.surface),
            greaterThan(4.5),
            reason: 'secondary text',
          );
          expect(
            contrast(s.onPrimary, s.primary),
            greaterThan(4.5),
            reason: 'primary',
          );
          expect(
            contrast(BrandColors.navy, BrandColors.accent),
            greaterThan(4.5),
            reason: 'accent button text',
          );
        }
      },
    );
  });
}
