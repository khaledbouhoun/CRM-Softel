import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../follow_ups/data/models/follow_up.dart';
import '../../../follow_ups/presentation/dialogs/follow_up_search_dialog.dart';
import '../../../prospects/data/models/prospect_ref.dart';
import '../../../prospects/presentation/widgets/prospect_picker_field.dart';
import '../../data/models/activity_type.dart';
import '../controllers/activity_form_controller.dart';
import '../widgets/activity_widgets.dart';

/// Opens the "new activity" form and shows the outcome. Resolves with the
/// result when the activity was saved.
///
/// An activity can be created linked to a [followUp] (or [prospect]), or on its own
/// to be linked to a follow-up later.
Future<ActivityFormResult?> showActivityFormDialog({ProspectRef? prospect, FollowUp? followUp}) async {
  final result = await showControllerDialog<ActivityFormController, ActivityFormResult>(
    controller: ActivityFormController(
      activitiesRepository: Get.find(),
      followUpsRepository: Get.find(),
      prospect: prospect,
      followUp: followUp,
    ),
    builder: (c) => _ActivityFormDialog(c),
  );
  if (result != null) {
    AppFeedback.success(result.followUp != null ? tr.activitySavedAndFollowUp : tr.activitySaved);
    if (result.followUpError != null) {
      AppFeedback.error(result.followUpError!, prefix: tr.activitySavedFollowUpFailed);
    }
  }
  return result;
}

/// Segmented selector of the types offered for new activities and follow-ups
/// (Call, Meeting, Message, Other).
class ActivityTypeSelector extends StatelessWidget {
  const ActivityTypeSelector({super.key, required this.value, required this.onChanged, this.errorText});

  /// Null shows nothing selected (a follow-up without a type).
  final ActivityType? value;
  final ValueChanged<ActivityType> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SegmentedButton<ActivityType>(
        showSelectedIcon: false,
        emptySelectionAllowed: true,
        segments: [
          for (final t in ActivityType.selectable)
            ButtonSegment(value: t, label: Text(t.label), icon: Icon(activityIcon(t), size: 18)),
        ],
        selected: value == null ? const {} : {value!.canonical},
        onSelectionChanged: (s) {
          if (s.isNotEmpty) onChanged(s.first);
        },
      ),
      if (errorText != null)
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 4, start: 12, end: 12),
          child: Text(errorText!, style: context.text.bodySmall?.copyWith(color: context.colors.error)),
        ),
    ],
  );
}

class _ActivityFormDialog extends StatelessWidget {
  const _ActivityFormDialog(this.c);

  final ActivityFormController c;

  Future<void> _submit() async {
    final result = await c.submit();
    if (result != null) Get.back(result: result);
  }

  Widget _followUpField(BuildContext context) {
    final fu = c.selectedFollowUp.value;
    final prospect = c.prospect.value;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.event_note, color: context.colors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fu != null
                      ? (fu.description?.trim().isNotEmpty == true ? fu.description! : 'Follow-up #${fu.id}')
                      : 'No follow-up linked (optional)',
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: fu != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (fu != null && prospect != null)
                  Text(
                    'Prospect: ${prospect.companyName}',
                    style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (fu != null && !c.followUpLocked)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              tooltip: 'Clear',
              onPressed: () => c.selectFollowUp(null),
            ),
          if (!c.followUpLocked)
            OutlinedButton.icon(
              icon: const Icon(Icons.search, size: 16),
              label: Text(fu == null ? 'Choose follow-up' : 'Change'),
              onPressed: () async {
                final chosen = await showFollowUpSearchDialog(
                  prospectId: prospect?.id,
                  prospectName: prospect?.companyName,
                );
                if (chosen != null) c.selectFollowUp(chosen);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: tr.newActivity,
      icon: Icons.add_comment_outlined,
      width: 680,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProspectPickerField(
              value: c.prospect.value,
              enabled: !c.prospectLocked,
              optional: true,
              excludeStageIds: const [2, 3],
              onChanged: c.selectProspect,
            ),
            const SizedBox(height: 14),
            Text(tr.typeLabelRequired, style: context.text.labelLarge),
            const SizedBox(height: 6),
            ActivityTypeSelector(value: c.type.value, onChanged: (t) => c.type.value = t),
            const SizedBox(height: 16),
            DateTimeField(
              label: tr.fieldDateTimeRequired,
              value: c.occurredAt.value,
              errorText: c.occurredAtError,
              onChanged: (d) {
                if (d != null) c.occurredAt.value = d;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: c.title,
              autofocus: true,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: tr.activityTitleRequired,
                hintText: tr.activityTitleHint,
                counterText: '',
              ),
              validator: c.validateTitle,
              onChanged: (_) => c.serverErrors.remove('title'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: c.description,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: tr.activityDiscussionLabel,
                hintText: tr.activityDescriptionHint,
                alignLabelWithHint: true,
              ),
              validator: c.validateDescription,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: c.outcome,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(labelText: tr.fieldOutcome, hintText: tr.activityOutcomeHint),
              validator: c.validateOutcome,
            ),
            const SizedBox(height: 14),
            _followUpField(context),
            if (c.prospect.value != null) ...[
              const SizedBox(height: 18),
              FormSectionLabel(tr.nextStepsSection),
              DateTimeField(
                label: tr.nextFollowUpOptional,
                value: c.nextFollowUpAt.value,
                clearable: true,
                errorText: c.nextFollowUpError,
                onChanged: (d) => c.nextFollowUpAt.value = d,
              ),
              if (c.nextFollowUpAt.value != null) ...[
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: c.scheduleFollowUp.value,
                  onChanged: (v) => c.scheduleFollowUp.value = v ?? false,
                  title: Text(tr.alsoScheduleFollowUp),
                  subtitle: Text(tr.willAppearInFollowUps),
                ),
                if (c.scheduleFollowUp.value)
                  TextFormField(
                    controller: c.followUpDescription,
                    decoration: InputDecoration(labelText: tr.followUpSubject, hintText: tr.leaveEmptyAuto),
                  ),
              ],
            ],
          ],
        ),
      ),
    ),
  );
}
