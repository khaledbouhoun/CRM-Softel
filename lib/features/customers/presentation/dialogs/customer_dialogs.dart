import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../app/services/workflow_lookup_service.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../products/domain/products_repository.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../data/models/customer_models.dart';
import '../controllers/customers_controllers.dart';

import 'package:hugeicons/hugeicons.dart';
/// "Convert prospect to customer": choose the purchased products and an
/// optional note. Resolves with the converted prospect, or null.
Future<Prospect?> showConvertProspectDialog(Prospect prospect) =>
    showControllerDialog<ConvertProspectController, Prospect>(
      controller: ConvertProspectController(
        repository: Get.find(),
        prospect: prospect,
        // Lets the checklist enforce "one product per pack".
        catalog: Get.find<LookupService>().products.toList(),
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
        icon: HugeIcons.strokeRoundedSecurityCheck,
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
                  secondary: p.packName == null
                      ? null
                      : Tooltip(
                          message: tr.prPackHint,
                          child: Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(p.packName!),
                          ),
                        ),
                  onChanged: (v) {
                    final dropped = c.toggleProduct(p.id, v ?? false);
                    if (dropped.isNotEmpty) {
                      AppFeedback.warning(
                        tr.prPackReplaced(dropped.map((e) => e.name).join(', ')),
                      );
                    }
                  },
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
Future<Trial?> showTrialDialog({
  required int prospectId,
  int? productId,
  List<int>? productIds,
  String? notes,
}) async {
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
      initialProductId: productId,
      initialProductIds: productIds,
      initialNotes: notes,
      productsRepository: Get.find<ProductsRepository>(),
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
    return Obx(() {
      final products = c.products.toList();
      final selected = c.selectedProduct;
      final showMultiCheck = products.length > 1;

      return FormDialog(
        title: tr.wfNewTrial,
        icon: HugeIcons.strokeRoundedMedicine01,
        busy: c.isSubmitting.value,
        errorMessage: c.errorMessage.value,
        submitLabel: tr.actionConfirm,
        onCancel: () => Get.back(),
        onSubmit: _submit,
        child: Form(
          key: c.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (c.productsError.value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    c.productsError.value!,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ),
              if (showMultiCheck) ...[
                Text(
                  tr.interestedProducts,
                  style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < products.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, color: context.colors.outlineVariant),
                        CheckboxListTile(
                          value: c.selectedProductIds.contains(products[i].id),
                          onChanged: (v) => c.toggleProduct(products[i].id, v ?? false),
                          title: Text(
                            products[i].name,
                            style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: products[i].hasDemo &&
                                  products[i].demoUrl != null &&
                                  products[i].demoUrl!.isNotEmpty
                              ? Text(
                                  products[i].demoUrl!,
                                  style: context.text.bodySmall?.copyWith(color: context.colors.primary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        ),
                      ],
                    ],
                  ),
                ),
                if (c.selectedProductIds.isEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 6, start: 4),
                    child: Text(
                      tr.wfSelectProduct,
                      style: context.text.bodySmall?.copyWith(color: context.colors.error),
                    ),
                  ),
                const SizedBox(height: 14),
              ] else ...[
                DropdownButtonFormField<int>(
                  key: ValueKey('trial-product-${products.length}'),
                  initialValue: c.productId.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: tr.fieldProduct,
                    helperText: products.isEmpty && !c.isLoadingProducts.value
                        ? tr.prNoDemoProducts
                        : tr.prFilteredByCustomer,
                  ),
                  items: [
                    for (final p in products)
                      DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  onChanged: (v) {
                    c.productId.value = v;
                    c.selectedProductIds.clear();
                    if (v != null) c.selectedProductIds.add(v);
                  },
                ),
                const SizedBox(height: 14),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr.prDemoLink,
                    helperText: selected == null
                        ? null
                        : (selected.hasDemo ? tr.prDemoLinkHint : tr.prNoDemoLink),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(8),
                      child: HugeIcon(icon: HugeIcons.strokeRoundedLink01, size: 18),
                    ),
                  ),
                  child: SelectableText(
                    selected?.demoUrl ?? '—',
                    style: context.text.bodyMedium,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Text(
                    tr.wfTrialStarts,
                    style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    children: [
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        label: const Text('7d'),
                        onPressed: () => c.setDurationDays(7),
                      ),
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        label: const Text('14d'),
                        onPressed: () => c.setDurationDays(14),
                      ),
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        label: const Text('30d'),
                        onPressed: () => c.setDurationDays(30),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
      );
    });
  }
}
