# -*- coding: utf-8 -*-
"""Follow-up (relance) type and the atomic completion flow."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import edit  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CTRL = 'lib/features/follow_ups/presentation/controllers/follow_up_form_controllers.dart'
DLG = 'lib/features/follow_ups/presentation/dialogs/follow_up_dialogs.dart'

# ---------------------------------------------------------------- form controller: type
edit(CTRL, "    description.text = existing?.description ?? '';\n  }",
     "    description.text = existing?.description ?? '';\n"
     "    // New follow-ups default to a call; older ones without a type stay empty\n"
     "    // until the user picks one.\n"
     "    type.value = existing == null ? ActivityType.call : existing!.activityType;\n  }")
edit(CTRL, "  final dueAt = Rxn<DateTime>();\n  final description = TextEditingController();\n\n  final isSubmitting",
     "  final dueAt = Rxn<DateTime>();\n  final description = TextEditingController();\n\n"
     "  /// Planned kind (call, appointment, message); copied to the activity the\n"
     "  /// follow-up becomes.\n"
     "  final type = Rxn<ActivityType>();\n\n  final isSubmitting")
edit(CTRL, "  String? get prospectError {",
     "  String? get typeError => showValidation.value && type.value == null ? tr.followUpTypeRequired : null;\n\n"
     "  String? get prospectError {")
edit(CTRL, "    final desc = validateDescription(description.text);\n    if (desc != null) errors['description'] = desc;\n    return errors;\n  }\n\n  Future<FollowUp?> submit() async {",
     "    final desc = validateDescription(description.text);\n    if (desc != null) errors['description'] = desc;\n"
     "    if (type.value == null) errors['activity_type'] = tr.followUpTypeRequired;\n    return errors;\n  }\n\n  Future<FollowUp?> submit() async {")
edit(CTRL, "FollowUpPayload(prospectId: prospect.value!.id, dueAt: dueAt.value!, description: description.text);",
     "FollowUpPayload(\n        prospectId: prospect.value!.id,\n        dueAt: dueAt.value!,\n        description: description.text,\n        activityType: type.value,\n      );")
edit(CTRL, "static const displayedFields = {'description', 'title', 'scheduled_at'};",
     "static const displayedFields = {'description', 'title', 'scheduled_at', 'activity_type'};")

# ---------------------------------------------------------------- completion controller
src = open(os.path.join(ROOT, CTRL), encoding='utf-8').read()
start = src.index('/// Completes a follow-up and optionally records the result as an activity.')
end = src.index('/// Cancels a pending follow-up with an optional reason.')
new_class = '''/// Completes a follow-up and optionally records the exchange as an activity.
///
/// One request: the server completes the follow-up and creates the activity
/// in the same transaction. The activity takes the follow-up's type and
/// prospect, and a follow-up can never produce two activities.
class CompleteFollowUpController extends GetxController {
  CompleteFollowUpController({required FollowUpsRepository repository, required this.followUp, DateTime Function()? clock})
    : _repository = repository,
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
        Validators.combine([() => Validators.required(v, field: tr.validFieldDescription), () => Validators.maxLength(v, 5000)]);
  }

  String? validateOutcome(String? v) => recordActivity.value ? Validators.maxLength(v, 2000) : null;

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
      errorMessage.value = [e.message, ...e.allMessages].join('\\n');
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

'''
open(os.path.join(ROOT, CTRL), 'w', encoding='utf-8', newline='\n').write(src[:start] + new_class + src[end:])

# ---------------------------------------------------------------- dialogs
edit(DLG, """  final activityError = done.activityError;
  if (activityError == null) {
    AppFeedback.success(tr.followUpCompleted);
  } else {
    AppFeedback.warning(
      tr.followUpCompletedActivityFailed(activityError.message),
    );
  }
  return done.followUp;""", """  AppFeedback.success(done.activityRecorded ? tr.followUpCompletedWithActivity : tr.followUpCompleted);
  return done.followUp;""")

edit(DLG, """            const SizedBox(height: 14),
            DateTimeField(
              label: tr.fieldDateTimeRequired,
              value: c.dueAt.value,""", """            const SizedBox(height: 14),
            Text(tr.followUpTypeLabel, style: context.text.labelLarge),
            const SizedBox(height: 6),
            ActivityTypeSelector(
              value: c.type.value,
              errorText: c.typeError,
              onChanged: (t) => c.type.value = t,
            ),
            const SizedBox(height: 14),
            DateTimeField(
              label: tr.fieldDateTimeRequired,
              value: c.dueAt.value,""")
edit(DLG, """            if (c.recordActivity.value) ...[
              ActivityTypeSelector(value: c.type.value, onChanged: (t) => c.type.value = t),
              const SizedBox(height: 14),""", """            if (c.recordActivity.value) ...[
              if (c.typeComesFromFollowUp)
                Row(
                  children: [
                    ActivityTypeAvatar(c.activityType, size: 26),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr.followUpCompletedKeepsType(c.activityType.label),
                        style: context.text.bodyMedium,
                      ),
                    ),
                  ],
                )
              else ...[
                Text(tr.activityTypeForLegacy, style: context.text.bodySmall),
                const SizedBox(height: 6),
                ActivityTypeSelector(
                  value: c.fallbackType.value,
                  onChanged: (t) => c.fallbackType.value = t,
                ),
              ],
              const SizedBox(height: 14),""")
edit(DLG, "import '../../../activities/presentation/dialogs/activity_form_dialog.dart';",
     "import '../../../activities/presentation/dialogs/activity_form_dialog.dart';\nimport '../../../activities/presentation/widgets/activity_widgets.dart';")
print('ctrl2 ok')
