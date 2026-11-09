import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../activities/presentation/dialogs/activity_form_dialog.dart';
import '../../../follow_ups/presentation/dialogs/follow_up_dialogs.dart';
import '../../../products/data/models/product.dart';
import '../../../products/presentation/widgets/product_selector.dart';
import '../../../settings/data/models/loss_reason.dart';
import '../../../settings/data/models/sales_stage.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_catalogs.dart';
import '../../data/models/prospect_filter.dart';
import '../controllers/prospects_list_controller.dart';
import '../dialogs/prospect_dialogs.dart';
import '../../../../app/l10n/l10n.dart';

class ProspectsPage extends GetView<ProspectsListController> {
  const ProspectsPage({super.key});

  Future<void> _create() async {
    final created = await showProspectFormDialog();
    if (created == null) return;
    AppFeedback.success(tr.prospectCreated(created.companyName));
    await controller.refreshAfterMutation();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.prospects,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => PageHeader(
            title: tr.navProspects,
            subtitle:
                controller.state.isSuccess || controller.page.value.total > 0
                ? tr.countProspects(controller.page.value.total)
                : tr.prospectsSubtitle,
            actions: [
              OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add, size: 18),
                label: Text(tr.newProspect),
              ),
            ],
          ),
        ),
        _FilterBar(controller),
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
                      visible: controller.state.isLoading && !page.isEmpty,
                    ),
                    if (controller.state.hasError && !page.isEmpty)
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
                        isEmpty: page.isEmpty,
                        onRetry: controller.load,
                        empty: EmptyView(
                          icon: Icons.person_search_outlined,
                          title: controller.filter.value.hasActiveFilters
                              ? tr.noProspectMatchesFilters
                              : tr.noProspectsYet,
                          action: controller.filter.value.hasActiveFilters
                              ? OutlinedButton(
                                  onPressed: controller.clearFilters,
                                  child: Text(tr.clearFilters),
                                )
                              : FilledButton.icon(
                                  onPressed: _create,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(tr.addProspect),
                                ),
                        ),
                        builder: (_) => _ProspectsTable(controller),
                      ),
                    ),
                    PaginationBar(
                      page: page,
                      enabled: !controller.state.isLoading,
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

  final ProspectsListController c;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Obx(() {
      final f = c.filter.value;
      final lookups = c.lookups;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SearchField(
            initialValue: f.search,
            hint: tr.prospectSearchHint,
            onChanged: c.setSearch,
          ),
          FilterDropdown<SalesStage>(
            label: tr.fieldStage,
            value: lookups.stageById(f.stageId),
            items: lookups.stages.toList(),
            itemLabel: (s) =>
                s.isActive ? s.name : tr.stageInactiveSuffix(s.name),
            leading: (s) => StageDot(s),
            allLabel: tr.allStages,
            onChanged: (s) => c.setStage(s?.id),
          ),
          FilterDropdown<Product>(
            label: tr.fieldProduct,
            value: lookups.products.firstWhereOrNull(
              (p) => p.id == f.productId,
            ),
            items: lookups.products.toList(),
            itemLabel: (p) => p.name,
            allLabel: tr.allProducts,
            onChanged: (p) => c.setProduct(p?.id),
          ),
          if (c.hasLostStages)
            FilterDropdown<LossReason>(
              label: tr.fieldLossReason,
              value: lookups.lossReasons.firstWhereOrNull(
                (r) => r.id == f.lossReasonId,
              ),
              items: lookups.lossReasons.toList(),
              itemLabel: (r) => r.label,
              allLabel: tr.allReasons,
              onChanged: (r) => c.setLossReason(r?.id),
            ),
          FilterDropdown<CatalogOption>(
            label: tr.fieldSource,
            value: ProspectCatalogs.sources.firstWhereOrNull(
              (o) => o.code == f.source,
            ),
            items: ProspectCatalogs.sources,
            itemLabel: (o) => o.label,
            allLabel: tr.allSources,
            onChanged: (o) => c.setSource(o?.code),
          ),
          FilterDropdown<CatalogOption>(
            label: tr.fieldBusinessActivity,
            value: ProspectCatalogs.businessActivities.firstWhereOrNull(
              (o) => o.code == f.businessActivity,
            ),
            items: ProspectCatalogs.businessActivities,
            itemLabel: (o) => o.label,
            onChanged: (o) => c.setBusinessActivity(o?.code),
          ),
          FilterDropdown<CatalogOption>(
            label: tr.fieldPreviousSoftware,
            value: ProspectCatalogs.previousSoftware.firstWhereOrNull(
              (o) => o.code == f.previousSoftware,
            ),
            items: ProspectCatalogs.previousSoftware,
            itemLabel: (o) => o.label,
            onChanged: (o) => c.setPreviousSoftware(o?.code),
          ),
          DateRangeFilterButton(
            label: tr.filterCreatedDate,
            from: f.createdFrom,
            to: f.createdTo,
            onChanged: c.setCreatedRange,
          ),
          if (f.hasActiveFilters)
            TextButton.icon(
              onPressed: c.clearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: Text(tr.actionReset),
            ),
          if (lookups.lastError.value != null)
            Tooltip(
              message: tr.filtersUnavailable(lookups.lastError.value!.message),
              child: IconButton(
                icon: Icon(
                  Icons.warning_amber_rounded,
                  color: context.crm.warning,
                ),
                onPressed: lookups.refreshQuietly,
              ),
            ),
        ],
      );
    }),
  );
}

