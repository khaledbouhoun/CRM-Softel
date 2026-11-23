import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/workflow_lookup_service.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/whatsapp_launcher.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../data/models/appointment.dart';
import '../controllers/appointment_action_controller.dart';

import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/animated_entrance.dart';
/// What a decision dialog resolved with. [stale] means the server state
/// changed under the employee (an expired hold): reload the list even though
/// nothing was saved.
class AppointmentActionResult {
  const AppointmentActionResult({this.appointment, this.stale = false});

  final Appointment? appointment;
  final bool stale;

  bool get changed => appointment != null || stale;
}

/// Opens the decision dialog of [kind] for [appointment].
Future<AppointmentActionResult> showAppointmentActionDialog({
  required AppointmentActionKind kind,
  required Appointment appointment,
}) async {
  final workflow = Get.find<WorkflowLookupService>();
  try {
    await workflow.ensureLoaded();
  } catch (_) {
    // Employee names are optional helpers.
  }
  final result =
      await showControllerDialog<
        AppointmentActionController,
        AppointmentActionResult
      >(
        controller: AppointmentActionController(
          repository: Get.find(),
          kind: kind,
          appointment: appointment,
        ),
        builder: (c) => _ActionDialog(c),
      );
  return result ?? const AppointmentActionResult();
}

class _ActionDialog extends StatelessWidget {
  const _ActionDialog(this.c);

  final AppointmentActionController c;

  Future<void> _submit() async {
    final saved = await c.submit();
    if (saved != null) {
      Get.back(result: AppointmentActionResult(appointment: saved));
    }
  }

  String get _title => switch (c.kind) {
    AppointmentActionKind.confirm => tr.wfConfirmHoldTitle,
    AppointmentActionKind.reject => tr.wfRejectTitle,
    AppointmentActionKind.cancel => tr.wfCancelAppointmentTitle,
    AppointmentActionKind.propose => tr.wfProposeTitle,
    AppointmentActionKind.reschedule => tr.wfRescheduleTitle,
    AppointmentActionKind.complete => tr.wfRecordOutcomeTitle,
  };

  String get _submitLabel => switch (c.kind) {
    AppointmentActionKind.confirm => tr.actionConfirm,
    AppointmentActionKind.reject => tr.wfReject,
    AppointmentActionKind.cancel => tr.wfCancelAppointment,
    AppointmentActionKind.propose => tr.wfSendProposal,
    AppointmentActionKind.reschedule => tr.actionSave,
    AppointmentActionKind.complete => tr.wfRecordOutcome,
  };

