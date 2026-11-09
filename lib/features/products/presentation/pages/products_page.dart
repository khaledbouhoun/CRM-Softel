import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/models/product.dart';
import '../controllers/products_controllers.dart';
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
                              cell: (p) => CellText(
                                p.name,
                                bold: true,
                                color: p.isActive
                                    ? null
                                    : context.colors.outline,
                              ),
                            ),
                            CrmColumn(
                              label: tr.fieldDescription,
                              flex: 5,
                              cell: (p) => CellText(p.description ?? ''),
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
                              width: 130,
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
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: c.isEdit ? tr.editProduct : tr.newProduct,
      icon: Icons.inventory_2_outlined,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Form(
        key: c.formKey,
        child: Column(
          children: [
            TextFormField(
              controller: c.name,
              autofocus: true,
              decoration: InputDecoration(labelText: tr.fieldNameRequired),
              validator: c.validateName,
              onChanged: (_) => c.serverErrors.remove('name'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: c.description,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: tr.fieldDescription,
                alignLabelWithHint: true,
              ),
              validator: c.validateDescription,
            ),
            const SizedBox(height: 8),
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
    ),
  );
}
