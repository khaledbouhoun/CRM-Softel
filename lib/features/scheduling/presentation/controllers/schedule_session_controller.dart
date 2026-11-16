import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/workflow_lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../prospects/data/models/prospect_ref.dart';
import '../../../workflow_settings/data/models/config_models.dart';
import '../../../workflow_settings/domain/workflow_config_repository.dart';
import '../../data/models/appointment.dart';
import '../../domain/scheduling_repository.dart';

/// Which kind of session the dialog schedules.
enum SessionMode {
  training('training'),
  accompaniment('accompaniment');

  const SessionMode(this.group);

  /// Appointment type group offered for this mode.
  final String group;
}

/// Creates a training session or an accompaniment series.
///
/// Accompaniment defaults (number of sessions and interval) come from the
/// CRM scheduling settings. The whole series is checked on the server before
/// anything is saved: a `409 APPOINTMENT_CONFLICT` lists each clashing
/// occurrence in [conflicts] and nothing is created.
class ScheduleSessionController extends GetxController {
  ScheduleSessionController({
    required SchedulingRepository repository,
    required WorkflowLookupService workflow,
    required this.mode,
    WorkflowConfigRepository? configRepository,
    ProspectRef? customer,
    DateTime Function()? clock,
  }) : _repository = repository,
       _workflow = workflow,
       _config = configRepository,
       _clock = clock ?? DateTime.now {
    this.customer.value = customer;
    final settings = workflow.scheduling.value;
    occurrences.text = '${settings?.accompanimentOccurrences ?? 1}';
    interval.text = '${settings?.accompanimentIntervalDays ?? 7}';
    final types = workflow.typesOfGroup(mode.group);
    if (types.isNotEmpty) selectType(types.first);
    final now = _clock();
    date.value = DateTime(now.year, now.month, now.day + 1);
    final start = _parseTime(settings?.workStart);
    if (start != null) startTime.value = start;
    _applyDefaultEnd();
    final self = workflow.identity.username;
    if (self.isNotEmpty) employee.value = self;
  }

  final SchedulingRepository _repository;
  final WorkflowLookupService _workflow;
  final WorkflowConfigRepository? _config;
  final DateTime Function() _clock;
  final SessionMode mode;

  final customer = Rxn<ProspectRef>();
  final type = Rxn<AppointmentType>();
  final productId = RxnInt();
  final date = Rxn<DateTime>();
  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();
  final employee = RxnString();
  final notes = TextEditingController();
  final resourceUrl = TextEditingController();
  final occurrences = TextEditingController();
  final interval = TextEditingController();
  final sendWhatsapp = false.obs;

  /// Training material links of the selected product (configured in the CRM).
  final resources = <ProductResource>[].obs;

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;
  final showValidation = false.obs;
  final conflicts = <ScheduleConflict>[].obs;

  bool get isAccompaniment => mode == SessionMode.accompaniment;
  List<AppointmentType> get types => _workflow.typesOfGroup(mode.group);

  int get occurrenceCount => int.tryParse(occurrences.text.trim()) ?? 0;
  int get intervalDays => int.tryParse(interval.text.trim()) ?? 0;

  static TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  void selectType(AppointmentType value) {
    type.value = value;
    _applyDefaultEnd();
  }