class _ProspectsTable extends StatelessWidget {
  const _ProspectsTable(this.c);

  final ProspectsListController c;

  Future<void> _open(Prospect p) async {
    await AppNavigation.openProspect(p.id);
    // Details may have changed the prospect (stage, activities...).
    await c.load();
  }

  Future<void> _edit(Prospect p) async {
    final saved = await showProspectFormDialog(initial: p);
    if (saved == null) return;
    AppFeedback.success(tr.prospectUpdated);
    await c.refreshAfterMutation();
  }

  Future<void> _changeStage(Prospect p) async {
    final updated = await showStageChangeDialog(p);
    if (updated == null) return;
    AppFeedback.success(
      tr.prospectMovedTo(updated.companyName, updated.stage?.name ?? ''),
    );
    await c.refreshAfterMutation();
  }

  Future<void> _addActivity(Prospect p) async {
    final result = await showActivityFormDialog(prospect: p.toRef());
    if (result != null) await c.refreshAfterMutation();
  }

  Future<void> _scheduleFollowUp(Prospect p) async {
    final saved = await showFollowUpFormDialog(prospect: p.toRef());
    if (saved != null) await c.refreshAfterMutation();
  }

  @override
  Widget build(BuildContext context) {
    final f = c.filter.value;
    final now = DateTime.now();
    return CrmDataTable<Prospect>(
      rows: c.page.value.items,
      sortKey: f.sort,
      ascending: f.ascending,
      onSort: (key) => c.sortBy(key as ProspectSort),
      onRowTap: _open,
      rowHeight: 58,
      columns: [
        CrmColumn(
          label: tr.colCompanyContact,
          flex: 3,
          sortKey: ProspectSort.companyName,
          cell: (p) =>
              CellText(p.companyName, secondary: p.contactName, bold: true),
        ),
        CrmColumn(
          label: tr.colContactDetails,
          flex: 3,
          cell: (p) => CellText(p.phone ?? '', secondary: p.email),
        ),
        CrmColumn(
          label: tr.fieldCity,
          flex: 2,
          sortKey: ProspectSort.city,
          cell: (p) => CellText(p.city ?? ''),
        ),
        CrmColumn(
          label: tr.fieldStage,
          flex: 3,
          cell: (p) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StageChip(stage: p.stage, dense: true),
              if (p.isLost && p.lossReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    p.lossReason!.label,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.crm.danger,
                    ),
                  ),
                ),
            ],
          ),
        ),
        CrmColumn(
          label: tr.navProducts,
          flex: 3,
          cell: (p) => ProductChips(products: p.products, max: 2),
        ),
        CrmColumn(
          label: tr.colLastActivity,
          width: 170,
          cell: (p) {
            final at = p.lastActivityAt;
            if (at == null) return const CellText('');
            return CellText(
              Formatters.date(at),
              secondary: Formatters.relative(at),
            );
          },
        ),
        CrmColumn(
          label: tr.colNextFollowUp,
          width: 170,
          cell: (p) {
            final next = p.nextFollowUpAt;
            if (next == null) return const CellText('');
            final overdue = p.isNextFollowUpOverdue(now);
            return Row(
              children: [
                if (overdue) ...[
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: context.crm.danger,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: CellText(
                    Formatters.dateTime(next),
                    secondary: overdue
                        ? tr.followUpViewOverdue
                        : Formatters.relative(next),
                    color: overdue ? context.crm.danger : null,
                  ),
                ),
              ],
            );
          },
        ),
        CrmColumn(
          label: tr.colCreatedOn,
          width: 96,
          sortKey: ProspectSort.createdAt,
          cell: (p) => CellText(Formatters.date(p.createdAt)),
        ),
        CrmColumn(
          label: '',
          width: 116,
          alignment: AlignmentDirectional.centerEnd,
          cell: (p) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: tr.changeStage,
                icon: const Icon(Icons.swap_horiz, size: 20),
                onPressed: () => _changeStage(p),
              ),
              PopupMenuButton<String>(
                tooltip: tr.colActions,
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (action) => switch (action) {
                  'open' => _open(p),
                  'edit' => _edit(p),
                  'stage' => _changeStage(p),
                  'activity' => _addActivity(p),
                  'followup' => _scheduleFollowUp(p),
                  _ => null,
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'open',
                    child: ListTile(
                      leading: Icon(Icons.open_in_new),
                      title: Text(tr.actionOpenRecord),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text(tr.actionEdit),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'stage',
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz),
                      title: Text(tr.changeStage),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'activity',
                    child: ListTile(
                      leading: Icon(Icons.add_comment_outlined),
                      title: Text(tr.addActivity),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'followup',
                    child: ListTile(
                      leading: Icon(Icons.event_available_outlined),
                      title: Text(tr.scheduleFollowUp),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
