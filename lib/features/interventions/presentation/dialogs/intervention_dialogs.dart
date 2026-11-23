import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../app/services/workflow_lookup_service.dart';
import '../../../../core/models/named_ref.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../../workflow_settings/data/models/config_models.dart';
import '../../../prospects/presentation/dialogs/prospect_search_dialog.dart';
import '../../data/models/intervention.dart';
import '../controllers/interventions_controllers.dart';

import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/animated_entrance.dart';
/// New employee-originated intervention (fix, release, update ...). The
/// affected customers see it only once it is published.
Future<Intervention?> showInterventionFormDialog() async {
  final workflow = Get.find<WorkflowLookupService>();
  try {
    await workflow.ensureLoaded();
  } catch (_) {
    // The dialog reports the missing configuration itself.
  }
  return showControllerDialog<InterventionFormController, Intervention>(
    controller: InterventionFormController(
      repository: Get.find(),
      workflow: workflow,
    ),
    builder: (c) => _FormDialog(c),
  );
}

class _FormDialog extends StatelessWidget {
  const _FormDialog(this.c);

  final InterventionFormController c;

  Future<void> _submit() async {
    final created = await c.submit();
    if (created != null) Get.back(result: created);
  }

  @override
  Widget build(BuildContext context) {
    final lookups = Get.find<LookupService>();
    return Obx(() {
      final types = c.workflow.employeeInterventionTypes;
      return FormDialog(
        title: tr.wfNewIntervention,
        icon: HugeIcons.strokeRoundedWrench01,
        width: 640,
        busy: c.isSubmitting.value,
        errorMessage: c.errorMessage.value,
        onCancel: () => Get.back(),
        onSubmit: _submit,
        child: Form(
          key: c.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormRow(
                children: [
                  DropdownButtonFormField<InterventionType>(
                    initialValue: c.type.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: tr.wfInterventionType,
                    ),
                    items: [
                      for (final t in types)
                        DropdownMenuItem(value: t, child: Text(t.name)),
                    ],
                    onChanged: (v) => c.type.value = v,
                  ),
                  DropdownButtonFormField<int?>(
                    initialValue: c.priority.value?.id,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: tr.wfPriority),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(tr.wfNoPriority),
                      ),
                      for (final p in c.workflow.activePriorities)
                        DropdownMenuItem<int?>(
                          value: p.id,
                          child: Text(p.name),
                        ),
                    ],
                    onChanged: (v) =>
                        c.priority.value = c.workflow.priorityById(v),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: c.title,
                decoration: InputDecoration(labelText: tr.wfTitle),
                validator: c.validateTitle,
                onChanged: (_) => c.serverErrors.remove('title'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: c.description,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: tr.fieldDescription,
                  alignLabelWithHint: true,
                ),
                validator: c.validateDescription,
                onChanged: (_) => c.serverErrors.remove('description'),
              ),
              const SizedBox(height: 14),
              FormRow(
                children: [
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
                    onChanged: (v) => c.productId.value = v,
                  ),
                  EmployeeDropdown(
                    value: c.employee.value,
                    names: c.workflow.employeeNames,
                    onChanged: (v) => c.employee.value = v,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DateTimeField(
                label: tr.wfScheduledAt,
                value: c.scheduledAt.value,
                clearable: true,
                onChanged: (v) => c.scheduledAt.value = v,
              ),
              const SizedBox(height: 14),
              FormSectionLabel(tr.wfAffectedCustomers),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final customer in c.customers)
                    InputChip(
                      label: Text(customer.name),
                      onDeleted: () => c.removeCustomer(customer),
                    ),
                  ActionChip(
                    avatar: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 16),
                    label: Text(tr.wfAddCustomer),
                    onPressed: () async {
                      final picked = await showProspectSearchDialog(
                        title: tr.wfAddCustomer,
                        excludeStageIds: const [],
                        // Product chosen first: only the customers who own
                        // it or are interested in it are offered.
                        productId: c.productId.value,
                      );
                      if (picked != null) {
                        c.addCustomer(
                          NamedRef(id: picked.id, name: picked.companyName),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Asks for an optional customer-visible explanation before a status
/// change. Resolves with the text ('' for none) or null when cancelled.
Future<String?> showStatusChangeDialog({
  required String statusName,
  required String customerLabel,
}) {
  final text = TextEditingController();
  return showAppDialog<String>(
    Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.wfChangeStatusTo(statusName),
                style: Get.textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(tr.wfCustomerSeesStatus(customerLabel)),
              const SizedBox(height: 12),
              TextField(
                controller: text,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: tr.wfStatusExplanation,
                  helperText: tr.wfCustomerVisibleHint,
                  helperMaxLines: 2,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(tr.actionCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Get.back(result: text.text),
                    child: Text(tr.actionConfirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Optional note recorded in the timeline when an intervention is reopened.
/// Resolves with the note ('' for none) or null when cancelled.
Future<String?> showReopenDialog() {
  final text = TextEditingController();
  return showAppDialog<String>(
    Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.ivReopen, style: Get.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(tr.ivReopenBody),
              const SizedBox(height: 12),
              TextField(
                controller: text,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: tr.ivReopenNote,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(tr.actionCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => Get.back(result: text.text),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedLockOpen, size: 18),
                    label: Text(tr.ivReopen),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Release / update notes for the affected customers. Resolves with the
/// text, or null when cancelled.
Future<String?> showPublishDialog(Intervention intervention) {
  final text = TextEditingController(text: intervention.customerResolution);
  return showAppDialog<String>(
    Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.wfPublishTitle, style: Get.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                intervention.customers.isEmpty
                    ? tr.wfPublishNoCustomers
                    : tr.wfPublishTo(
                        intervention.customers.map((c) => c.name).join(', '),
                      ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: text,
                minLines: 4,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: tr.wfReleaseNotes,
                  helperText: tr.wfCustomerVisibleHint,
                  helperMaxLines: 2,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(tr.actionCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => Get.back(result: text.text),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedMegaphone01, size: 18),
                    label: Text(tr.wfPublish),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
