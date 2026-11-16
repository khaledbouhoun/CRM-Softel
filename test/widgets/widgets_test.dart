import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/app/config/app_settings_service.dart';
import 'package:softel_crm/app/config/key_value_store.dart';
import 'package:softel_crm/app/routes/app_pages.dart';
import 'package:softel_crm/app/routes/app_routes.dart';
import 'package:softel_crm/app/services/connection_service.dart';
import 'package:softel_crm/app/theme/app_theme.dart';
import 'package:softel_crm/core/network/network_info.dart';
import 'package:softel_crm/features/prospects/data/models/prospect.dart';
import 'package:softel_crm/features/prospects/presentation/dialogs/prospect_dialogs.dart';
import 'package:softel_crm/features/settings/data/models/loss_reason.dart';
import 'package:softel_crm/features/settings/data/models/sales_stage.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_env.dart';

void main() {
  late TestEnv env;

  setUp(() {
    Get.testMode = true;
    env = TestEnv()
      ..stubReferenceData()
      ..registerInGet();
  });

  tearDown(Get.reset);

  void useDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'stage dialog requires a loss reason (and details) for a lost stage',
    (tester) async {
      useDesktopSize(tester);
      Prospect? result;
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (_) => TextButton(
                onPressed: () async {
                  result = await showStageChangeDialog(
                    Prospect.fromJson(prospectJson(stage: openStage)),
                    targetStageId: 6, // as when dropping on the "lost" column
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Changer d\'étape'), findsOneWidget);
      expect(find.text('Motif de perte *'), findsOneWidget);

      // Submitting without a reason is refused and nothing is sent.
      await tester.tap(find.text('Marquer comme perdu'));
      await tester.pumpAndSettle();
      expect(find.text('Le motif de perte est obligatoire.'), findsOneWidget);
      expect(
        env.adapter.requestsTo('POST', '/prospects/42/change-stage'),
        isEmpty,
      );

      // A reason that requires details reveals the mandatory detail field.
      await tester.tap(
        find.byWidgetPredicate((w) => w is DropdownButtonFormField<LossReason>),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Concurrent choisi  (précision requise)').last,
      );
      await tester.pumpAndSettle();
      expect(find.text('Précision *'), findsOneWidget);

      await tester.tap(find.text('Marquer comme perdu'));
      await tester.pumpAndSettle();
      expect(find.text('Précision obligatoire pour ce motif.'), findsOneWidget);
      expect(
        env.adapter.requestsTo('POST', '/prospects/42/change-stage'),
        isEmpty,
      );
      expect(result, isNull);

      // Choosing an open stage removes the loss fields.
      await tester.tap(
        find
            .byWidgetPredicate((w) => w is DropdownButtonFormField<SalesStage>)
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Démo faite').last);
      await tester.pumpAndSettle();
      expect(find.text('Motif de perte *'), findsNothing);
    },
  );

  testWidgets('prospects page renders the desktop shell and the data table', (
    tester,
  ) async {
    useDesktopSize(tester);
    env.adapter.reply(
      'GET',
      '/prospects',
      paginated([
        prospectJson(),
        prospectJson(
          id: 43,
          companyName: 'EURL Atlas',
          stage: lostStage,
          lossReason: tooExpensive,
        ),
      ], total: 2),
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
        theme: AppTheme.light(),
        getPages: AppPages.pages,
        initialRoute: Routes.prospects,
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tableau de bord'), findsOneWidget); // sidebar
    expect(find.text('Nouveau prospect'), findsOneWidget);
    expect(find.text('SARL Exemple'), findsOneWidget);
    expect(find.text('EURL Atlas'), findsOneWidget);
    expect(
      find.text('Trop cher'),
      findsWidgets,
    ); // loss reason under the lost stage
    expect(find.text('1–2 sur 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
