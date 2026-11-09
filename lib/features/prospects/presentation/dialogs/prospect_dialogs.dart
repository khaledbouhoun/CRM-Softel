import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/lookup_service.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../products/presentation/widgets/product_selector.dart';
import '../../../settings/data/models/loss_reason.dart';
import '../../../settings/data/models/sales_stage.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_catalogs.dart';
import '../widgets/catalog_text_field.dart';
import '../controllers/prospect_form_controller.dart';
import '../controllers/prospect_products_controller.dart';
import '../controllers/stage_change_controller.dart';
import '../../../../app/l10n/l10n.dart';

/// Opens the create/edit form. Resolves with the saved prospect (as returned
/// by the API) or null when cancelled.
Future<Prospect?> showProspectFormDialog({Prospect? initial}) =>
    showControllerDialog<ProspectFormController, Prospect>(
      controller: ProspectFormController(
        repository: Get.find(),
        lookups: Get.find<LookupService>(),
        initial: initial,
      ),
      builder: (c) => _ProspectFormDialog(c),
    );

/// Opens the stage transition dialog. [targetStageId] preselects a stage
/// (pipeline drag and drop). Resolves with the updated prospect.
Future<Prospect?> showStageChangeDialog(
  Prospect prospect, {
  int? targetStageId,
}) => showControllerDialog<StageChangeController, Prospect>(
  controller: StageChangeController(
    prospect: prospect,
    prospectsRepository: Get.find(),
    stagesRepository: Get.find(),
    lossReasonsRepository: Get.find(),
    initialTargetId: targetStageId,
  ),
  builder: (c) => _StageChangeDialog(c),
);

Future<Prospect?> showProspectProductsDialog(Prospect prospect) =>
    showControllerDialog<ProspectProductsController, Prospect>(
      controller: ProspectProductsController(
        repository: Get.find(),
        lookups: Get.find<LookupService>(),
        prospect: prospect,
      ),
      builder: (c) => _ProspectProductsDialog(c),
    );

class _ProspectFormDialog extends StatelessWidget {
  const _ProspectFormDialog(this.c);

  final ProspectFormController c;

