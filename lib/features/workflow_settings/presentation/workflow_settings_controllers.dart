import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/l10n/l10n.dart';
import '../../../app/services/workflow_lookup_service.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/state/action_result.dart';
import '../../../core/state/load_state.dart';
import '../../../core/utils/json_utils.dart';
import '../../scheduling/data/models/scheduling_settings.dart';
import '../data/models/config_models.dart';
import '../domain/workflow_config_repository.dart';
import 'config_schema.dart';

/// Rows of one configurable list. Rows are deactivated, never deleted, so
/// history that references them keeps its labels.
class ConfigEntityController extends GetxController {
  ConfigEntityController({
    required this.schema,
    required WorkflowConfigRepository repository,
    this.workflow,
  }) : _repository = repository;

  final ConfigSchema schema;
  final WorkflowConfigRepository _repository;

  /// Refreshed after every change so pickers elsewhere see the new values.
  final WorkflowLookupService? workflow;

  final rows = <ConfigRow>[].obs;
  final state = LoadState();
  final busyIds = <int>{}.obs;
  final showInactive = true.obs;

  List<ConfigRow> get visibleRows => rows
      .where((r) => showInactive.value || r.isActive)
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    rows.assignAll(await _repository.getRows(schema.entity));
  });

  Future<void> _afterChange() async {
    await load();
    await workflow?.refreshQuietly();
  }

  Future<ActionResult<ConfigRow>> toggleActive(ConfigRow row) async {
    if (busyIds.contains(row.id)) return ActionResult.success(row);
    busyIds.add(row.id);
    try {
      final result = await ActionResult.guard(
        () => row.isActive
            ? _repository.deactivate(schema.entity, row.id)
            : _repository.reactivate(schema.entity, row.id),
      );
      if (result.isSuccess) await _afterChange();
      return result;
    } finally {
      busyIds.remove(row.id);
    }
  }

  Future<void> saved() => _afterChange();

  Future<ConfigRow> save(ConfigRow? existing, Map<String, dynamic> payload) {
    return existing == null
        ? _repository.create(schema.entity, payload)
        : _repository.update(schema.entity, existing.id, payload);
  }
}

/// Form state for one configuration row, driven by the [ConfigSchema].
class ConfigFormController extends GetxController {
  ConfigFormController({
    required this.schema,
    required ConfigEntityController list,
    this.existing,
    this.defaults,
  }) : _list = list {
    for (final f in schema.fields) {
      final current = existing?.data[f.key] ?? defaults?[f.key];
      switch (f.kind) {
        case ConfigFieldKind.text:
        case ConfigFieldKind.multiline:
        case ConfigFieldKind.url:
        case ConfigFieldKind.integer:
          texts[f.key] = TextEditingController(
            text: current == null
                ? (existing == null ? (f.initial?.toString() ?? '') : '')
                : current.toString(),
          );
        case ConfigFieldKind.boolean:
          bools[f.key] = asBool(current, fallback: f.initial == true);
        case ConfigFieldKind.color:
          choices[f.key] =
              asStringOrNull(current) ?? f.initial?.toString() ?? '#64748B';
        case ConfigFieldKind.choice:
          choices[f.key] = asStringOrNull(current) ?? f.initial?.toString();
        case ConfigFieldKind.date:
          choices[f.key] = asStringOrNull(current)?.split('T').first;
        case ConfigFieldKind.status:
        case ConfigFieldKind.product:
          ids[f.key] = asIntOrNull(current);
      }
    }
  }

  final ConfigSchema schema;
  final ConfigEntityController _list;
  final ConfigRow? existing;

  /// Values preset on a new row (for example the product of a resource).
  final Map<String, dynamic>? defaults;

  final texts = <String, TextEditingController>{};
  final bools = <String, bool>{}.obs;
  final choices = <String, String?>{}.obs;
  final ids = <String, int?>{}.obs;

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;
  final showValidation = false.obs;

  bool get isEdit => existing != null;

  static final _codePattern = RegExp(r'^[a-z][a-z0-9_]*$');

