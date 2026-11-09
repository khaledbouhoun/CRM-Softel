import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../follow_ups/data/models/follow_up.dart';
import '../../../follow_ups/domain/follow_ups_repository.dart';
import '../../../prospects/data/models/prospect_ref.dart';
import '../../data/models/activity.dart';
import '../../data/models/activity_type.dart';
import '../../domain/activities_repository.dart';

/// Outcome of saving an activity. The activity is saved even when the
/// optional follow-up could not be scheduled; [followUpError] says so.
class ActivityFormResult {
  const ActivityFormResult({
    required this.activity,
    this.followUp,
    this.followUpError,
  });

  final Activity activity;
  final FollowUp? followUp;
  final ApiException? followUpError;
}

/// Creates an activity on its own. The prospect is optional: an activity
/// created without one can be linked to a prospect afterwards.
class ActivityFormController extends GetxController {
  ActivityFormController({
    required ActivitiesRepository activitiesRepository,
    required FollowUpsRepository followUpsRepository,
    ProspectRef? prospect,
    DateTime Function()? clock,
  }) : _activities = activitiesRepository,
       _followUps = followUpsRepository,
       prospectLocked = prospect != null,
       _clock = clock ?? DateTime.now {
    this.prospect.value = prospect;
    final now = _clock();
    occurredAt.value = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
  }

  final ActivitiesRepository _activities;
  final FollowUpsRepository _followUps;
  final DateTime Function() _clock;

  /// True when opened from a prospect page (prospect cannot be changed).
  final bool prospectLocked;

  final formKey = GlobalKey<FormState>();
  final prospect = Rxn<ProspectRef>();
  final type = ActivityType.call.obs;
  final occurredAt = Rx<DateTime>(DateTime.now());
  final title = TextEditingController();
  final description = TextEditingController();
  final outcome = TextEditingController();
  final nextFollowUpAt = Rxn<DateTime>();

  /// Also create a pending follow-up at [nextFollowUpAt] (needs a prospect).
  final scheduleFollowUp = true.obs;
  final followUpDescription = TextEditingController();

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;
  final showValidation = false.obs;

  String? validateTitle(String? v) =>
      serverErrors['title'] ??
      Validators.combine([
        () => Validators.required(v, field: tr.validFieldTitle),
        () => Validators.minLength(v, 2),
        () => Validators.maxLength(v, 200),
      ]);

  String? validateDescription(String? v) =>
      serverErrors['description'] ?? Validators.maxLength(v, 5000);

  String? validateOutcome(String? v) =>
      serverErrors['outcome'] ?? Validators.maxLength(v, 5000);

  /// Server fields shown next to an input; other server errors go to
  /// [errorMessage].
  static const displayedFields = {
    'title',
    'description',
    'outcome',
    'activity_at',
  };

  String? get occurredAtError {
    if (serverErrors['activity_at'] != null) return serverErrors['activity_at'];
    if (occurredAt.value.isAfter(_clock().add(const Duration(minutes: 5)))) {
      return tr.validActivityNotFuture;
    }
    return null;
  }

  /// Client-side only: the follow-up is created by a separate request.
  String? get nextFollowUpError {
    final next = nextFollowUpAt.value;
    if (next == null) return null;
    if (!next.isAfter(occurredAt.value)) {
      return tr.validNextFollowUpAfterActivity;
    }
    if (next.isBefore(_clock())) {
      return tr.validNextFollowUpFuture;
    }
    return null;
  }

  Map<String, String> validateAll() {
    final errors = <String, String>{};
    final t = validateTitle(title.text);
    if (t != null) errors['title'] = t;
    final desc = validateDescription(description.text);
    if (desc != null) errors['description'] = desc;
    final out = validateOutcome(outcome.text);
    if (out != null) errors['outcome'] = out;
    if (occurredAtError != null) errors['activity_at'] = occurredAtError!;
    if (prospect.value != null && nextFollowUpError != null) {
      errors['next_follow_up_at'] = nextFollowUpError!;
    }
    return errors;
  }

  ActivityPayload buildPayload() => ActivityPayload(
    prospectId: prospect.value?.id,
    type: type.value,
    occurredAt: occurredAt.value,
    title: title.text,
    description: description.text,
    outcome: outcome.text,
  );

  String _defaultFollowUpDescription() => tr.followUpAfterActivity(
    type.value.label.toLowerCase(),
    Formatters.date(occurredAt.value),
  );

  Future<ActivityFormResult?> submit() async {
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
      final activity = await _activities.createActivity(buildPayload());

      FollowUp? followUp;
      ApiException? followUpError;
      final next = nextFollowUpAt.value;
      final linkedProspect = prospect.value;
      if (linkedProspect != null && next != null && scheduleFollowUp.value) {
        try {
          final text = followUpDescription.text.trim();
          followUp = await _followUps.createFollowUp(
            FollowUpPayload(
              prospectId: linkedProspect.id,
              dueAt: next,
              description: text.isEmpty ? _defaultFollowUpDescription() : text,
              activityType: type.value.canonical,
            ),
          );
        } catch (e) {
          followUpError = ApiException.from(e);
        }
      }
      return ActivityFormResult(
        activity: activity,
        followUp: followUp,
        followUpError: followUpError,
      );
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((key, messages) {
        if (messages.isNotEmpty) {
          serverErrors[key.split('.').first] = messages.first;
        }
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
    title.dispose();
    description.dispose();
    outcome.dispose();
    followUpDescription.dispose();
    super.onClose();
  }
}
