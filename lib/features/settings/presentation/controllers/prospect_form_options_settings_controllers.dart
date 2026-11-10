import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/prospect_form_option.dart';
import '../../domain/settings_repositories.dart';
import 'stages_settings_controllers.dart' show moveItem;

class ProspectFormOptionsSettingsController extends GetxController {
  ProspectFormOptionsSettingsController({
    required ProspectFormOptionsRepository repository,
    this.lookups,
  }) : _repository = repository;

  final ProspectFormOptionsRepository _repository;
  final LookupService? lookups;

  final selectedType = ProspectFormOption.typeSource.obs;
  final allOptions = <ProspectFormOption>[].obs;
  final state = LoadState();
  final isSavingOrder = false.obs;
  final busyIds = <int>{}.obs;
  final isReadOnly = false.obs;

  List<ProspectFormOption> get currentOptions => allOptions
      .where((o) => o.type == selectedType.value)
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void selectType(String type) {
    selectedType.value = type;
  }

  Future<void> load() => state.run(() async {
    allOptions.assignAll(
      await _repository.getOptions(includeInactive: true),
    );
  });

  void noteUnsupported(ApiException? error) {
    if (error is NotFoundException || error is NotSupportedException) {
      isReadOnly.value = true;
    }
  }

  Future<ActionResult<void>> move(int from, int to) async {
    if (isSavingOrder.value || from == to) return const ActionResult.success();
    final type = selectedType.value;
    final current = currentOptions;
    if (from < 0 || from >= current.length || to < 0 || to >= current.length) {
      return const ActionResult.success();
    }

    final reordered = moveItem(current, from, to);
    final previousAll = [...allOptions];

    // Update local state optimistically
    allOptions.removeWhere((o) => o.type == type);
    allOptions.addAll(reordered);

    isSavingOrder.value = true;
    try {
      final saved = await _repository.reorderOptions(
        type,
        reordered.map((o) => o.id).toList(),
      );
      allOptions.removeWhere((o) => o.type == type);
      allOptions.addAll(saved.isEmpty ? reordered : saved);
      await lookups?.refreshQuietly();
      return const ActionResult.success();
    } catch (e) {
      allOptions.assignAll(previousAll);
      final error = ApiException.from(e);
      noteUnsupported(error);
      return ActionResult.failure(error);
    } finally {
      isSavingOrder.value = false;
    }
  }

  Future<ActionResult<ProspectFormOption>> setActive(
    ProspectFormOption option,
    bool isActive,
  ) async {
    if (busyIds.contains(option.id)) {
      return ActionResult.failure(CancelledApiException(tr.errBusy));
    }
    busyIds.add(option.id);
    try {
      final result = await ActionResult.guard(
        () => _repository.setOptionActive(option.id, isActive),
      );
      if (result.isSuccess) {
        await afterMutation();
      } else {
        noteUnsupported(result.error);
      }
      return result;
    } finally {
      busyIds.remove(option.id);
    }
  }

  Future<ActionResult<void>> delete(ProspectFormOption option) async {
    if (busyIds.contains(option.id)) {
      return ActionResult.failure(CancelledApiException(tr.errBusy));
    }
    busyIds.add(option.id);
    try {
      final result = await ActionResult.guard(
        () => _repository.deleteOption(option.id),
      );
      if (result.isSuccess) {
        await afterMutation();
      }
      return result;
    } finally {
      busyIds.remove(option.id);
    }
  }

  Future<void> afterMutation() async {
    await load();
    await lookups?.refreshQuietly();
  }
}

class ProspectFormOptionFormController extends GetxController {
  ProspectFormOptionFormController({
    required ProspectFormOptionsRepository repository,
    required this.type,
    this.initial,
  }) : _repository = repository;

  final ProspectFormOptionsRepository _repository;
  final String type;
  final ProspectFormOption? initial;

  bool get isEdit => initial != null;

  final formKey = GlobalKey<FormState>();
  late final name = TextEditingController(text: initial?.name);
  late final requiresDetails = (initial?.requiresDetails ?? false).obs;
  late final isActive = (initial?.isActive ?? true).obs;

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;

  ApiException? lastError;

  String? validateName(String? v) =>
      serverErrors['name'] ??
      Validators.combine([
        () => Validators.required(v, field: tr.validFieldName),
        () => Validators.maxLength(v, 150),
      ]);

  Future<ProspectFormOption?> submit() async {
    if (isSubmitting.value) return null;
    serverErrors.clear();
    errorMessage.value = null;
    lastError = null;

    if (!(formKey.currentState?.validate() ?? true)) return null;

    isSubmitting.value = true;
    try {
      final payload = ProspectFormOptionPayload(
        type: type,
        name: name.text.trim(),
        requiresDetails: requiresDetails.value,
        isActive: isActive.value,
      );
      final saved = isEdit
          ? await _repository.updateOption(initial!.id, payload)
          : await _repository.createOption(payload);
      return saved;
    } on ValidationException catch (e) {
      serverErrors.assignAll(
        e.fieldErrors.map((k, v) => MapEntry(k, v.firstOrNull ?? '')),
      );
      errorMessage.value = e.message;
      formKey.currentState?.validate();
      return null;
    } catch (e) {
      final error = ApiException.from(e);
      lastError = error;
      errorMessage.value = error.message;
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
