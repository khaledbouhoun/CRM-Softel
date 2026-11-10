import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../activities/presentation/dialogs/activity_form_dialog.dart';
import '../../../prospects/data/models/prospect_ref.dart';
import '../../../prospects/presentation/widgets/prospect_picker_field.dart';
import '../../data/models/follow_up.dart';
import '../../domain/follow_ups_repository.dart';
import '../controllers/follow_up_form_controllers.dart';

/// Create ([existing] null) or edit a pending follow-up.
Future<FollowUp?> showFollowUpFormDialog({ProspectRef? prospect, FollowUp? existing}) async {
  final saved = await showControllerDialog<FollowUpFormController, FollowUp>(
    controller: FollowUpFormController(repository: Get.find(), prospect: prospect, existing: existing),
    builder: (c) => _FollowUpFormDialog(c),
  );
  if (saved != null) {
    AppFeedback.success(existing == null ? tr.followUpScheduled : tr.followUpUpdated);
  }
  return saved;
}

Future<FollowUp?> showCompleteFollowUpDialog(FollowUp followUp) async {
  final done = await showControllerDialog<CompleteFollowUpController, FollowUpCompletion>(
    controller: CompleteFollowUpController(repository: Get.find(), followUp: followUp),
    builder: (c) => _CompleteFollowUpDialog(c),
  );
  if (done == null) return null;
  AppFeedback.success(done.activityRecorded ? tr.followUpCompletedWithActivity : tr.followUpCompleted);
  return done.followUp;
}

Future<FollowUp?> showCancelFollowUpDialog(FollowUp followUp) async {
  final cancelled = await showControllerDialog<CancelFollowUpController, FollowUp>(
    controller: CancelFollowUpController(repository: Get.find(), followUp: followUp),
    builder: (c) => _CancelFollowUpDialog(c),
  );
  if (cancelled != null) AppFeedback.success(tr.followUpCancelled);
  return cancelled;
}

class _FollowUpFormDialog extends StatelessWidget {
  const _FollowUpFormDialog(this.c);

  final FollowUpFormController c;

  Future<void> _submit() async {
    final saved = await c.submit();
    if (saved != null) Get.back(result: saved);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: c.isEdit ? tr.editFollowUp : tr.scheduleFollowUp,
      icon: Icons.event_available_outlined,
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
              errorText: c.prospectError,
              onChanged: (p) => c.prospect.value = p,
            ),
            const SizedBox(height: 14),
            Text(tr.followUpTypeLabel, style: context.text.labelLarge),
            const SizedBox(height: 6),
            ActivityTypeSelector(value: c.type.value, errorText: c.typeError, onChanged: (t) => c.type.value = t),
            const SizedBox(height: 14),
            DateTimeField(
              label: tr.fieldDateTimeRequired,
              value: c.dueAt.value,
              errorText: c.dueAtError,
              onChanged: (d) => c.dueAt.value = d,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final (label, days) in [
                  (tr.quickTomorrow, 1),
                  (tr.quickIn3Days, 3),
                  (tr.quickIn1Week, 7),
                  (tr.quickIn2Weeks, 14),
                ])
                  ActionChip(
                    label: Text(label),
                    onPressed: () {
                      final now = DateTime.now();
                      c.dueAt.value = DateTime(now.year, now.month, now.day + days, 9);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: c.description,
              minLines: 2,
              maxLines: 5,
              autofocus: true,
              decoration: InputDecoration(
                labelText: tr.fieldDescriptionRequired,
                hintText: tr.followUpDescriptionHint,
                alignLabelWithHint: true,
              ),
              validator: c.validateDescription,
            ),
          ],
        ),
      ),
    ),
  );
}

class _CompleteFollowUpDialog extends StatelessWidget {
  const _CompleteFollowUpDialog(this.c);

  final CompleteFollowUpController c;

  Future<void> _submit() async {
    final done = await c.submit();
    if (done != null) Get.back(result: done);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: tr.completeFollowUpTitle,
      icon: Icons.task_alt,
      width: 640,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      submitLabel: tr.finishFollowUp,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.followUp.prospect?.companyName ?? '', style: context.text.titleSmall),
                  Text(tr.dueOn(Formatters.dateTime(c.followUp.dueAt)), style: context.text.bodySmall),
                  if (c.followUp.description != null) ...[
                    const SizedBox(height: 4),
                    Text(c.followUp.description!, style: context.text.bodyMedium),
                  ],
                ],
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: c.recordActivity.value,
              onChanged: (v) => c.recordActivity.value = v,
              title: Text(tr.recordOutcomeAsActivity),
              subtitle: Text(tr.recommendedKeepsHistory),
            ),
            if (c.recordActivity.value) ...[
              ActivityTypeSelector(value: c.type.value, onChanged: (t) => c.type.value = t),
              const SizedBox(height: 14),
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
                controller: c.description,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(labelText: tr.fieldDescriptionRequired, alignLabelWithHint: true),
                validator: c.validateDescription,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: c.outcome,
                decoration: InputDecoration(labelText: tr.fieldOutcome, hintText: tr.completeOutcomeHint),
                validator: c.validateOutcome,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _CancelFollowUpDialog extends StatelessWidget {
  const _CancelFollowUpDialog(this.c);

  final CancelFollowUpController c;

  Future<void> _submit() async {
    final cancelled = await c.submit();
    if (cancelled != null) Get.back(result: cancelled);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: tr.cancelFollowUp,
      icon: Icons.event_busy_outlined,
      width: 480,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      submitLabel: tr.cancelFollowUp,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr.companyDueOn(c.followUp.prospect?.companyName ?? '', Formatters.dateTime(c.followUp.dueAt)),
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: c.reason,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: tr.reasonOptional, alignLabelWithHint: true),
          ),
        ],
      ),
    ),
  );
}