  String? validate(ConfigField f) {
    final server = serverErrors[f.key];
    if (server != null) return server;
    final raw = texts[f.key]?.text.trim() ?? '';
    switch (f.kind) {
      case ConfigFieldKind.text:
      case ConfigFieldKind.multiline:
      case ConfigFieldKind.url:
        if (raw.isEmpty) return f.required ? tr.wfFieldRequired : null;
        if (f.maxLength != null && raw.length > f.maxLength!) {
          return tr.wfTooLong(f.maxLength!);
        }
        if (f.isCode && !_codePattern.hasMatch(raw)) return tr.wfCodeInvalid;
        if (f.kind == ConfigFieldKind.url) {
          final uri = Uri.tryParse(raw);
          final ok =
              uri != null &&
              (uri.scheme == 'http' || uri.scheme == 'https') &&
              uri.host.isNotEmpty;
          if (!ok) return tr.wfUrlInvalid;
        }
        return null;
      case ConfigFieldKind.integer:
        if (raw.isEmpty) {
          return f.nullable || !f.required ? null : tr.wfFieldRequired;
        }
        final n = int.tryParse(raw);
        return (n == null || n < 0) ? tr.wfNumberInvalid : null;
      case ConfigFieldKind.choice:
      case ConfigFieldKind.date:
        return f.required && (choices[f.key] ?? '').isEmpty
            ? tr.wfFieldRequired
            : null;
      case ConfigFieldKind.status:
      case ConfigFieldKind.product:
        return f.required && ids[f.key] == null ? tr.wfFieldRequired : null;
      case ConfigFieldKind.boolean:
      case ConfigFieldKind.color:
        return null;
    }
  }

  bool get isValid => schema.fields.every((f) => validate(f) == null);

  /// Values to send. Immutable fields (codes) are only sent on creation.
  Map<String, dynamic> buildPayload() {
    final payload = <String, dynamic>{};
    for (final f in schema.fields) {
      if (isEdit && f.immutable) continue;
      switch (f.kind) {
        case ConfigFieldKind.text:
        case ConfigFieldKind.multiline:
        case ConfigFieldKind.url:
          final v = texts[f.key]!.text.trim();
          if (v.isNotEmpty || f.required) payload[f.key] = v;
        case ConfigFieldKind.integer:
          final v = texts[f.key]!.text.trim();
          if (v.isEmpty) {
            if (f.nullable) payload[f.key] = null;
          } else {
            payload[f.key] = int.parse(v);
          }
        case ConfigFieldKind.boolean:
          payload[f.key] = bools[f.key] ?? false;
        case ConfigFieldKind.color:
        case ConfigFieldKind.choice:
        case ConfigFieldKind.date:
          final v = choices[f.key];
          if (v != null && v.isNotEmpty) payload[f.key] = v;
        case ConfigFieldKind.status:
        case ConfigFieldKind.product:
          final v = ids[f.key];
          if (v != null) payload[f.key] = v;
      }
    }
    return payload;
  }

  Future<ConfigRow?> submit() async {
    if (isSubmitting.value) return null;
    showValidation.value = true;
    serverErrors.clear();
    errorMessage.value = null;
    if (!isValid) {
      errorMessage.value = tr.validFixFields;
      return null;
    }
    isSubmitting.value = true;
    try {
      final saved = await _list.save(existing, buildPayload());
      await _list.saved();
      return saved;
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k.split('.').first] = m.first;
      });
      errorMessage.value = e.describeFor(
        schema.fields.map((f) => f.key).toSet(),
      );
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
    for (final c in texts.values) {
      c.dispose();
    }
    super.onClose();
  }
}

/// Business hours and booking policy (`/settings/scheduling`).
class SchedulingSettingsController extends GetxController {
  SchedulingSettingsController({
    required WorkflowConfigRepository repository,
    this.workflow,
  }) : _repository = repository;

  final WorkflowConfigRepository _repository;
  final WorkflowLookupService? workflow;

  final state = LoadState();
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final saved = false.obs;

  final workingDays = <int>{}.obs;
  final workStart = TextEditingController();
  final workEnd = TextEditingController();
  final slotMinutes = TextEditingController();
  final holdExpiryMinutes = TextEditingController();
  final bookingHorizonDays = TextEditingController();
  final minNoticeHours = TextEditingController();
  final demoCapacity = TextEditingController();
  final accompanimentOccurrences = TextEditingController();
  final accompanimentIntervalDays = TextEditingController();
  final trialDefaultDays = TextEditingController();
  final whatsappCountryCode = TextEditingController();
  final serverErrors = <String, String>{}.obs;
  final showValidation = false.obs;

