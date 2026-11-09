import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/loss_reason.dart';
import '../../domain/settings_repositories.dart';
import 'stages_settings_controllers.dart' show moveItem;
import '../../../../app/l10n/l10n.dart';

class LossReasonsSettingsController extends GetxController {
  LossReasonsSettingsController({
    required LossReasonsRepository repository,
    this.lookups,
  }) : _repository = repository;

  final LossReasonsRepository _repository;
  final LookupService? lookups;

  final reasons = <LossReason>[].obs;
  final state = LoadState();
  final isSavingOrder = false.obs;
  final busyIds = <int>{}.obs;

  /// Set when the backend does not expose the management endpoints
  /// (404/405 on a mutation): the screen becomes read-only.
  final isReadOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    reasons.assignAll(await _repository.getLossReasons(includeInactive: true));
  });

  /// Marks the screen read-only if [error] means "endpoint not available".
  void noteUnsupported(ApiException? error) {
    if (error is NotFoundException || error is NotSupportedException) {
      isReadOnly.value = true;
    }
  }

  Future<ActionResult<void>> move(int from, int to) async {
    if (isSavingOrder.value || from == to) return const ActionResult.success();
    final previous = [...reasons];
    final reordered = moveItem(previous, from, to);
    reasons.assignAll(reordered);
    isSavingOrder.value = true;
    try {
      final saved = await _repository.reorderLossReasons(
        reordered.map((r) => r.id).toList(),
      );
      reasons.assignAll(saved.isEmpty ? reordered : saved);
      await lookups?.refreshQuietly();
      return const ActionResult.success();
    } catch (e) {
      reasons.assignAll(previous);
      final error = ApiException.from(e);
      noteUnsupported(error);
      return ActionResult.failure(error);
    } finally {
      isSavingOrder.value = false;
    }
  }

  Future<ActionResult<LossReason>> setActive(
    LossReason reason,
    bool isActive,
  ) async {
    if (busyIds.contains(reason.id)) {
      return ActionResult.failure(CancelledApiException(tr.errBusy));
    }
    busyIds.add(reason.id);
    try {
      final result = await ActionResult.guard(
        () => _repository.setLossReasonActive(reason.id, isActive),
      );
      if (result.isSuccess) {
        await afterMutation();
      } else {
        noteUnsupported(result.error);
      }
      return result;
    } finally {
      busyIds.remove(reason.id);
    }
  }

  Future<void> afterMutation() async {
    await load();
    await lookups?.refreshQuietly();
  }
}

class LossReasonFormController extends GetxController {
  LossReasonFormController({
    required LossReasonsRepository repository,
    this.initial,
  }) : _repository = repository;

  final LossReasonsRepository _repository;
  final LossReason? initial;

  bool get isEdit => initial != null;

  final formKey = GlobalKey<FormState>();
  late final label = TextEditingController(text: initial?.label);
  late final requiresDetails = (initial?.requiresDetails ?? false).obs;
  late final isActive = (initial?.isActive ?? true).obs;

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;

  /// Last error, so the list screen can switch to read-only on 404/405.
  ApiException? lastError;

  /// The label is the API's `name`.
  String? validateLabel(String? v) =>
      serverErrors['name'] ??
      Validators.combine([
        () => Validators.required(v, field: tr.validFieldLabel),
        () => Validators.maxLength(v, 100),
      ]);

  Future<LossReason?> submit() async {
    if (isSubmitting.value) return null;
    serverErrors.clear();
    errorMessage.value = null;
    final widgetValid = formKey.currentState?.validate() ?? true;
    if (!widgetValid || validateLabel(label.text) != null) return null;
    isSubmitting.value = true;
    try {
      final payload = LossReasonPayload(
        label: label.text,
        requiresDetails: requiresDetails.value,
        isActive: isActive.value,
      );
      return isEdit
          ? await _repository.updateLossReason(initial!.id, payload)
          : await _repository.createLossReason(payload);
    } on ValidationException catch (e) {
      lastError = e;
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k] = m.first;
      });
      errorMessage.value = e.describeFor(const {'name'});
      formKey.currentState?.validate();
      return null;
    } catch (e) {
      lastError = ApiException.from(e);
      errorMessage.value = lastError!.message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    label.dispose();
    super.onClose();
  }
}