  Future<void> _submit() async {
    final saved = await c.submit();
    if (saved != null) Get.back(result: saved);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: c.isEdit ? tr.editProspect : tr.newProspect,
      icon: c.isEdit ? Icons.edit_outlined : Icons.person_add_alt_1_outlined,
      width: 780,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      submitLabel: c.isEdit ? tr.actionSave : tr.createProspect,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormSectionLabel(tr.sectionIdentity),
            FormRow(
              children: [
                TextFormField(
                  controller: c.companyName,
                  autofocus: !c.isEdit,
                  decoration: InputDecoration(
                    labelText: tr.fieldCompanyRequired,
                    prefixIcon: Icon(Icons.business_outlined, size: 20),
                  ),
                  validator: c.validateCompanyName,
                  onChanged: (_) => c.clearServerError('company_name'),
                ),
                TextFormField(
                  controller: c.contactName,
                  decoration: InputDecoration(
                    labelText: tr.fieldContactPerson,
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: c.validateContactName,
                  onChanged: (_) => c.clearServerError('contact_name'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FormRow(
              children: [
                TextFormField(
                  controller: c.phone,
                  decoration: InputDecoration(
                    labelText: tr.fieldPhone,
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                  validator: c.validatePhone,
                  onChanged: (_) => c.clearServerError('phone'),
                ),
                TextFormField(
                  controller: c.email,
                  decoration: InputDecoration(
                    labelText: tr.fieldEmail,
                    prefixIcon: Icon(Icons.alternate_email, size: 20),
                  ),
                  validator: c.validateEmail,
                  onChanged: (_) => c.clearServerError('email'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FormSectionLabel(tr.fieldAddress),
            FormRow(
              children: [
                TextFormField(
                  controller: c.address,
                  decoration: InputDecoration(labelText: tr.fieldAddress),
                  validator: c.validateAddress,
                  onChanged: (_) => c.clearServerError('address'),
                ),
                TextFormField(
                  controller: c.city,
                  decoration: InputDecoration(labelText: tr.fieldCity),
                  validator: c.validateCity,
                  onChanged: (_) => c.clearServerError('city'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FormSectionLabel(tr.sectionBusinessProfile),
            FormRow(
              children: [
                CatalogTextField(
                  controller: c.businessActivity,
                  options: ProspectCatalogs.businessActivities,
                  label: tr.fieldBusinessActivity,
                  hint: tr.businessActivityHint,
                  icon: Icons.storefront_outlined,
                  validator: c.validateBusinessActivity,
                  onChanged: (_) => c.clearServerError('business_activity'),
                ),
                CatalogTextField(
                  controller: c.previousSoftware,
                  options: ProspectCatalogs.previousSoftware,
                  label: tr.fieldPreviousSoftware,
                  hint: tr.previousSoftwareHint,
                  icon: Icons.apps_outlined,
                  validator: c.validatePreviousSoftware,
                  onChanged: (_) => c.clearServerError('previous_software'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sourceRow(),
            const SizedBox(height: 18),
            FormSectionLabel(tr.sectionSalesFollowUp),
            _stageField(context),
            const SizedBox(height: 14),
            _productsField(),
            const SizedBox(height: 14),
            TextFormField(
              controller: c.notes,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: tr.fieldNotes,
                alignLabelWithHint: true,
              ),
              validator: c.validateNotes,
              onChanged: (_) => c.clearServerError('notes'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _sourceRow() {
    final known = ProspectCatalogs.sources;
    final current = c.source.value;
    // A code added by a newer server is still shown (and kept) as-is.
    final extra = current != null && !known.any((o) => o.code == current)
        ? [CatalogOption(current, () => current)]
        : const <CatalogOption>[];
    final sourceField = DropdownButtonFormField<String?>(
      key: ValueKey('source-$current'),
      initialValue: current,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: tr.fieldSource,
        errorText: c.serverErrors['source'],
        prefixIcon: const Icon(Icons.campaign_outlined, size: 20),
      ),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(tr.notSpecified)),
        for (final o in [...known, ...extra])
          DropdownMenuItem<String?>(value: o.code, child: Text(o.label)),
      ],
      onChanged: c.selectSource,
    );
    if (current != ProspectCatalogs.otherCode) return sourceField;
    return FormRow(
      children: [
        sourceField,
        TextFormField(
          controller: c.sourceOther,
          decoration: InputDecoration(
            labelText: tr.fieldSourceOther,
            prefixIcon: const Icon(Icons.edit_note, size: 20),
          ),
          validator: c.validateSourceOther,
          onChanged: (_) => c.clearServerError('source_other'),
        ),
      ],
    );
  }

  Widget _stageField(BuildContext context) {
    if (c.isEdit) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: tr.currentStage,
          helperText: tr.useChangeStageHint,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: StageChip(stage: c.initial!.stage),
        ),
      );
    }
    if (c.lookupState.hasError) {
      return ErrorBanner(
        message: tr.stagesUnavailable(c.lookupState.errorMessage.value ?? ''),
        onRetry: c.loadLookups,
      );
    }
    final stages = c.lookups.activeStages;
    return DropdownButtonFormField<SalesStage>(
      key: ValueKey('stage-${c.selectedStage.value?.id}-${stages.length}'),
      initialValue: stages.contains(c.selectedStage.value)
          ? c.selectedStage.value
          : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: tr.initialStageRequired,
        errorText: c.stageError,
        helperText: c.lookupState.isLoading ? tr.loadingStages : null,
      ),
      items: [
        for (final s in stages)
          DropdownMenuItem(
            value: s,
            child: Row(
              children: [
                StageDot(s),
                const SizedBox(width: 8),
                Expanded(child: Text(s.name, overflow: TextOverflow.ellipsis)),
                StageTypeBadge(s.type),
              ],
            ),
          ),
      ],
      onChanged: c.selectStage,
    );
  }

  Widget _productsField() {
    if (c.lookupState.isLoading && c.lookups.products.isEmpty) {
      return const LinearProgressIndicator();
    }
    return ProductSelector(
      products: c.lookups.products.toList(),
      selectedIds: c.selectedProductIds.toSet(),
      onToggle: c.toggleProduct,
      errorText: c.productsError,
    );
  }
}

class _StageChangeDialog extends StatelessWidget {
  const _StageChangeDialog(this.c);

  final StageChangeController c;

  Future<void> _submit() async {
    final updated = await c.submit();
    if (updated != null) Get.back(result: updated);
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final target = c.target.value;
    final isLost = target?.isLost ?? false;
    return FormDialog(
      title: tr.changeStage,
      icon: Icons.swap_horiz,
      width: 560,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      submitLabel: isLost ? tr.markAsLost : tr.confirmChange,
      submitEnabled: c.loadState.isSuccess,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: c.loadState.hasError
          ? ErrorBanner(
              message: c.loadState.errorMessage.value ?? '',
              onRetry: c.load,
            )
          : !c.loadState.isSuccess
          ? LoadingView(message: tr.loadingStages)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(c.prospect.companyName, style: context.text.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(tr.currentStageLabel, style: context.text.bodyMedium),
                    StageChip(stage: c.currentStage),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SalesStage>(
                  key: ValueKey('target-${target?.id}'),
                  initialValue: c.selectableStages.contains(target)
                      ? target
                      : null,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: tr.newStageRequired,
                    errorText: c.showValidation.value && target == null
                        ? tr.validSelectStage
                        : null,
                  ),
                  items: [
                    for (final s in c.selectableStages)
                      DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            StageDot(s),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StageTypeBadge(s.type),
                          ],
                        ),
                      ),
                  ],
                  onChanged: c.selectTarget,
                ),
                if (target?.isWon ?? false) ...[
                  const SizedBox(height: 12),
                  _InfoNote(
                    icon: Icons.emoji_events_outlined,
                    color: context.crm.success,
                    text: tr.stageMarksWon,
                  ),
                ],
                if (isLost) ...[
                  const SizedBox(height: 12),
                  _InfoNote(
                    icon: Icons.info_outline,
                    color: context.crm.danger,
                    text: tr.validLossReasonRequiredForLost,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<LossReason>(
                    key: ValueKey('reason-${c.lossReason.value?.id}'),
                    initialValue: c.lossReason.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: tr.lossReasonRequiredLabel,
                      errorText: c.lossReasonError,
                      helperText: c.lossReasons.isEmpty
                          ? tr.noActiveLossReason
                          : null,
                    ),
                    items: [
                      for (final r in c.lossReasons)
                        DropdownMenuItem(
                          value: r,
                          child: Text(
                            r.requiresDetails
                                ? tr.reasonDetailsRequiredSuffix(r.label)
                                : r.label,
                          ),
                        ),
                    ],
                    onChanged: c.selectLossReason,
                  ),
                  if (c.requiresDetails) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: c.lossDetails.value,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: tr.detailsRequiredLabel,
                        alignLabelWithHint: true,
                        errorText: c.lossDetailsError,
                      ),
                      onChanged: c.setLossDetails,
                    ),
                  ],
                ],
              ],
            ),
    );
  });
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: context.text.bodyMedium)),
      ],
    ),
  );
}

class _ProspectProductsDialog extends StatelessWidget {
  const _ProspectProductsDialog(this.c);

  final ProspectProductsController c;

  Future<void> _submit() async {
    final updated = await c.submit();
    if (updated != null) Get.back(result: updated);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: tr.interestedProducts,
      icon: Icons.inventory_2_outlined,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value ?? c.lookupState.errorMessage.value,
      submitEnabled: c.hasChanges,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: c.lookupState.isLoading && c.lookups.products.isEmpty
          ? const LoadingView()
          : ProductSelector(
              products: c.lookups.products.toList(),
              selectedIds: c.selectedIds.toSet(),
              onToggle: c.toggle,
            ),
    ),
  );
}
