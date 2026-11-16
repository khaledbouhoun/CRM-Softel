import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../app/services/workflow_lookup_service.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../../prospects/data/models/prospect_ref.dart';
import '../../../prospects/presentation/widgets/prospect_picker_field.dart';
import '../../data/models/appointment.dart';
import '../../../workflow_settings/domain/workflow_config_repository.dart';
import '../controllers/schedule_session_controller.dart';

export '../controllers/schedule_session_controller.dart' show SessionMode;

/// Schedules a training session or an accompaniment series for a customer.
/// Resolves with the created session(s), or null when cancelled.
Future<ScheduleResult?> showScheduleSessionDialog({
  required SessionMode mode,
  ProspectRef? customer,
}) async {
  final workflow = Get.find<WorkflowLookupService>();
  try {
    await workflow.ensureLoaded();
  } catch (_) {
    // Types / employees may be missing; the dialog reports an empty list.
  }
  return showControllerDialog<ScheduleSessionController, ScheduleResult>(
    controller: ScheduleSessionController(
      repository: Get.find(),
      workflow: workflow,
      // Explicit type: the parameter is nullable.
      configRepository: Get.find<WorkflowConfigRepository>(),
      mode: mode,
      customer: customer,
    ),
    builder: (c) => _SessionDialog(c),
  );
}

class _SessionDialog extends StatelessWidget {
  const _SessionDialog(this.c);

  final ScheduleSessionController c;

  Future<void> _submit() async {
    final result = await c.submit();
    if (result != null) Get.back(result: result);
  }

  Future<void> _pickTime(BuildContext context, bool start) async {
    final initial =
        (start ? c.startTime.value : c.endTime.value) ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (start) {
      c.setStartTime(picked);
    } else {
      c.endTime.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workflow = Get.find<WorkflowLookupService>();
    final lookups = Get.find<LookupService>();
    return Obx(() {
      final types = c.types;
      return FormDialog(
        title: c.isAccompaniment ? tr.wfNewAccompaniment : tr.wfNewTraining,
        icon: c.isAccompaniment
            ? Icons.event_repeat_outlined
            : Icons.school_outlined,
        width: 640,
        busy: c.isSubmitting.value,
        errorMessage: c.errorMessage.value,
        onCancel: () => Get.back(),
        onSubmit: _submit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProspectPickerField(
              value: c.customer.value,
              excludeStageIds: const [],
              errorText: c.customerError,
              onChanged: (v) => c.customer.value = v,
            ),
            const SizedBox(height: 14),
            if (types.isEmpty)
              Text(
                tr.wfNoTypesConfigured,
                style: context.text.bodySmall?.copyWith(
                  color: context.crm.warning,
                ),
              )
            else
              FormRow(
                children: [
                  DropdownButtonFormField(
                    initialValue: c.type.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: tr.wfSessionType,
                      errorText: c.typeError,
                    ),
                    items: [
                      for (final t in types)
                        DropdownMenuItem(value: t, child: Text(t.name)),
                    ],
                    onChanged: (v) {
                      if (v != null) c.selectType(v);
                    },
                  ),
                  DropdownButtonFormField<int?>(
                    initialValue: c.productId.value,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: tr.fieldProduct),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(tr.wfNoProduct),
                      ),
                      for (final p in lookups.activeProducts)
                        DropdownMenuItem<int?>(
                          value: p.id,
                          child: Text(p.name),
                        ),
                    ],
                    onChanged: c.selectProduct,
                  ),
                ],
              ),
            const SizedBox(height: 14),
            FormRow(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: c.date.value ?? now,
                      firstDate: DateTime(now.year, now.month, now.day),
                      lastDate: DateTime(now.year + 3),
                    );
                    if (picked != null) c.date.value = picked;
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: tr.wfDate,
                      prefixIcon: const Icon(Icons.event, size: 20),
                      errorText: c.startError,
                    ),
                    child: Text(Formatters.date(c.date.value)),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _pickTime(context, true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: tr.wfStartTime,
                      prefixIcon: const Icon(Icons.schedule, size: 20),
                    ),
                    child: Text(c.startTime.value?.format(context) ?? '—'),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _pickTime(context, false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: tr.wfEndTime,
                      prefixIcon: const Icon(Icons.schedule, size: 20),
                      errorText: c.endError,
                    ),
                    child: Text(c.endTime.value?.format(context) ?? '—'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            EmployeeDropdown(
              label: tr.wfTrainer,
              value: c.employee.value,
              names: workflow.employeeNames,
              onChanged: (v) => c.employee.value = v,
            ),
            if (c.isAccompaniment) ...[
              const SizedBox(height: 14),
              FormRow(
                children: [
                  TextFormField(
                    controller: c.occurrences,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr.wfOccurrences,
                      helperText: tr.wfOccurrencesHint,
                    ),
                    validator: c.validateOccurrences,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) => c.errorMessage.value = null,
                  ),
                  TextFormField(
                    controller: c.interval,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr.wfIntervalDays,
                      helperText: tr.wfIntervalHint,
                    ),
                    validator: c.validateInterval,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) => c.errorMessage.value = null,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: c.notes,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: tr.wfInternalNotes,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            if (c.resources.isNotEmpty)
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(labelText: tr.wfPickResource),
                items: [
                  for (final r in c.resources)
                    DropdownMenuItem(value: r.url, child: Text(r.title)),
                ],
                onChanged: (v) {
                  if (v != null) c.resourceUrl.text = v;
                },
              ),
            if (c.resources.isNotEmpty) const SizedBox(height: 10),
            TextFormField(
              controller: c.resourceUrl,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: tr.wfResourceLink),
              validator: c.validateResourceUrl,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(tr.wfPrepareWhatsApp),
              subtitle: Text(tr.wfPrepareWhatsAppHint),
              value: c.sendWhatsapp.value,
              onChanged: (v) => c.sendWhatsapp.value = v ?? false,
            ),
            if (c.isAccompaniment && c.plannedStarts.length > 1) ...[
              const SizedBox(height: 8),
              FormSectionLabel(tr.wfPlannedSessions(c.plannedStarts.length)),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (i, d) in c.plannedStarts.indexed)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('${i + 1}. ${Formatters.dateTime(d)}'),
                    ),
                ],
              ),
            ],
            if (c.conflicts.isNotEmpty) ...[
              const SizedBox(height: 12),
              ConflictList(conflicts: c.conflicts.toList()),
            ],
          ],
        ),
      );
    });
  }
}
