import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../app/services/workflow_lookup_service.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../data/models/customer_models.dart';
import '../controllers/customers_controllers.dart';

/// "Convert prospect to customer": choose the purchased products and an
/// optional note. Resolves with the converted prospect, or null.
Future<Prospect?> showConvertProspectDialog(Prospect prospect) =>
    showControllerDialog<ConvertProspectController, Prospect>(
      controller: ConvertProspectController(
        repository: Get.find(),
        prospect: prospect,
      ),
      builder: (c) => _ConvertDialog(c),
    );

class _ConvertDialog extends StatelessWidget {
  const _ConvertDialog(this.c);

  final ConvertProspectController c;

  Future<void> _submit() async {
    final converted = await c.submit();
    if (converted != null) Get.back(result: converted);
  }

  @override
  Widget build(BuildContext context) {
    final lookups = Get.find<LookupService>();
    return Obx(() {
      // Products already linked stay listed even if deactivated later.
      final products = {
        for (final p in lookups.activeProducts) p.id: p,
        for (final p in c.prospect.products) p.id: p,
      }.values.toList();
      return FormDialog(
        title: tr.wfConvertTitle,
        icon: Icons.verified_user_outlined,
        busy: c.isSubmitting.value,
        errorMessage: c.errorMessage.value,
        submitLabel: tr.actionConfirm,
        submitEnabled: !c.alreadyCustomer.value,
        onCancel: () => Get.back(),
        onSubmit: _submit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.wfConvertIntro(c.prospect.companyName),
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: 14),
            FormSectionLabel(tr.wfPurchasedProducts),
            if (products.isEmpty)
              Text(
                tr.noProducts,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              )
            else
              for (final p in products)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(p.name),
                  value: c.selectedProductIds.contains(p.id),
                  onChanged: (v) => c.toggleProduct(p.id, v ?? false),
                ),
            const SizedBox(height: 10),
            TextField(
              controller: c.note,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: tr.wfConversionNote,
                alignLabelWithHint: true,
                errorText: c.serverErrors['note'],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Activates trial access for [prospectId]. Resolves with the new trial.
Future<Trial?> showTrialDialog({required int prospectId}) async {
  final workflow = Get.find<WorkflowLookupService>();
  try {
    await workflow.ensureLoaded();
  } catch (_) {
    // The dialog still works without the default duration.
  }
  final scheduling = workflow.scheduling.value;
  return showControllerDialog<TrialFormController, Trial>(
    controller: TrialFormController(
      repository: Get.find(),
      prospectId: prospectId,
      defaultDays: scheduling?.trialDefaultDays,
    ),
    builder: (c) => _TrialDialog(c),
  );
}

class _TrialDialog extends StatelessWidget {
  const _TrialDialog(this.c);

  final TrialFormController c;

  Future<void> _submit() async {
    final trial = await c.submit();
    if (trial != null) Get.back(result: trial);
  }

  @override
  Widget build(BuildContext context) {
    final lookups = Get.find<LookupService>();
    return Obx(
      () => FormDialog(
        title: tr.wfNewTrial,
        icon: Icons.science_outlined,
        busy: c.isSubmitting.value,
        errorMessage: c.errorMessage.value,
        onCancel: () => Get.back(),
        onSubmit: _submit,
        child: Form(
          key: c.formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                initialValue: c.productId.value,
                isExpanded: true,
                decoration: InputDecoration(labelText: tr.fieldProduct),
                items: [
                  for (final p in lookups.activeProducts)
                    DropdownMenuItem(value: p.id, child: Text(p.name)),
                ],
                onChanged: (v) => c.productId.value = v,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: c.url,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: tr.wfTrialUrl,
                  helperText: tr.wfTrialUrlHint,
                ),
                validator: c.validateUrl,
                onChanged: (_) => c.serverErrors.remove('url'),
              ),
              const SizedBox(height: 14),
              FormRow(
                children: [
                  DateTimeField(
                    label: tr.wfTrialStarts,
                    value: c.startsAt.value,
                    onChanged: (v) => c.startsAt.value = v,
                  ),
                  DateTimeField(
                    label: tr.wfTrialEnds,
                    value: c.endsAt.value,
                    clearable: true,
                    errorText: c.endError,
                    onChanged: (v) => c.endsAt.value = v,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: c.notes,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: tr.wfInternalNotes,
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