  @override
  Widget build(BuildContext context) {
    final workflow = Get.find<WorkflowLookupService>();
    final a = c.appointment;
    return Obx(
      () => FormDialog(
        title: _title,
        icon: HugeIcons.strokeRoundedCalendar02,
        busy: c.isSubmitting.value,
        errorMessage: c.errorMessage.value,
        submitLabel: _submitLabel,
        submitEnabled: !c.holdExpired.value,
        onCancel: () => Get.back(
          result: AppointmentActionResult(stale: c.holdExpired.value),
        ),
        onSubmit: _submit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Summary(a),
            const SizedBox(height: 14),
            if (c.kind == AppointmentActionKind.confirm) ...[
              TextFormField(
                controller: c.meetingUrl,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: tr.wfMeetingLink,
                  helperText: tr.wfMeetingLinkHint,
                  errorText: c.validateUrl(c.meetingUrl.text),
                ),
                onChanged: (_) => c.serverErrors.remove('meeting_url'),
              ),
              const SizedBox(height: 14),
              EmployeeDropdown(
                value: c.employee.value,
                names: workflow.employeeNames,
                onChanged: (v) => c.employee.value = v,
              ),
              const SizedBox(height: 14),
            ],
            if (c.kind == AppointmentActionKind.propose) ...[
              DateTimeField(
                label: tr.wfNewTime,
                value: c.startsAt.value,
                errorText: c.startsAt.value == null ? null : c.startError,
                onChanged: (v) {
                  if (v != null) c.setStart(v);
                },
              ),
              const SizedBox(height: 14),
            ],
            if (c.kind == AppointmentActionKind.reschedule) ...[
              FormRow(
                children: [
                  DateTimeField(
                    label: tr.wfStarts,
                    value: c.startsAt.value,
                    errorText: c.startError,
                    onChanged: (v) {
                      if (v != null) c.setStart(v);
                    },
                  ),
                  DateTimeField(
                    label: tr.wfEnds,
                    value: c.endsAt.value,
                    errorText: c.endError,
                    onChanged: (v) => c.endsAt.value = v,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              EmployeeDropdown(
                value: c.employee.value,
                names: workflow.employeeNames,
                onChanged: (v) => c.employee.value = v,
              ),
            ],
            if (c.usesText) ...[
              TextField(
                controller: c.text,
                minLines: c.kind == AppointmentActionKind.complete ? 4 : 2,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: switch (c.kind) {
                    AppointmentActionKind.complete => tr.wfOutcome,
                    AppointmentActionKind.reject ||
                    AppointmentActionKind.cancel => tr.wfReasonVisible,
                    _ => tr.wfMessageVisible,
                  },
                  helperText: switch (c.kind) {
                    AppointmentActionKind.complete => tr.wfOutcomeHint,
                    _ => tr.wfCustomerVisibleHint,
                  },
                  helperMaxLines: 2,
                  alignLabelWithHint: true,
                  errorText: c.kind == AppointmentActionKind.complete
                      ? c.serverErrors['outcome']
                      : null,
                ),
                onChanged: (_) => c.serverErrors.remove('outcome'),
              ),
            ],
            if (c.conflicts.isNotEmpty) ...[
              const SizedBox(height: 12),
              ConflictList(conflicts: c.conflicts.toList()),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header recap of the appointment a dialog acts on.
class _Summary extends StatelessWidget {
  const _Summary(this.a);

  final Appointment a;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHigh.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(a.prospect.name, style: context.text.titleSmall),
        const SizedBox(height: 2),
        Text(
          joinNonEmpty([
            a.type.name,
            a.product?.name,
            '${Formatters.dateTime(a.startsAt)} – ${Formatters.time(a.endsAt)}',
          ]),
          style: context.text.bodySmall,
        ),
      ],
    ),
  );
}

/// Full detail of an appointment with the actions allowed in its state.
/// Resolves with true when something changed (the caller reloads).
Future<bool> showAppointmentDetailDialog(Appointment appointment) async {
  final changed = await showAppDialog<bool>(
    _DetailDialog(appointment),
    barrierDismissible: true,
  );
  return changed ?? false;
}

class _DetailDialog extends StatelessWidget {
  const _DetailDialog(this.a);

  final Appointment a;

  Future<void> _run(AppointmentActionKind kind) async {
    final result = await showAppointmentActionDialog(
      kind: kind,
      appointment: a,
    );
    if (result.changed) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (a.isAwaitingDecision) ...[
        FilledButton.icon(
          onPressed: () => _run(AppointmentActionKind.confirm),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedTick02, size: 18),
          label: Text(tr.actionConfirm),
        ),
        OutlinedButton.icon(
          onPressed: () => _run(AppointmentActionKind.propose),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeftRight, size: 18),
          label: Text(tr.wfProposeOther),
        ),
        OutlinedButton.icon(
          onPressed: () => _run(AppointmentActionKind.reject),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel02, size: 18),
          label: Text(tr.wfReject),
        ),
      ],
      if (a.status == AppointmentStatus.held && a.isHoldExpired)
        Chip(label: Text(tr.wfHoldExpiredChip)),
      if (a.status == AppointmentStatus.confirmed) ...[
        if (a.canComplete)
          FilledButton.icon(
            onPressed: () => _run(AppointmentActionKind.complete),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01, size: 18),
            label: Text(tr.wfRecordOutcome),
          ),
        if (!a.type.isDemo)
          OutlinedButton.icon(
            onPressed: () => _run(AppointmentActionKind.reschedule),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendarAdd01, size: 18),
            label: Text(tr.wfReschedule),
          ),
      ],
      if (a.canCancel && a.status != AppointmentStatus.held)
        OutlinedButton.icon(
          onPressed: () => _run(AppointmentActionKind.cancel),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendarRemove02, size: 18),
          label: Text(tr.wfCancelAppointment),
        ),
      if (a.whatsapp != null) OpenWhatsAppButton(link: a.whatsapp!),
    ];
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(a.displayTitle, style: context.text.titleLarge),
                  ),
                  AppointmentStatusBadge(status: a.status),
                  IconButton(
                    tooltip: tr.actionClose,
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01),
                    onPressed: () => Get.back(result: false),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InfoRow(label: tr.fieldCompany, value: a.prospect.name),
              InfoRow(label: tr.fieldContact, value: a.prospect.contactPerson),
              InfoRow(label: tr.fieldPhone, value: a.prospect.phone),
              InfoRow(label: tr.fieldProduct, value: a.product?.name),
              InfoRow(
                label: tr.wfWhen,
                value:
                    '${Formatters.dateTime(a.startsAt)} – ${Formatters.time(a.endsAt)}',
              ),
              InfoRow(label: tr.wfAssignedTo, value: a.assignedEmployee),
              InfoRow(label: tr.wfMeetingLink, value: a.meetingUrl),
              if (a.holdExpiresAt != null)
                InfoRow(
                  label: tr.wfHoldExpires,
                  child: HoldCountdown(expiresAt: a.holdExpiresAt),
                ),
              if (a.customerMessage != null)
                InfoRow(label: tr.wfCustomerMessage, value: a.customerMessage),
              if (a.internalNotes != null)
                InfoRow(label: tr.wfInternalNotes, value: a.internalNotes),
              if (a.outcome != null)
                InfoRow(label: tr.wfOutcome, value: a.outcome),
              if (a.activityId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: StatusBadge(
                    label: tr.wfActivityRecorded,
                    color: context.crm.success,
                    icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                  ),
                ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 18),
                Wrap(spacing: 8, runSpacing: 8, children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens ONLY the prefilled `wa.me` link built by the CRM. The employee
/// still has to press send in WhatsApp, so the UI never says "sent".
class OpenWhatsAppButton extends StatelessWidget {
  const OpenWhatsAppButton({
    super.key,
    required this.link,
    this.compact = false,
  });

  final WhatsAppLink link;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = tr.wfOpenWhatsApp;
    return Tooltip(
      message: tr.wfWhatsAppHint,
      child: compact
          ? IconButton(
              tooltip: label,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedMessage01, size: 20),
              onPressed: () => WhatsAppLauncher.launchPrefilledLink(link.url),
            )
          : OutlinedButton.icon(
              onPressed: () => WhatsAppLauncher.launchPrefilledLink(link.url),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedMessage01, size: 18),
              label: Text(label),
            ),
    );
  }
}
