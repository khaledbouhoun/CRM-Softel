import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/features/prospects/data/models/prospect.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_requests.dart';
import 'package:softel_crm/features/prospects/presentation/controllers/stage_change_controller.dart';
import 'package:softel_crm/features/settings/data/models/loss_reason.dart';
import 'package:softel_crm/features/settings/data/models/sales_stage.dart';

import '../helpers/fixtures.dart';
import '../helpers/mock_http_adapter.dart';
import '../helpers/test_env.dart';

void main() {
  late TestEnv env;
  const transitionPath = '/prospects/42/change-stage';

  setUp(() {
    Get.testMode = true;
    env = TestEnv()..stubReferenceData();
  });

  tearDown(Get.reset);

  Future<StageChangeController> build({int? target}) async {
    final c = Get.put(
      StageChangeController(
        prospect: Prospect.fromJson(prospectJson(stage: openStage)),
        prospectsRepository: env.prospects,
        stagesRepository: env.stages,
        lossReasonsRepository: env.lossReasons,
        initialTargetId: target,
      ),
    );
    await settle();
    return c;
  }

  SalesStage stage(StageChangeController c, int id) =>
      c.stages.firstWhere((s) => s.id == id);
  LossReason reason(StageChangeController c, int id) =>
      c.lossReasons.firstWhere((r) => r.id == id);

  group('StageTransitionRules', () {
    final lost = SalesStage.fromJson(lostStage);
    final won = SalesStage.fromJson(wonStage);
    final needsDetails = LossReason.fromJson(competitor);
    final simple = LossReason.fromJson(tooExpensive);

    test('lost stage requires a loss reason', () {
      expect(
        StageTransitionRules.validate(target: lost, currentStageId: 1),
        isNotNull,
      );
      expect(
        StageTransitionRules.validate(
          target: lost,
          currentStageId: 1,
          lossReason: simple,
        ),
        isNull,
      );
    });

    test('reason with requires_details requires non-blank details', () {
      expect(
        StageTransitionRules.validate(
          target: lost,
          currentStageId: 1,
          lossReason: needsDetails,
          lossDetails: '  ',
        ),
        isNotNull,
      );
      expect(
        StageTransitionRules.validate(
          target: lost,
          currentStageId: 1,
          lossReason: needsDetails,
          lossDetails: 'Concurrent X',
        ),
        isNull,
      );
    });

    test('same stage, no stage or inactive stage are refused', () {
      expect(
        StageTransitionRules.validate(target: null, currentStageId: 1),
        isNotNull,
      );
      expect(
        StageTransitionRules.validate(target: won, currentStageId: 5),
        isNotNull,
      );
      final inactive = SalesStage.fromJson(inactiveStage);
      expect(
        StageTransitionRules.validate(target: inactive, currentStageId: 1),
        isNotNull,
      );
    });

    test('build never sends loss data for a non-lost stage', () {
      final request = StageTransitionRules.build(
        target: won,
        lossReason: simple,
        lossDetails: 'x',
      );
      expect(request.toJson(), {'sales_stage_id': 5});
    });
  });

  group('StageChangeController', () {
    test(
      'loads active stages / reasons and preselects the drop target',
      () async {
        final c = await build(target: 6);
        expect(c.loadState.isSuccess, isTrue);
        expect(c.stages.map((s) => s.id), [1, 2, 5, 6]); // inactive 9 excluded
        expect(c.selectableStages.map((s) => s.id), [
          2,
          5,
          6,
        ]); // current (1) excluded
        expect(c.lossReasons.map((r) => r.id), [1, 2]);
        expect(c.target.value?.id, 6);
        expect(c.requiresLossReason, isTrue);
      },
    );

    test(
      'lost stage without a reason is refused and nothing is sent',
      () async {
        final c = await build();
        c.selectTarget(stage(c, 6));
        final result = await c.submit();
        expect(result, isNull);
        expect(c.errorMessage.value, contains('motif'));
        expect(c.lossReasonError, isNotNull);
        expect(env.adapter.requestsTo('POST', transitionPath), isEmpty);
      },
    );

    test('a reason requiring details cannot be sent without details', () async {
      final c = await build();
      c
        ..selectTarget(stage(c, 6))
        ..selectLossReason(reason(c, 2));
      expect(c.requiresDetails, isTrue);
      expect(await c.submit(), isNull);
      expect(c.lossDetailsError, isNotNull);
      expect(env.adapter.requestsTo('POST', transitionPath), isEmpty);
    });

    test('valid lost transition sends reason and loss note', () async {
      env.adapter.reply(
        'POST',
        transitionPath,
        stageChanged(
          prospectJson(
            stage: lostStage,
            lossReason: competitor,
            lossDetails: 'Concurrent X',
          ),
        ),
      );
      final c = await build();
      c
        ..selectTarget(stage(c, 6))
        ..selectLossReason(reason(c, 2))
        ..setLossDetails('Concurrent X');
      final updated = await c.submit();
      expect(updated, isNotNull);
      expect(updated!.isLost, isTrue);
      expect(env.adapter.lastTo('POST', transitionPath).json, {
        'sales_stage_id': 6,
        'loss_reason_id': 2,
        'loss_note': 'Concurrent X',
      });
    });

    test(
      'won transition is recorded through the API without loss data',
      () async {
        env.adapter.reply(
          'POST',
          transitionPath,
          stageChanged(prospectJson(stage: wonStage)),
        );
        final c = await build();
        c
          ..selectTarget(stage(c, 6))
          ..selectLossReason(reason(c, 1))
          ..selectTarget(stage(c, 5)); // switching away clears loss data
        expect(c.lossReason.value, isNull);
        final updated = await c.submit();
        expect(updated!.isWon, isTrue);
        expect(env.adapter.lastTo('POST', transitionPath).json, {
          'sales_stage_id': 5,
        });
      },
    );

    test('API failure keeps the dialog open with the error', () async {
      env.adapter.fail(
        'POST',
        transitionPath,
        DioExceptionType.connectionError,
      );
      final c = await build();
      c.selectTarget(stage(c, 2));
      expect(await c.submit(), isNull);
      expect(c.errorMessage.value, contains('Impossible de joindre'));
      expect(c.isSubmitting.value, isFalse);
    });

    test('422 from the backend is shown on the matching field', () async {
      env.adapter.reply(
        'POST',
        transitionPath,
        validationError({
          'loss_reason_id': ['Motif inactif.'],
        }),
        status: 422,
      );
      final c = await build();
      c
        ..selectTarget(stage(c, 6))
        ..selectLossReason(reason(c, 1));
      expect(await c.submit(), isNull);
      expect(c.lossReasonError, 'Motif inactif.');
      expect(
        c.errorMessage.value,
        contains('Certaines données sont invalides.'),
      );
    });

    test('a business-rule refusal shows the server message', () async {
      env.adapter.reply('POST', transitionPath, {
        'success': false,
        'message': 'The prospect is already in the stage "Démo faite".',
        'error_code': 'INVALID_STAGE_TRANSITION',
        'errors': {
          'sales_stage_id': [
            'The prospect is already in the stage "Démo faite".',
          ],
        },
      }, status: 422);
      final c = await build();
      c.selectTarget(stage(c, 2));
      expect(await c.submit(), isNull);
      expect(
        c.errorMessage.value,
        startsWith('The prospect is already in the stage'),
      );
    });

    test('double click sends a single request', () async {
      env.adapter.on('POST', transitionPath, (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return MockResponse(200, stageChanged(prospectJson(stage: demoStage)));
      });
      final c = await build();
      c.selectTarget(stage(c, 2));
      final results = await Future.wait([c.submit(), c.submit()]);
      expect(results.whereType<Prospect>(), hasLength(1));
      expect(env.adapter.requestsTo('POST', transitionPath), hasLength(1));
    });

    test('stage loading failure is reported', () async {
      env.adapter.fail(
        'GET',
        '/sales-stages',
        DioExceptionType.connectionTimeout,
      );
      final c = await build();
      expect(c.loadState.hasError, isTrue);
      expect(c.loadState.isConnectionError, isTrue);
    });
  });
}
