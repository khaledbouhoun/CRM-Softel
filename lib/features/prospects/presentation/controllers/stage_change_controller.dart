import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/load_state.dart';
import '../../../settings/data/models/loss_reason.dart';
import '../../../settings/data/models/sales_stage.dart';
import '../../../settings/domain/settings_repositories.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_requests.dart';
import '../../domain/prospects_repository.dart';
import '../../../../app/l10n/l10n.dart';

/// Moves a prospect to another stage, enforcing the lost-stage rule (§4.5).
///
/// Used by the prospects table (quick change), the details page and the
/// pipeline (drag and drop). Nothing changes in the UI until the API
/// confirms the transition.
class StageChangeController extends GetxController {
  StageChangeController({
    required this.prospect,
    required ProspectsRepository prospectsRepository,
    required SalesStagesRepository stagesRepository,
    required LossReasonsRepository lossReasonsRepository,
    this.initialTargetId,
  }) : _prospects = prospectsRepository,
       _stages = stagesRepository,
       _reasons = lossReasonsRepository;

  final Prospect prospect;
  final int? initialTargetId;
  final ProspectsRepository _prospects;
  final SalesStagesRepository _stages;
  final LossReasonsRepository _reasons;

  final stages = <SalesStage>[].obs;
  final lossReasons = <LossReason>[].obs;
  final loadState = LoadState();

  final target = Rxn<SalesStage>();
  final lossReason = Rxn<LossReason>();
  final lossDetails = ''.obs;

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;
  final showValidation = false.obs;

  SalesStage? get currentStage => prospect.stage;

  bool get requiresLossReason => target.value?.isLost ?? false;

  bool get requiresDetails =>
      requiresLossReason && (lossReason.value?.requiresDetails ?? false);

  /// Active stages other than the current one.
  List<SalesStage> get selectableStages =>
      stages.where((s) => s.id != currentStage?.id).toList(growable: false);

  String? get validationError => StageTransitionRules.validate(
    target: target.value,
    currentStageId: currentStage?.id,
    lossReason: lossReason.value,
    lossDetails: lossDetails.value,
  );

  String? get lossReasonError {
    if (serverErrors['loss_reason_id'] != null) {
      return serverErrors['loss_reason_id'];
    }
    if (!showValidation.value || !requiresLossReason) return null;
    return lossReason.value == null ? tr.validLossReasonRequired : null;
  }

  String? get lossDetailsError {
    if (serverErrors['loss_note'] != null) return serverErrors['loss_note'];
    if (!showValidation.value || !requiresDetails) return null;
    return lossDetails.value.trim().isEmpty ? tr.validDetailsRequired : null;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Loads fresh stages and loss reasons from the server.
  Future<void> load() => loadState.run(() async {
    final results = await Future.wait([
      _stages.getStages(),
      _reasons.getLossReasons(),
    ]);
    stages.assignAll((results[0] as List<SalesStage>).where((s) => s.isActive));
    lossReasons.assignAll(
      (results[1] as List<LossReason>).where((r) => r.isActive),
    );
    if (initialTargetId != null && target.value == null) {
      target.value = stages.firstWhereOrNull((s) => s.id == initialTargetId);
    }
  });

  void selectTarget(SalesStage? stage) {
    target.value = stage;
    if (stage == null || !stage.isLost) {
      lossReason.value = null;
      lossDetails.value = '';
    }
    errorMessage.value = null;
    serverErrors.clear();
  }

  void selectLossReason(LossReason? reason) {
    lossReason.value = reason;
    if (reason == null || !reason.requiresDetails) lossDetails.value = '';
    serverErrors.remove('loss_reason_id');
    errorMessage.value = null;
  }

  void setLossDetails(String value) {
    lossDetails.value = value;
    serverErrors.remove('loss_note');
  }

  /// Returns the updated prospect on success, null otherwise.
  Future<Prospect?> submit() async {
    if (isSubmitting.value) return null;
    showValidation.value = true;
    final error = validationError;
    if (error != null) {
      errorMessage.value = error;
      return null;
    }
    isSubmitting.value = true;
    errorMessage.value = null;
    serverErrors.clear();
    try {
      final request = StageTransitionRules.build(
        target: target.value!,
        lossReason: lossReason.value,
        lossDetails: lossDetails.value,
      );
      return await _prospects.changeStage(prospect.id, request);
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((key, messages) {
        if (messages.isNotEmpty) {
          serverErrors[key.split('.').first] = messages.first;
        }
      });
      final extra = e.allMessages.isEmpty
          ? ''
          : '\n${e.allMessages.join('\n')}';
      errorMessage.value = '${e.message}$extra';
      return null;
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}
