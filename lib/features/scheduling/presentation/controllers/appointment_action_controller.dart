import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/models/appointment.dart';
import '../../domain/scheduling_repository.dart';

enum AppointmentActionKind {
  confirm,
  reject,
  cancel,
  propose,
  reschedule,
  complete,
}

/// One controller for the single-appointment decisions an employee makes:
/// confirm a hold, reject / cancel (releases the slot), propose another time,
/// reschedule and record the outcome. The server is the only judge of
/// availability: `410 HOLD_EXPIRED` and `409` conflicts are surfaced, never
/// guessed.
class AppointmentActionController extends GetxController {
  AppointmentActionController({
    required SchedulingRepository repository,
    required this.kind,
    required this.appointment,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now {
    meetingUrl.text = appointment.meetingUrl ?? '';
    employee.value = appointment.assignedEmployee;
    startsAt.value = appointment.startsAt;
    endsAt.value = appointment.endsAt;
    if (kind == AppointmentActionKind.propose) {
      // Never prefill the slot being replaced.
      startsAt.value = null;
    }
  }

  final SchedulingRepository _repository;
  final DateTime Function() _clock;
  final AppointmentActionKind kind;
  final Appointment appointment;

  /// Meeting link (confirm).
  final meetingUrl = TextEditingController();

  /// Customer message (confirm / propose), customer-visible reason
  /// (reject / cancel) or the recorded outcome (complete).
  final text = TextEditingController();
  final employee = RxnString();
  final startsAt = Rxn<DateTime>();
  final endsAt = Rxn<DateTime>();

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;

  /// The hold ran out before the employee decided (`410 HOLD_EXPIRED`): the
  /// slot is gone and the caller must refresh its list.
  final holdExpired = false.obs;

  /// Occurrences refused by a `409 APPOINTMENT_CONFLICT`.
  final conflicts = <ScheduleConflict>[].obs;

  bool get usesText => kind != AppointmentActionKind.reschedule;

  /// Moves the start and keeps the session length.
  void setStart(DateTime value) {
    final oldStart = startsAt.value;
    final oldEnd = endsAt.value;
    startsAt.value = value;
    if (oldStart != null && oldEnd != null && oldEnd.isAfter(oldStart)) {
      endsAt.value = value.add(oldEnd.difference(oldStart));
    } else if (kind == AppointmentActionKind.reschedule) {
      endsAt.value = value.add(const Duration(hours: 1));
    }
  }

  String? validateUrl(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return serverErrors['meeting_url'];
    final uri = Uri.tryParse(value);
    final ok =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return ok ? serverErrors['meeting_url'] : tr.wfUrlInvalid;
  }

  String? get outcomeError {
    if (kind != AppointmentActionKind.complete) return null;
    return text.text.trim().isEmpty
        ? (serverErrors['outcome'] ?? tr.wfOutcomeRequired)
        : serverErrors['outcome'];
  }

  String? get startError {
    if (kind != AppointmentActionKind.propose &&
        kind != AppointmentActionKind.reschedule) {
      return null;
    }
    final s = startsAt.value;
    if (s == null) return serverErrors['starts_at'] ?? tr.validDateRequired;
    if (s.isBefore(_clock())) return tr.wfStartInPast;
    return serverErrors['starts_at'];
  }

  String? get endError {
    if (kind != AppointmentActionKind.reschedule) return null;
    final s = startsAt.value;
    final e = endsAt.value;
    if (e == null) return tr.validDateRequired;
    if (s != null && !e.isAfter(s)) return tr.wfEndAfterStart;
    return serverErrors['ends_at'];
  }

  bool get isValid {
    switch (kind) {
      case AppointmentActionKind.complete:
        return text.text.trim().isNotEmpty;
      case AppointmentActionKind.propose:
        return startError == null;
      case AppointmentActionKind.reschedule:
        return startError == null && endError == null;
      case AppointmentActionKind.confirm:
        return validateUrl(meetingUrl.text) == null;
      case AppointmentActionKind.reject:
      case AppointmentActionKind.cancel:
        return true;
    }
  }

  Future<Appointment?> submit() async {
    if (isSubmitting.value) return null;
    serverErrors.clear();
    errorMessage.value = null;
    conflicts.clear();
    if (!isValid) {
      errorMessage.value = tr.validFixFields;
      return null;
    }
    isSubmitting.value = true;
    try {
      final id = appointment.id;
      return switch (kind) {
        AppointmentActionKind.confirm => await _repository.confirm(
          id,
          meetingUrl: meetingUrl.text,
          assignedEmployee: employee.value,
          message: text.text,
        ),
        AppointmentActionKind.reject => await _repository.reject(
          id,
          reason: text.text,
        ),
        AppointmentActionKind.cancel => await _repository.cancel(
          id,
          reason: text.text,
        ),
        AppointmentActionKind.propose => await _repository.propose(
          id,
          startsAt.value!,
          message: text.text,
        ),
        AppointmentActionKind.reschedule => await _repository.reschedule(
          id,
          startsAt.value!,
          endsAt.value!,
          assignedEmployee: employee.value,
        ),
        AppointmentActionKind.complete => await _repository.complete(
          id,
          text.text,
        ),
      };
    } on GoneException catch (e) {
      holdExpired.value = e.isHoldExpired || e.statusCode == 410;
      errorMessage.value = holdExpired.value ? tr.wfHoldExpired : e.message;
      return null;
    } on ConflictException catch (e) {
      if (e.isScheduleConflict) {
        conflicts.assignAll(ScheduleConflict.listFrom(e.details));
        errorMessage.value = tr.wfConflictNothingSaved;
      } else {
        // SLOT_UNAVAILABLE and other refusals carry their own message.
        errorMessage.value = e.message;
      }
      return null;
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k.split('.').first] = m.first;
      });
      errorMessage.value = e.describeFor(const {
        'meeting_url',
        'starts_at',
        'ends_at',
        'outcome',
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
    meetingUrl.dispose();
    text.dispose();
    super.onClose();
  }
}