  /// Default end = start + the type's configured duration.
  void _applyDefaultEnd() {
    final start = startTime.value;
    final t = type.value;
    if (start == null || t == null) return;
    final total = start.hour * 60 + start.minute + t.defaultDurationMinutes;
    endTime.value = TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  void setStartTime(TimeOfDay value) {
    startTime.value = value;
    _applyDefaultEnd();
  }

  Future<void> selectProduct(int? id) async {
    productId.value = id;
    resources.clear();
    if (id == null || _config == null) return;
    try {
      final rows = await _config.getRows(ConfigEntities.productResources);
      resources.assignAll(
        rows
            .map((r) => ProductResource.fromJson(r.data))
            .where((r) => r.productId == id && r.isActive),
      );
    } catch (_) {
      // Optional helper: the URL can still be typed by hand.
    }
  }

  DateTime? get startsAt => _combine(date.value, startTime.value);
  DateTime? get endsAt => _combine(date.value, endTime.value);

  static DateTime? _combine(DateTime? day, TimeOfDay? time) =>
      day == null || time == null
      ? null
      : DateTime(day.year, day.month, day.day, time.hour, time.minute);

  String? get customerError => showValidation.value && customer.value == null
      ? tr.validSelectProspect
      : serverErrors['prospect_id'];

  String? get typeError => showValidation.value && type.value == null
      ? tr.wfSelectType
      : serverErrors['appointment_type_id'];

  String? get startError {
    final s = startsAt;
    if (s == null) {
      return showValidation.value ? tr.validDateRequired : null;
    }
    if (s.isBefore(_clock())) return tr.wfStartInPast;
    return serverErrors['starts_at'];
  }

  String? get endError {
    final s = startsAt;
    final e = endsAt;
    if (s == null || e == null) return null;
    return e.isAfter(s) ? serverErrors['ends_at'] : tr.wfEndAfterStart;
  }

  String? validateOccurrences(String? v) {
    if (!isAccompaniment) return null;
    final n = int.tryParse(v?.trim() ?? '');
    return (n == null || n < 1 || n > 52) ? tr.wfRangeError(1, 52) : null;
  }

  String? validateInterval(String? v) {
    if (!isAccompaniment) return null;
    final n = int.tryParse(v?.trim() ?? '');
    return (n == null || n < 1 || n > 365) ? tr.wfRangeError(1, 365) : null;
  }

  String? validateResourceUrl(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return serverErrors['resource_url'];
    final uri = Uri.tryParse(value);
    final ok =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return ok ? serverErrors['resource_url'] : tr.wfUrlInvalid;
  }

  /// Dates of every session of the series (one entry for a single session),
  /// shown before saving so the employee sees what will be booked.
  List<DateTime> get plannedStarts {
    final s = startsAt;
    if (s == null) return const [];
    if (!isAccompaniment) return [s];
    final n = occurrenceCount.clamp(0, 52);
    final step = intervalDays;
    if (n < 1 || step < 1) return [s];
    return [
      for (var i = 0; i < n; i++)
        DateTime(s.year, s.month, s.day + i * step, s.hour, s.minute),
    ];
  }

  bool get isValid =>
      customer.value != null &&
      type.value != null &&
      startsAt != null &&
      startError == null &&
      endError == null &&
      validateOccurrences(occurrences.text) == null &&
      validateInterval(interval.text) == null &&
      validateResourceUrl(resourceUrl.text) == null;

  SchedulePayload buildPayload() => SchedulePayload(
    prospectId: customer.value!.id,
    appointmentTypeId: type.value!.id,
    startsAt: startsAt!,
    endsAt: endsAt,
    productId: productId.value,
    assignedEmployee: employee.value,
    internalNotes: notes.text,
    sendWhatsapp: sendWhatsapp.value,
    resourceUrl: resourceUrl.text,
    occurrences: isAccompaniment ? occurrenceCount : null,
    intervalDays: isAccompaniment ? intervalDays : null,
  );

  Future<ScheduleResult?> submit() async {
    if (isSubmitting.value) return null;
    showValidation.value = true;
    serverErrors.clear();
    errorMessage.value = null;
    conflicts.clear();
    if (!isValid) {
      errorMessage.value = tr.validFixFields;
      return null;
    }
    isSubmitting.value = true;
    try {
      return await _repository.schedule(buildPayload());
    } on ConflictException catch (e) {
      if (e.isScheduleConflict) {
        conflicts.assignAll(ScheduleConflict.listFrom(e.details));
        errorMessage.value = tr.wfConflictNothingSaved;
      } else {
        errorMessage.value = e.message;
      }
      return null;
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k.split('.').first] = m.first;
      });
      errorMessage.value = e.describeFor(const {
        'prospect_id',
        'appointment_type_id',
        'starts_at',
        'ends_at',
        'resource_url',
        'occurrences',
        'interval_days',
      });
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
    notes.dispose();
    resourceUrl.dispose();
    occurrences.dispose();
    interval.dispose();
    super.onClose();
  }
}
