import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/huge_data.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/phone_cell.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../../products/data/models/product.dart';
import '../../../products/presentation/widgets/product_selector.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../data/models/customer_models.dart';
import '../controllers/customers_controllers.dart';

/// Customers = converted prospects. Opening one shows its profile.
class CustomersPage extends GetView<CustomersListController> {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.customers,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: tr.navCustomers,
          subtitle: tr.wfCustomersSubtitle,
          actions: [
            Obx(
              () => OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ),
          ],
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: _FilterBar(controller)),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Obx(() {
                final page = controller.page.value;
                final sortKey = controller.sort.value;
                final ascending = controller.ascending.value;
                return Column(
                  children: [
                    RefreshingBar(visible: controller.state.isLoading && controller.customers.isNotEmpty),
                    Expanded(
                      child: LoadStateView(
                        state: controller.state,
                        isEmpty: controller.customers.isEmpty,
                        onRetry: controller.load,
                        empty: EmptyView(
                          icon: HugeIcons.strokeRoundedSecurityCheck,
                          title: tr.wfNoCustomers,
                          message: tr.wfNoCustomersHint,
                        ),
                        builder: (_) => CrmDataTable<Prospect>(
                          rows: controller.customers,
                          rowHeight: 64,
                          sortKey: sortKey,
                          ascending: ascending,
                          onSort: (key) => controller.sortBy(key as CustomerSort),
                          onRowTap: (p) => Get.toNamed(Routes.customer(p.id)),
                          columns: [
                            CrmColumn(
                              label: tr.fieldCompany,
                              flex: 3,
                              sortKey: CustomerSort.companyName,
                              cell: (p) => Row(
                                children: [
                                  _Monogram(p),
                                  const SizedBox(width: 10),
                                  Expanded(child: CellText(p.companyName, bold: true, secondary: p.contactName)),
                                ],
                              ),
                            ),
                            CrmColumn(
                              label: tr.fieldPhone,
                              flex: 2,
                              sortKey: CustomerSort.phone,
                              cell: (p) => PhoneCell(p.phone),
                            ),
                            CrmColumn(
                              label: tr.navProducts,
                              flex: 3,
                              cell: (p) => ProductChips(products: p.products, max: 2),
                            ),
                            CrmColumn(
                              label: tr.customerFilterMaintenance,
                              flex: 3,
                              sortKey: CustomerSort.maintenance,
                              cell: (p) => _MaintenanceChip(p),
                            ),
                            CrmColumn(
                              label: tr.customerFilterPortal,
                              width: 80,
                              alignment: AlignmentDirectional.center,
                              cell: (p) => Tooltip(
                                message: p.hasPortalAccount ? tr.customerPortalHas : tr.customerPortalNone,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: p.hasPortalAccount ? context.crm.success.withValues(alpha: 0.10) : null,
                                  ),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedUserCheck01,
                                    size: 20,
                                    color: p.hasPortalAccount ? context.crm.success : context.colors.outline,
                                  ),
                                ),
                              ),
                            ),
                            CrmColumn(
                              flex: 2,
                              label: tr.wfCustomerSince,

                              sortKey: CustomerSort.convertedAt,
                              cell: (p) => CellText(Formatters.date(p.convertedAt)),
                            ),
                            CrmColumn(
                              flex: 1,
                              label: '',

                              alignment: AlignmentDirectional.centerEnd,
                              cell: (p) => _RowActions(p),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (controller.customers.isNotEmpty)
                      PaginationBar(
                        page: page,
                        onPageChanged: controller.goToPage,
                        onPerPageChanged: controller.setPerPage,
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

class _FilterBar extends StatelessWidget {
  const _FilterBar(this.c);

  final CustomersListController c;

  static String _maintenanceLabel(CustomerMaintenanceFilter f) => switch (f) {
    CustomerMaintenanceFilter.all => tr.customerFilterAll,
    CustomerMaintenanceFilter.active => tr.customerMaintenanceActivePlan,
    CustomerMaintenanceFilter.expiring => tr.customerMaintenanceExpiringSoon,
    CustomerMaintenanceFilter.expiredOrNone => tr.customerMaintenanceExpiredNone,
  };

  static String _portalLabel(CustomerPortalFilter f) => switch (f) {
    CustomerPortalFilter.all => tr.customerFilterAll,
    CustomerPortalFilter.hasAccount => tr.customerPortalHas,
    CustomerPortalFilter.noAccount => tr.customerPortalNone,
  };

  @override
  Widget build(BuildContext context) {
    final lookups = Get.isRegistered<LookupService>() ? Get.find<LookupService>() : null;
    return Obx(() {
      final products = lookups?.activeProducts ?? const <Product>[];
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SearchField(initialValue: c.search.value, hint: tr.wfCustomerSearchHint, onChanged: c.setSearch),
          FilterDropdown<Product>(
            label: tr.fieldProduct,
            value: products.firstWhereOrNull((p) => p.id == c.productId.value),
            items: products.toList(),
            itemLabel: (p) => p.name,
            allLabel: tr.allProducts,
            onChanged: (p) => c.setProduct(p?.id),
          ),
          SegmentedButton<CustomerMaintenanceFilter>(
            showSelectedIcon: false,
            segments: [
              for (final f in CustomerMaintenanceFilter.values)
                ButtonSegment(value: f, label: Text(_maintenanceLabel(f))),
            ],
            selected: {c.maintenance.value},
            onSelectionChanged: (v) => c.setMaintenance(v.first),
          ),
          SegmentedButton<CustomerPortalFilter>(
            showSelectedIcon: false,
            segments: [
              for (final f in CustomerPortalFilter.values) ButtonSegment(value: f, label: Text(_portalLabel(f))),
            ],
            selected: {c.portal.value},
            onSelectionChanged: (v) => c.setPortal(v.first),
          ),
          if (c.hasFilters)
            TextButton.icon(
              onPressed: c.clearFilters,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedFilterRemove, size: 18),
              label: Text(tr.actionReset),
            ),
        ],
      );
    });
  }
}

/// Company monogram ringed with the maintenance status color.
class _Monogram extends StatelessWidget {
  const _Monogram(this.p);

  final Prospect p;

  @override
  Widget build(BuildContext context) {
    final color = _maintenanceColor(context, p.maintenanceStatus);
    final name = p.companyName.trim();
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: color.withValues(alpha: 0.10),
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: context.text.titleSmall?.copyWith(color: color),
      ),
    );
  }
}

Color _maintenanceColor(BuildContext context, String? status) => switch (status) {
  'active' => context.crm.success,
  'expiring_soon' => context.crm.warning,
  'expired' => context.crm.danger,
  _ => context.colors.outline,
};

/// Co-termed maintenance chip with the expiry date.
class _MaintenanceChip extends StatelessWidget {
  const _MaintenanceChip(this.p);

  final Prospect p;

  @override
  Widget build(BuildContext context) {
    final status = p.maintenanceStatus;
    final expires = p.maintenanceExpiresAt;
    final label = switch (status) {
      'active' ||
      'expiring_soon' => expires == null ? tr.statusActive : tr.customerMaintenanceActiveUntil(Formatters.day(expires)),
      'expired' => tr.customerMaintenanceExpired,
      _ => tr.customerMaintenanceNone,
    };
    return StatusBadge(label: label, color: _maintenanceColor(context, status));
  }
}

/// Call, WhatsApp and open-profile shortcuts of a customer row.
class _RowActions extends StatelessWidget {
  const _RowActions(this.p);

  final Prospect p;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: tr.wfOpenCustomerProfile,
          onPressed: () => Get.toNamed(Routes.customer(p.id)),
          icon: const MirroredHugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
        ),
      ],
    );
  }
}
