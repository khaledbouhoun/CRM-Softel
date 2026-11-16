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
import '../../../prospects/data/models/prospect.dart';
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
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SearchField(
              hint: tr.wfCustomerSearchHint,
              onChanged: controller.setSearch,
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
                final page = controller.page.value;
                return Column(
                  children: [
                    RefreshingBar(
                      visible:
                          controller.state.isLoading &&
                          controller.customers.isNotEmpty,
                    ),
                    Expanded(
                      child: LoadStateView(
                        state: controller.state,
                        isEmpty: controller.customers.isEmpty,
                        onRetry: controller.load,
                        empty: EmptyView(
                          icon: Icons.verified_user_outlined,
                          title: tr.wfNoCustomers,
                          message: tr.wfNoCustomersHint,
                        ),
                        builder: (_) => CrmDataTable<Prospect>(
                          rows: controller.customers,
                          onRowTap: (p) => Get.toNamed(Routes.customer(p.id)),
                          columns: [
                            CrmColumn(
                              label: tr.fieldCompany,
                              flex: 3,
                              cell: (p) => CellText(
                                p.companyName,
                                bold: true,
                                secondary: p.contactName,
                              ),
                            ),
                            CrmColumn(
                              label: tr.fieldPhone,
                              flex: 2,
                              cell: (p) => CellText(p.phone ?? ''),
                            ),
                            CrmColumn(
                              label: tr.fieldCity,
                              flex: 2,
                              cell: (p) => CellText(p.city ?? ''),
                            ),
                            CrmColumn(
                              label: tr.navProducts,
                              flex: 3,
                              cell: (p) => CellText(
                                p.products.map((e) => e.name).join(', '),
                              ),
                            ),
                            CrmColumn(
                              label: tr.wfCustomerSince,
                              width: 130,
                              cell: (p) =>
                                  CellText(Formatters.date(p.convertedAt)),
                            ),
                            CrmColumn(
                              label: '',
                              width: 48,
                              alignment: AlignmentDirectional.centerEnd,
                              cell: (_) =>
                                  const Icon(Icons.chevron_right, size: 20),
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
