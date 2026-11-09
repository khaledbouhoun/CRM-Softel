import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/validators.dart';
import '../../../activities/data/models/activity_type.dart';
import '../../../prospects/data/models/prospect_ref.dart';
import '../../data/models/follow_up.dart';
import '../../domain/follow_ups_repository.dart';
import '../../../../app/l10n/l10n.dart';

/// First message per field. The follow-up form edits one text that the API
/// splits into `title` / `description`, so both map to `description`.
Map<String, String> _firstErrors(ValidationException e) {
  final mapped = <String, String>{};
  e.fieldErrors.forEach((key, messages) {
    if (messages.isEmpty) return;
    var field = key.split('.').first;
    if (field == 'title') field = 'description';
    mapped.putIfAbsent(field, () => messages.first);
  });
  return mapped;
}

/// Create or edit (pending only) a follow-up.
class FollowUpFormController extends GetxController {
  FollowUpFormController({
    required FollowUpsRepository repository,
    ProspectRef? prospect,
    this.existing,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now,
       prospectLocked = prospect != null || existing != null {
    this.prospect.value = prospect ?? existing?.prospect;
    final now = _clock();
    dueAt.value =
        existing?.dueAt ?? DateTime(now.year, now.month, now.day + 1, 9);
    description.text = existing?.description ?? '';
    // New follow-ups default to a call; older ones without a type stay empty
    // until the user picks one.
    type.value = existing == null ? ActivityType.call : existing!.activityType;
  }

  final FollowUpsRepository _repository;
  final DateTime Function() _clock;
  final FollowUp? existing;
  final bool prospectLocked;

  bool get isEdit => existing != null;

  final formKey = GlobalKey<FormState>();
  final prospect = Rxn<ProspectRef>();
  final dueAt = Rxn<DateTime>();
  final description = TextEditingController();

  /// Planned kind (call, appointment, message); copied to the activity the
  /// follow-up becomes.
  final type = Rxn<ActivityType>();

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;
  final showValidation = false.obs;

  String? validateDescription(String? v) =>
      serverErrors['description'] ??
      Validators.combine([
        () => Validators.required(v, field: tr.validFieldDescription),
        () => Validators.maxLength(v, 2000),
      ]);

  /// Server fields shown next to an input; other server errors go to
  /// [errorMessage].
  static const displayedFields = {
    'description',
    'title',
    'scheduled_at',
    'activity_type',
  };

  String? get typeError => showValidation.value && type.value == null
      ? tr.followUpTypeRequired
      : null;

  String? get prospectError {
    if (!showValidation.value) return null;
    return prospect.value == null ? tr.validSelectProspect : null;
  }

  String? get dueAtError {
    if (serverErrors['scheduled_at'] != null) {
      return serverErrors['scheduled_at'];
    }
    final due = dueAt.value;
    if (due == null) return showValidation.value ? tr.validDateRequired : null;
    // One minute of tolerance for "now".
    if (due.isBefore(_clock().subtract(const Duration(minutes: 1)))) {
      return tr.validFollowUpFuture;
    }
    return null;
  }

  Map<String, String> validateAll() {
    final errors = <String, String>{};
    if (prospect.value == null) errors['prospect_id'] = tr.validSelectProspect;
    if (dueAt.value == null) {
      errors['scheduled_at'] = tr.validDateRequired;
    } else if (dueAtError != null) {
      errors['scheduled_at'] = dueAtError!;
    }
    final desc = validateDescription(description.text);
    if (desc != null) errors['description'] = desc;
    if (type.value == null) errors['activity_type'] = tr.followUpTypeRequired;
    return errors;
  }

  Future<FollowUp?> submit() async {
    if (isSubmitting.value) return null;
    showValidation.value = true;
    serverErrors.clear();
    errorMessage.value = null;
    final widgetValid = formKey.currentState?.validate() ?? true;
    if (!widgetValid || validateAll().isNotEmpty) {
      errorMessage.value = tr.validFixFields;
      return null;
    }
    isSubmitting.value = true;
    try {
      final payload = FollowUpPayload(
        prospectId: prospect.value!.id,
        dueAt: dueAt.value!,
        description: description.text,
        activityType: type.value,
      );
      return isEdit
          ? await _repository.updateFollowUp(existing!.id, payload)
          : await _repository.createFollowUp(payload);
    } on ValidationException catch (e) {
      serverErrors.assignAll(_firstErrors(e));
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
    description.dispose();
    super.onClose();
  }
}

/// Completes a follow-up and optionally records the exchange as an activity.
///
/// One request: the server completes the follow-up and creates the activity
/// in the same transaction. The activity takes the follow-up's type and
/// prospect, and a follow-up can never produce two activities.
class CompleteFollowUpController extends GetxController {
  CompleteFollowUpController({
    required FollowUpsRepository repository,
    required this.followUp,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now {
    // An exchange cannot be in the future: a follow-up completed ahead of
    // schedule is recorded as happening now.
    final now = _clock();
    final due = followUp.dueAt;
    occurredAt.value = due != null && due.isBefore(now) ? due : now;
    description.text = followUp.description ?? '';
  }

  final FollowUpsRepository _repository;
  final DateTime Function() _clock;
  final FollowUp followUp;

  final formKey = GlobalKey<FormState>();
  final recordActivity = true.obs;

  /// Only used for older follow-ups that have no type of their own.
  final fallbackType = ActivityType.call.obs;
  final occurredAt = Rx<DateTime>(DateTime.now());
  final description = TextEditingController();
  final outcome = TextEditingController();

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;

  /// The activity type: the follow-up's own, else the user's pick.
  ActivityType get activityType => followUp.activityType ?? fallbackType.value;

  bool get typeComesFromFollowUp => followUp.activityType != null;

  String? validateDescription(String? v) {
    if (!recordActivity.value) return null;
    return serverErrors['description'] ??
        Validators.combine([
          () => Validators.required(v, field: tr.validFieldDescription),
          () => Validators.maxLength(v, 5000),
        ]);
  }

  String? validateOutcome(String? v) =>
      recordActivity.value ? Validators.maxLength(v, 2000) : null;

  String? get occurredAtError {
    if (!recordActivity.value) return null;
    if (occurredAt.value.isAfter(_clock().add(const Duration(minutes: 5)))) {
      return tr.validDateNotFuture;
    }
    return null;
  }

  Map<String, String> validateAll() {
    final errors = <String, String>{};
    final desc = validateDescription(description.text);
    if (desc != null) errors['description'] = desc;
    final out = validateOutcome(outcome.text);
    if (out != null) errors['outcome'] = out;
    if (occurredAtError != null) errors['activity_at'] = occurredAtError!;
    return errors;
  }

  CompleteFollowUpRequest buildRequest() => CompleteFollowUpRequest(
    recordActivity: recordActivity.value,
    description: description.text,
    outcome: outcome.text,
    occurredAt: occurredAt.value,
    fallbackType: typeComesFromFollowUp ? null : fallbackType.value,
  );

  Future<FollowUpCompletion?> submit() async {
    if (isSubmitting.value) return null;
    serverErrors.clear();
    errorMessage.value = null;
    final widgetValid = formKey.currentState?.validate() ?? true;
    if (!widgetValid || validateAll().isNotEmpty) {
      errorMessage.value = tr.validFixFields;
      return null;
    }
    isSubmitting.value = true;
    try {
      return await _repository.completeFollowUp(followUp.id, buildRequest());
    } on ValidationException catch (e) {
      serverErrors.assignAll(_firstErrors(e));
      errorMessage.value = [e.message, ...e.allMessages].join('\n');
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
    description.dispose();
    outcome.dispose();
    super.onClose();
  }
}

/// Cancels a pending follow-up with an optional reason.
class CancelFollowUpController extends GetxController {
  CancelFollowUpController({
    required FollowUpsRepository repository,
    required this.followUp,
  }) : _repository = repository;

  final FollowUpsRepository _repository;
  final FollowUp followUp;

  final reason = TextEditingController();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  Future<FollowUp?> submit() async {
    if (isSubmitting.value) return null;
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      return await _repository.cancelFollowUp(followUp.id, reason: reason.text);
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    reason.dispose();
    super.onClose();
  }
}
