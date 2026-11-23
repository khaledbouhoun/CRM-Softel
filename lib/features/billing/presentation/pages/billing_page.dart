import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/models/billing_models.dart';
import '../controllers/billing_controllers.dart';
import 'billing_widgets.dart';

/// Subscriptions overview: maintenance status of every customer.
class BillingPage extends GetView<BillingListController> {
  const BillingPage({super.key});

  String _sortLabel(String sort) => switch (sort) {
    BillingSort.expiresAt => tr.blSortExpiry,
    BillingSort.convertedAt => tr.blSortConverted,
    _ => tr.blSortName,
  };

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.billing,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: tr.blTitle, subtitle: tr.blSubtitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SearchField(
                  hint: tr.blSearchHint,
                  initialValue: controller.search.value,
                  onChanged: controller.setSearch,
                ),
                FilterDropdown<String>(
                  label: tr.blFilterStatus,
                  allLabel: tr.blStatusAll,
                  width: 200,
                  value: controller.status.value,
                  items: MaintenanceStatus.values,
                  itemLabel: maintenanceStatusLabel,
                  onChanged: controller.setStatus,
                ),
                SizedBox(
                  width: 210,
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.sort.value,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: tr.blSortBy),
                    items: [
                      for (final s in BillingSort.values)
                        DropdownMenuItem(value: s, child: Text(_sortLabel(s))),
                    ],
                    onChanged: (v) {
                      if (v != null) controller.setSort(v);
                    },
                  ),
                ),
                IconButton.outlined(
                  tooltip: tr.blSortDirection,
                  icon: Icon(
                    controller.descending.value
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    size: 18,
                  ),
                  onPressed: controller.toggleDirection,
                ),
                FilterChip(
                  label: Text(tr.blPendingOnly),
                  selected: controller.pendingOnly.value,
                  onSelected: controller.setPendingOnly,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Obx(() {
                final rows = controller.rows;
                return Column(
                  children: [
                    RefreshingBar(
                      visible: controller.state.isLoading && rows.isNotEmpty,
                    ),
                    Expanded(
                      child: LoadStateView(
                        state: controller.state,
                        isEmpty: rows.isEmpty,
                        onRetry: controller.load,
                        empty: EmptyView(
                          icon: Icons.verified_outlined,
                          title: tr.blNoCustomers,
                          message: tr.blNoCustomersHint,
                        ),
                        builder: (_) => CrmDataTable<BillingCustomerRow>(
                          rows: rows,
                          rowHeight: 60,
                          onRowTap: (r) => Get.toNamed(Routes.billingCustomer(r.id)),
                          columns: [
                            CrmColumn(
                              label: tr.blColCustomer,
                              flex: 3,
                              cell: (r) => CellText(
                                r.name,
                                bold: true,
                                secondary: r.contactPerson,
                              ),
                            ),
                            CrmColumn(
                              label: tr.blFilterStatus,
                              width: 160,
                              cell: (r) =>
                                  MaintenanceStatusBadge(r.maintenance.status),
                            ),
                            CrmColumn(
                              label: tr.blColExpiry,
                              width: 130,
                              cell: (r) =>
                                  CellText(Formatters.date(r.maintenance.expiresAt)),
                            ),
                            CrmColumn(
                              label: tr.blColDaysLeft,
                              width: 120,
                              cell: (r) => CellText(
                                r.maintenance.daysRemaining?.toString() ?? '',
                              ),
                            ),
                            CrmColumn(
                              label: tr.blColPending,
                              width: 110,
                              cell: (r) => CellText(
                                r.pendingRenewalsCount > 0
                                    ? '${r.pendingRenewalsCount}'
                                    : '',
                                bold: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PaginationBar(
                      page: controller.page.value,
                      onPageChanged: controller.goToPage,
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
