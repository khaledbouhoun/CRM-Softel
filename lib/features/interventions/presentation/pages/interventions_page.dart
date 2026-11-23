import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../data/models/intervention.dart';
import '../controllers/interventions_controllers.dart';
import '../dialogs/intervention_dialogs.dart';

/// After-sales triage list.
class InterventionsPage extends GetView<InterventionsController> {
  const InterventionsPage({super.key});

  Future<void> _create() async {
    final created = await showInterventionFormDialog();
    if (created == null) return;
    AppFeedback.success(tr.wfInterventionCreated(created.reference));
    await controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final workflow = controller.workflow;
    return AppShell(
      route: Routes.afterSales,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: tr.navAfterSales,
            subtitle: tr.wfAfterSalesSubtitle,
            actions: [
              Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.state.isLoading ? null : controller.load,
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, size: 18),
                  label: Text(tr.actionRefresh),
                ),
              ),
              FilledButton.icon(
                onPressed: _create,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18),
                label: Text(tr.wfNewIntervention),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Obx(() {
              final f = controller.filter.value;
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<bool?>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: true, label: Text(tr.wfOpenItems)),
                      ButtonSegment(value: false, label: Text(tr.wfClosedItems)),
                      ButtonSegment(value: null, label: Text(tr.filterAll)),
                    ],
                    selected: {f.open},
                    emptySelectionAllowed: false,
                    onSelectionChanged: (s) => controller.setFilter(f.copyWith(open: s.first)),
                  ),
                  FilterDropdown<int>(
                    label: tr.colStatus,
                    width: 180,
                    value: f.statusId,
                    items: workflow.interventionStatuses.where((s) => s.isActive).map((s) => s.id).toList(),
                    itemLabel: (id) => workflow.statusById(id)?.name ?? '$id',
                    onChanged: (v) => controller.setFilter(f.copyWith(statusId: v)),
                  ),
                  FilterDropdown<int>(
                    label: tr.wfPriority,
                    width: 170,
                    value: f.priorityId,
                    items: workflow.activePriorities.map((p) => p.id).toList(),
                    itemLabel: (id) => workflow.priorityById(id)?.name ?? '$id',
                    onChanged: (v) => controller.setFilter(f.copyWith(priorityId: v)),
                  ),
                  FilterDropdown<int>(
                    label: tr.colType,
                    width: 170,
                    value: f.typeId,
                    items: workflow.activeInterventionTypes.map((t) => t.id).toList(),
                    itemLabel: (id) => workflow.interventionTypeById(id)?.name ?? '$id',
                    onChanged: (v) => controller.setFilter(f.copyWith(typeId: v)),
                  ),
                  FilterDropdown<String>(
                    label: tr.wfSource,
                    width: 170,
                    value: f.source,
                    items: const ['customer', 'employee'],
                    itemLabel: (s) => s == 'customer' ? tr.wfSourceCustomer : tr.wfSourceEmployee,
                    onChanged: (v) => controller.setFilter(f.copyWith(source: v)),
                  ),
                  FilterDropdown<String>(
                    label: tr.wfAssignedTo,
                    width: 170,
                    value: f.assignedEmployee,
                    items: workflow.employeeNames.toList(),
                    itemLabel: (e) => e,
                    onChanged: (v) => controller.setFilter(f.copyWith(assignedEmployee: v)),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Obx(() {
                  final page = controller.page.value;
                  final sortKey = controller.sortKey.value;
                  final ascending = controller.ascending.value;
                  final rows = controller.sorted;
                  return Column(
                    children: [
                      RefreshingBar(visible: controller.state.isLoading && rows.isNotEmpty),
                      Expanded(
                        child: LoadStateView(
                          state: controller.state,
                          isEmpty: rows.isEmpty,
                          onRetry: controller.load,
                          empty: EmptyView(
                            icon: HugeIcons.strokeRoundedHeadset,
                            title: tr.wfNoInterventions,
                            message: tr.wfNoInterventionsHint,
                          ),
                          builder: (_) => CrmDataTable<Intervention>(
                            rows: rows,
                            rowHeight: 60,
                            sortKey: sortKey,
                            ascending: ascending,
                            onSort: (k) => controller.sortBy(k as String),
                            onRowTap: (i) async {
                              await Get.toNamed(Routes.afterSalesDetail(i.id));
                              await controller.load();
                            },
                            columns: [
                              CrmColumn(
                                label: tr.wfPriority,
                                sortKey: 'priority',
                                width: 130,
                                cell: (i) => PriorityChip(priority: i.priority),
                              ),
                              CrmColumn(
                                label: tr.wfReference,
                                sortKey: 'reference',
                                width: 110,
                                cell: (i) => CellText(i.reference, bold: true),
                              ),
                              CrmColumn(
                                label: tr.wfTitle,
                                sortKey: 'title',
                                flex: 4,
                                cell: (i) => CellText(
                                  i.title,
                                  secondary: joinNonEmpty([
                                    i.prospect?.name ??
                                        (i.customers.isEmpty ? null : tr.wfCustomersCount(i.customers.length)),
                                    i.product?.name,
                                  ]),
                                ),
                              ),
                              CrmColumn(
                                label: tr.colType,
                                sortKey: 'type',
                                flex: 2,
                                cell: (i) => i.type == null
                                    ? const SizedBox.shrink()
                                    : StatusBadge(
                                        label: i.type!.name,
                                        color: hexColor(i.type!.color, context.colors.primary),
                                      ),
                              ),
                              CrmColumn(
                                label: tr.wfSource,
                                width: 110,
                                cell: (i) => CellText(i.isFromCustomer ? tr.wfSourceCustomer : tr.wfSourceEmployee),
                              ),
                              CrmColumn(
                                label: tr.colStatus,
                                sortKey: 'status',
                                flex: 2,
                                cell: (i) => InterventionStatusBadge(status: i.status),
                              ),
                              CrmColumn(
                                label: tr.wfAssignedTo,
                                sortKey: 'assigned',
                                flex: 2,
                                cell: (i) => CellText(i.assignedEmployee ?? ''),
                              ),
                              CrmColumn(
                                label: tr.wfUpdated,
                                width: 140,
                                cell: (i) => CellText(Formatters.dateTime(i.updatedAt)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (rows.isNotEmpty) PaginationBar(page: page, onPageChanged: controller.goToPage),
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
}
