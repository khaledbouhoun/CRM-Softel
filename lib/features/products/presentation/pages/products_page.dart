import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../workflow_settings/presentation/product_resources_dialog.dart';
import '../../data/models/product.dart';
import '../controllers/products_controllers.dart';
import '../dialogs/pack_form_dialog.dart';
import '../../../../app/l10n/l10n.dart';

class ProductsPage extends GetView<ProductsController> {
  const ProductsPage({super.key});

  Future<void> _openForm([Product? product]) async {
    final saved = await showControllerDialog<ProductFormController, Product>(
      controller: ProductFormController(
        repository: Get.find(),
        initial: product,
      ),
      builder: (c) => _ProductFormDialog(c),
    );
    if (saved == null) return;
    AppFeedback.success(
      product == null ? tr.productAdded(saved.name) : tr.productUpdated,
    );
    await controller.afterMutation();
  }

  Future<void> _toggle(Product p) async {
    final activate = !p.isActive;
    if (!activate) {
      final ok = await showConfirmDialog(
        title: tr.deactivateQuestion(p.name),
        message: tr.deactivateProductBody,
        confirmLabel: tr.actionDeactivate,
      );
      if (!ok) return;
    }
    final result = await controller.setActive(p, activate);
    if (result.isSuccess) {
      AppFeedback.success(
        activate ? tr.productReactivated : tr.productDeactivated,
      );
    } else {
      AppFeedback.error(result.error!);
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.products,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: tr.navProducts,
          subtitle: tr.productsSubtitle,
          actions: [
            Obx(
              () => OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final pack = await showPackFormDialog(context: context);
                if (pack != null) {
                  await controller.afterMutation();
                }
              },
              icon: const Icon(Icons.layers_outlined, size: 18),
              label: Text(tr.productPacksTitle),
            ),
            FilledButton.icon(
              onPressed: _openForm,
              icon: const Icon(Icons.add, size: 18),
              label: Text(tr.newProduct),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SearchField(
                hint: tr.productSearchHint,
                onChanged: (v) => controller.search.value = v,
              ),
              Obx(
                () => FilterChip(
                  label: Text(tr.showInactiveProducts),
                  selected: controller.showInactive.value,
                  onSelected: (v) => controller.showInactive.value = v,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Obx(() {
                final items = controller.visibleProducts;
                return Column(
                  children: [
                    RefreshingBar(
                      visible:
                          controller.state.isLoading &&
                          controller.products.isNotEmpty,
                    ),
                    if (controller.state.hasError &&
                        controller.products.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ErrorBanner(
                          message: controller.state.errorMessage.value ?? '',
                          onRetry: controller.load,
                        ),
                      ),
                    Expanded(
                      child: LoadStateView(
                        state: controller.state,
                        isEmpty: items.isEmpty,
                        onRetry: controller.load,
                        empty: EmptyView(
                          icon: Icons.inventory_2_outlined,
                          title: controller.products.isEmpty
                              ? tr.noProducts
                              : tr.noProductMatches,
                          action: controller.products.isEmpty
                              ? FilledButton(
                                  onPressed: _openForm,
                                  child: Text(tr.addProduct),
                                )
                              : null,
                        ),
                        builder: (_) => CrmDataTable<Product>(
                          rows: items,
                          onRowTap: _openForm,
                          columns: [
                            CrmColumn(
                              label: tr.fieldProduct,
                              flex: 3,
                              cell: (p) => Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CellText(
                                    p.name,
                                    bold: true,
                                    color: p.isActive
                                        ? null
                                        : context.colors.outline,
                                  ),
                                  if (p.packName != null &&
                                      p.packName!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.layers_outlined,
                                          size: 13,
                                          color: context.colors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            p.packName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.text.bodySmall?.copyWith(
                                              color: context.colors.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            CrmColumn(
                              label: tr.fieldDescription,
                              flex: 4,
                              cell: (p) => CellText(p.description ?? ''),
                            ),
                            CrmColumn(
                              label: tr.productActiveOnWeb,
                              width: 140,
                              cell: (p) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (p.isActiveOnWeb)
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(end: 6),
                                      child: StatusPill(
                                        label: 'Web',
                                        icon: Icons.public,
                                        color: context.crm.info,
                                      ),
                                    ),
                                  if (p.hasDemo)
                                    Tooltip(
                                      message: p.demoUrl ?? '',
                                      child: StatusPill(
                                        label: 'Démo',
                                        icon: Icons.play_circle_outline,
                                        color: context.crm.warning,
                                      ),
                                    ),
                                  if (!p.isActiveOnWeb && !p.hasDemo)
                                    Text(
                                      '—',
                                      style: context.text.bodySmall?.copyWith(
                                        color: context.colors.outline,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            CrmColumn(
                              label: tr.navProspects,
                              width: 100,
                              alignment: AlignmentDirectional.centerEnd,
                              cell: (p) =>
                                  CellText(p.prospectsCount?.toString() ?? '—'),
                            ),
                            CrmColumn(
                              label: tr.colStatus,
                              width: 110,
                              cell: (p) => p.isActive
                                  ? StatusPill(
                                      label: tr.statusActive,
                                      color: context.crm.success,
                                    )
                                  : StatusPill(
                                      label: tr.statusInactive,
                                      color: context.colors.outline,
                                    ),
                            ),
                            CrmColumn(
                              label: '',
                              width: 176,
                              alignment: AlignmentDirectional.centerEnd,
                              cell: (p) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: p.isActive
                                        ? tr.actionDeactivate
                                        : tr.actionReactivate,
                                    child: Switch(
                                      value: p.isActive,
                                      onChanged:
                                          controller.busyIds.contains(p.id)
                                          ? null
                                          : (_) => _toggle(p),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: tr.wfProductResources,
                                    icon: const Icon(Icons.link, size: 20),
                                    onPressed: () =>
                                        showProductResourcesDialog(p),
                                  ),
                                  IconButton(
                                    tooltip: tr.actionEdit,
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () => _openForm(p),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProductFormDialog extends StatelessWidget {
  const _ProductFormDialog(this.c);

  final ProductFormController c;

  Future<void> _submit() async {
    final saved = await c.submit();
    if (saved != null) Get.back(result: saved);
  }

  @override
  Widget build(BuildContext context) {
    final lookups = Get.find<LookupService>();

    return Obx(
      () {
        final availablePacks = lookups.packs;
        final selectedPackId = c.packId.value;
        final validPackValue = (selectedPackId != null &&
                availablePacks.any((p) => p.id == selectedPackId))
            ? selectedPackId
            : null;

        return FormDialog(
          title: c.isEdit ? tr.editProduct : tr.newProduct,
          icon: Icons.inventory_2_outlined,
          busy: c.isSubmitting.value,
          errorMessage: c.errorMessage.value,
          onCancel: () => Get.back(),
          onSubmit: _submit,
          child: Form(
            key: c.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: c.name,
                  autofocus: true,
                  decoration: InputDecoration(labelText: tr.fieldNameRequired),
                  validator: c.validateName,
                  onChanged: (_) => c.serverErrors.remove('name'),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        key: ValueKey(validPackValue),
                        initialValue: validPackValue,
                        decoration: InputDecoration(
                          labelText: tr.productPack,
                          prefixIcon: const Icon(Icons.layers_outlined, size: 20),
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(tr.productNoPack),
                          ),
                          for (final p in availablePacks)
                            DropdownMenuItem<int?>(
                              value: p.id,
                              child: Text(p.name),
                            ),
                        ],
                        onChanged: (v) => c.packId.value = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: IconButton.outlined(
                        tooltip: tr.productNewPack,
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () async {
                          final created =
                              await showPackFormDialog(context: context);
                          if (created != null) {
                            c.packId.value = created.id;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: c.description,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: tr.fieldDescription,
                    alignLabelWithHint: true,
                  ),
                  validator: c.validateDescription,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: c.demoUrl,
                  decoration: InputDecoration(
                    labelText: tr.productDemoUrl,
                    hintText: tr.productDemoUrlHint,
                    prefixIcon: const Icon(Icons.link, size: 20),
                    helperText: tr.productDemoUrlHint,
                  ),
                  validator: c.validateDemoUrl,
                  onChanged: (_) => c.serverErrors.remove('demo_url'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    onPressed: (c.isUploadingDemo.value || c.isSubmitting.value)
                        ? null
                        : c.pickAndUploadDemoFile,
                    icon: c.isUploadingDemo.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file, size: 18),
                    label: Text(
                      c.isUploadingDemo.value
                          ? tr.productUploadingDemo
                          : tr.productUploadDemo,
                    ),
                  ),
                ),
                if (c.isUploadingDemo.value) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: c.demoUploadProgress.value > 0
                        ? c.demoUploadProgress.value
                        : null,
                  ),
                ],
                if (c.uploadedDemoName.value != null &&
                    !c.isUploadingDemo.value) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 14, color: context.crm.success),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          c.uploadedDemoName.value!,
                          style: context.text.bodySmall?.copyWith(
                            color: context.crm.success,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr.productActiveOnWeb),
                  subtitle: Text(tr.productActiveOnWebHint),
                  value: c.isActiveOnWeb.value,
                  onChanged: (v) => c.isActiveOnWeb.value = v,
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr.productActive),
                  subtitle: Text(tr.productActiveHint),
                  value: c.isActive.value,
                  onChanged: (v) => c.isActive.value = v,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