  static final _time = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    apply(await _repository.getScheduling());
  });

  void apply(SchedulingSettings s) {
    workingDays
      ..clear()
      ..addAll(s.workingDays);
    workStart.text = s.workStart;
    workEnd.text = s.workEnd;
    slotMinutes.text = '${s.slotMinutes}';
    holdExpiryMinutes.text = '${s.holdExpiryMinutes}';
    bookingHorizonDays.text = '${s.bookingHorizonDays}';
    minNoticeHours.text = '${s.minNoticeHours}';
    demoCapacity.text = '${s.demoCapacity}';
    accompanimentOccurrences.text = '${s.accompanimentOccurrences}';
    accompanimentIntervalDays.text = '${s.accompanimentIntervalDays}';
    trialDefaultDays.text = '${s.trialDefaultDays}';
    whatsappCountryCode.text = s.whatsappCountryCode;
  }

  String? validateTime(String key, TextEditingController c) {
    final v = c.text.trim();
    return serverErrors[key] ?? (_time.hasMatch(v) ? null : tr.wfTimeInvalid);
  }

  String? validateRange(String key, TextEditingController c, int min, int max) {
    final n = int.tryParse(c.text.trim());
    if (n == null || n < min || n > max) return tr.wfRangeError(min, max);
    return serverErrors[key];
  }

  String? get daysError => workingDays.isEmpty ? tr.wfPickWorkingDay : null;

  String? get endError {
    final s = workStart.text.trim();
    final e = workEnd.text.trim();
    if (_time.hasMatch(s) && _time.hasMatch(e) && e.compareTo(s) <= 0) {
      return tr.wfEndAfterStart;
    }
    return null;
  }

  String? validateCountryCode(String? v) {
    final t = v?.trim() ?? '';
    return RegExp(r'^[0-9]{1,4}$').hasMatch(t)
        ? serverErrors['whatsapp_country_code']
        : tr.wfCountryCodeInvalid;
  }

  bool get isValid =>
      daysError == null &&
      endError == null &&
      validateTime('work_start', workStart) == null &&
      validateTime('work_end', workEnd) == null &&
      validateRange('slot_minutes', slotMinutes, 5, 480) == null &&
      validateRange('hold_expiry_minutes', holdExpiryMinutes, 5, 43200) ==
          null &&
      validateRange('booking_horizon_days', bookingHorizonDays, 1, 365) ==
          null &&
      validateRange('min_notice_hours', minNoticeHours, 0, 720) == null &&
      validateRange('demo_capacity', demoCapacity, 1, 50) == null &&
      validateRange(
            'accompaniment_occurrences',
            accompanimentOccurrences,
            1,
            52,
          ) ==
          null &&
      validateRange(
            'accompaniment_interval_days',
            accompanimentIntervalDays,
            1,
            365,
          ) ==
          null &&
      validateRange('trial_default_days', trialDefaultDays, 1, 365) == null &&
      validateCountryCode(whatsappCountryCode.text) == null;

  SchedulingSettings build() => SchedulingSettings(
    workingDays: (workingDays.toList()..sort()),
    workStart: workStart.text.trim(),
    workEnd: workEnd.text.trim(),
    slotMinutes: int.parse(slotMinutes.text.trim()),
    holdExpiryMinutes: int.parse(holdExpiryMinutes.text.trim()),
    bookingHorizonDays: int.parse(bookingHorizonDays.text.trim()),
    minNoticeHours: int.parse(minNoticeHours.text.trim()),
    demoCapacity: int.parse(demoCapacity.text.trim()),
    accompanimentOccurrences: int.parse(accompanimentOccurrences.text.trim()),
    accompanimentIntervalDays: int.parse(accompanimentIntervalDays.text.trim()),
    trialDefaultDays: int.parse(trialDefaultDays.text.trim()),
    whatsappCountryCode: whatsappCountryCode.text.trim(),
  );

  Future<bool> save() async {
    if (isSaving.value) return false;
    showValidation.value = true;
    serverErrors.clear();
    errorMessage.value = null;
    saved.value = false;
    if (!isValid) {
      errorMessage.value = tr.validFixFields;
      return false;
    }
    isSaving.value = true;
    try {
      apply(await _repository.updateScheduling(build()));
      await workflow?.refreshQuietly();
      saved.value = true;
      return true;
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k.split('.').first] = m.first;
      });
      errorMessage.value = e.describeFor(const {
        'working_days',
        'work_start',
        'work_end',
        'slot_minutes',
        'hold_expiry_minutes',
        'booking_horizon_days',
        'min_notice_hours',
        'demo_capacity',
        'accompaniment_occurrences',
        'accompaniment_interval_days',
        'trial_default_days',
        'whatsapp_country_code',
      });
      return false;
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    for (final c in [
      workStart,
      workEnd,
      slotMinutes,
      holdExpiryMinutes,
      bookingHorizonDays,
      minNoticeHours,
      demoCapacity,
      accompanimentOccurrences,
      accompanimentIntervalDays,
      trialDefaultDays,
      whatsappCountryCode,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
