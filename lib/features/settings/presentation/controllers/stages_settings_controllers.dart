import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/sales_stage.dart';
import '../../domain/settings_repositories.dart';
import '../../../../app/l10n/l10n.dart';

/// Moves the item at [from] to final position [to] in a copy of [list].
List<T> moveItem<T>(List<T> list, int from, int to) {
  final copy = [...list];
  final item = copy.removeAt(from);
  copy.insert(to.clamp(0, copy.length), item);
  return copy;
}

class StagesSettingsController extends GetxController {
  StagesSettingsController({
    required SalesStagesRepository repository,
    this.lookups,
  }) : _repository = repository;

  final SalesStagesRepository _repository;
  final LookupService? lookups;

  final stages = <SalesStage>[].obs;
  final state = LoadState();
  final isSavingOrder = false.obs;
  final busyIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    stages.assignAll(await _repository.getStages(includeInactive: true));
  });

  /// Shows the new order immediately (with a saving indicator) and reverts
  /// it if the server refuses.
  Future<ActionResult<void>> move(int from, int to) async {
    if (isSavingOrder.value || from == to) return const ActionResult.success();
    final previous = [...stages];
    final reordered = moveItem(previous, from, to);
    stages.assignAll(reordered);
    isSavingOrder.value = true;
    try {
      final saved = await _repository.reorderStages(
        reordered.map((s) => s.id).toList(),
      );
      stages.assignAll(saved.isEmpty ? reordered : saved);
      await lookups?.refreshQuietly();
      return const ActionResult.success();
    } catch (e) {
      stages.assignAll(previous);
      return ActionResult.failure(ApiException.from(e));
    } finally {
      isSavingOrder.value = false;
    }
  }

  Future<ActionResult<SalesStage>> setActive(SalesStage stage, bool isActive) =>
      _busy(stage.id, () => _repository.setStageActive(stage.id, isActive));

  /// Only for stages never used; the backend refuses otherwise (409).
  Future<ActionResult<void>> delete(SalesStage stage) async {
    if (stage.isUsed) {
      return ActionResult.failure(
        ConflictException(tr.stageUsedDeactivateInstead),
      );
    }
    return _busy(stage.id, () => _repository.deleteStage(stage.id));
  }

  Future<ActionResult<T>> _busy<T>(int id, Future<T> Function() task) async {
    if (busyIds.contains(id)) {
      return ActionResult.failure(CancelledApiException(tr.errBusy));
    }
    busyIds.add(id);
    try {
      final result = await ActionResult.guard(task);
      if (result.isSuccess) await afterMutation();
      return result;
    } finally {
      busyIds.remove(id);
    }
  }

  Future<void> afterMutation() async {
    await load();
    await lookups?.refreshQuietly();
  }
}

class StageFormController extends GetxController {
  StageFormController({required SalesStagesRepository repository, this.initial})
    : _repository = repository;

  final SalesStagesRepository _repository;
  final SalesStage? initial;

  bool get isEdit => initial != null;

  /// The type of a used stage cannot change: it would rewrite the meaning
  /// of historical records (e.g. won → lost).
  bool get isTypeLocked => initial?.isUsed ?? false;

  final formKey = GlobalKey<FormState>();
  late final name = TextEditingController(text: initial?.name);
  late final colorHex = (initial?.colorHex.toUpperCase() ?? '#3B82F6').obs;
  late final type = (initial?.type ?? StageType.open).obs;
  late final isActive = (initial?.isActive ?? true).obs;

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;

  String? validateName(String? v) =>
      serverErrors['name'] ??
      Validators.combine([
        () => Validators.required(v, field: tr.validFieldName),
        () => Validators.maxLength(v, 100),
      ]);

  String? get colorError =>
      serverErrors['color'] ?? Validators.hexColor(colorHex.value);

  /// Also set when the server refuses to retype a stage used only by
  /// history (`STAGE_TYPE_LOCKED`).
  String? get typeError => serverErrors['stage_type'];

  static const displayedFields = {'name', 'color', 'stage_type'};

  Map<String, String> validateAll() {
    final errors = <String, String>{};
    final n = validateName(name.text);
    if (n != null) errors['name'] = n;
    if (colorError != null) errors['color'] = colorError!;
    return errors;
  }

  Future<SalesStage?> submit() async {
    if (isSubmitting.value) return null;
    serverErrors.clear();
    errorMessage.value = null;
    final widgetValid = formKey.currentState?.validate() ?? true;
    if (!widgetValid || validateAll().isNotEmpty) return null;
    isSubmitting.value = true;
    try {
      final payload = SalesStagePayload(
        name: name.text,
        colorHex: colorHex.value,
        type: isTypeLocked ? initial!.type : type.value,
        isActive: isActive.value,
      );
      return isEdit
          ? await _repository.updateStage(initial!.id, payload)
          : await _repository.createStage(payload);
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k] = m.first;
      });
      errorMessage.value = e.describeFor(displayedFields);
      formKey.currentState?.validate();
      return null;
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    name.dispose();
    super.onClose();
  }
}
