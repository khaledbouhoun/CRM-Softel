import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/whatsapp_launcher.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/phone_cell.dart';
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
import '../../../settings/data/models/prospect_form_option.dart';
import '../../data/models/prospect_catalogs.dart';
import '../../data/models/prospect_filter.dart';
import '../controllers/prospects_list_controller.dart';
import '../dialogs/prospect_dialogs.dart';

import 'package:hugeicons/hugeicons.dart';
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
            subtitle: controller.state.isSuccess || controller.page.value.total > 0
                ? tr.countProspects(controller.page.value.total)
                : tr.prospectsSubtitle,
            actions: [
              OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
              FilledButton.icon(onPressed: _create, icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18), label: Text(tr.newProspect)),
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
                    RefreshingBar(visible: controller.state.isLoading && !page.isEmpty),
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
                          icon: HugeIcons.strokeRoundedUserSearch01,
                          title: controller.filter.value.hasActiveFilters
                              ? tr.noProspectMatchesFilters
                              : tr.noProspectsYet,
                          action: controller.filter.value.hasActiveFilters
                              ? OutlinedButton(onPressed: controller.clearFilters, child: Text(tr.clearFilters))
                              : FilledButton.icon(
                                  onPressed: _create,
                                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18),
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

  /// Filter choices come from the configurable form options (database); the
  /// built-in catalog is only a fallback while they are empty or unreachable.
  /// Inactive options stay selectable because existing prospects may still
  /// hold them. A legacy value that matches no option is kept visible.
  static List<CatalogOption> _options(
    LookupService lookups,
    String type,
    List<CatalogOption> fallback,
    String? selected,
  ) {
    final db = lookups.prospectFormOptions.where((o) => o.type == type).toList()
      ..sort((a, b) => a.sortOrder != b.sortOrder ? a.sortOrder.compareTo(b.sortOrder) : a.name.compareTo(b.name));
    if (db.isEmpty) return fallback;
    final options = [for (final o in db) CatalogOption(o.name, () => o.name)];
    if (selected != null && !options.any((o) => o.code == selected)) {
      options.add(CatalogOption(selected, () => selected));
    }
    return options;
  }

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
          SearchField(initialValue: f.search, hint: tr.prospectSearchHint, onChanged: c.setSearch),
          SegmentedButton<ProspectConvertedFilter>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: ProspectConvertedFilter.activeOnly, label: Text(tr.filterActiveLeads)),
              ButtonSegment(value: ProspectConvertedFilter.all, label: Text(tr.filterAllLeads)),
              ButtonSegment(value: ProspectConvertedFilter.convertedOnly, label: Text(tr.filterConvertedLeads)),
            ],
            selected: {f.converted},
            onSelectionChanged: (v) => c.setConverted(v.first),
          ),
          FilterDropdown<SalesStage>(
            label: tr.fieldStage,
            value: lookups.stageById(f.stageId),
            items: lookups.stages.toList(),
            itemLabel: (s) => s.isActive ? s.name : tr.stageInactiveSuffix(s.name),
            leading: (s) => StageDot(s),
            allLabel: tr.allStages,
            onChanged: (s) => c.setStage(s?.id),
          ),
          FilterDropdown<Product>(
            label: tr.fieldProduct,
            value: lookups.products.firstWhereOrNull((p) => p.id == f.productId),
            items: lookups.products.toList(),
            itemLabel: (p) => p.name,
            allLabel: tr.allProducts,
            onChanged: (p) => c.setProduct(p?.id),
          ),
          if (c.hasLostStages)
            FilterDropdown<LossReason>(
              label: tr.fieldLossReason,
              value: lookups.lossReasons.firstWhereOrNull((r) => r.id == f.lossReasonId),
              items: lookups.lossReasons.toList(),
              itemLabel: (r) => r.label,
              allLabel: tr.allReasons,
              onChanged: (r) => c.setLossReason(r?.id),
            ),
          FilterDropdown<CatalogOption>(
            label: tr.fieldSource,
            value: _options(lookups, ProspectFormOption.typeSource, ProspectCatalogs.sources, f.source)
                .firstWhereOrNull((o) => o.code == f.source),
            items: _options(lookups, ProspectFormOption.typeSource, ProspectCatalogs.sources, f.source),
            itemLabel: (o) => o.label,
            allLabel: tr.allSources,
            onChanged: (o) => c.setSource(o?.code),
          ),
          FilterDropdown<CatalogOption>(
            label: tr.fieldBusinessActivity,
            value: _options(lookups, ProspectFormOption.typeBusinessActivity, ProspectCatalogs.businessActivities, f.businessActivity)
                .firstWhereOrNull((o) => o.code == f.businessActivity),
            items: _options(lookups, ProspectFormOption.typeBusinessActivity, ProspectCatalogs.businessActivities, f.businessActivity),
            itemLabel: (o) => o.label,
            onChanged: (o) => c.setBusinessActivity(o?.code),
          ),
          FilterDropdown<CatalogOption>(
            label: tr.fieldPreviousSoftware,
            value: _options(lookups, ProspectFormOption.typePreviousSoftware, ProspectCatalogs.previousSoftware, f.previousSoftware)
                .firstWhereOrNull((o) => o.code == f.previousSoftware),
            items: _options(lookups, ProspectFormOption.typePreviousSoftware, ProspectCatalogs.previousSoftware, f.previousSoftware),
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
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedFilterRemove, size: 18),
              label: Text(tr.actionReset),
            ),
          if (lookups.lastError.value != null)
            Tooltip(
              message: tr.filtersUnavailable(lookups.lastError.value!.message),
              child: IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedAlert02, color: context.crm.warning),
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
    AppFeedback.success(tr.prospectMovedTo(updated.companyName, updated.stage?.name ?? ''));
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
          flex: 4,
          sortKey: ProspectSort.companyName,
          cell: (p) => CellText(p.companyName, secondary: p.contactName, bold: true),
        ),
        CrmColumn(
          label: tr.colContactDetails,
          flex: 4,
          sortKey: ProspectSort.phone,
          cell: (p) => PhoneCell(p.phone),
        ),
        CrmColumn(label: tr.fieldCity, flex: 2, sortKey: ProspectSort.city, cell: (p) => CellText(p.city ?? '')),
        CrmColumn(
          label: tr.fieldStage,
          flex: 3,
          sortKey: ProspectSort.stage,
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
                    style: context.text.bodySmall?.copyWith(color: context.crm.danger),
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
            return CellText(Formatters.date(at), secondary: Formatters.relative(at));
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
                  HugeIcon(icon: HugeIcons.strokeRoundedAlert02, size: 16, color: context.crm.danger),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: CellText(
                    Formatters.dateTime(next),
                    secondary: overdue ? tr.followUpViewOverdue : Formatters.relative(next),
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
          width: 112,
          alignment: AlignmentDirectional.centerEnd,
          cell: (p) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // if (WhatsAppLauncher.isValid(p.phone)) WhatsAppIconButton(phone: p.phone),

              IconButton(
                tooltip: tr.changeStage,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeftRight, size: 20),
                onPressed: () => _changeStage(p),
              ),
              PopupMenuButton<String>(
                tooltip: tr.colActions,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedMoreVertical, size: 20),
                onSelected: (action) => switch (action) {
                  'open' => _open(p),
                  'whatsapp' => WhatsAppLauncher.launch(p.phone),
                  'edit' => _edit(p),
                  'stage' => _changeStage(p),
                  'activity' => _addActivity(p),
                  'followup' => _scheduleFollowUp(p),
                  _ => null,
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'open',
                    child: ListTile(leading: HugeIcon(icon: HugeIcons.strokeRoundedLinkSquare02), title: Text(tr.actionOpenRecord)),
                  ),
                  if (WhatsAppLauncher.isValid(p.phone))
                    PopupMenuItem(
                      value: 'whatsapp',
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.whatsapp, size: 20, color: WhatsAppLauncher.brandColor),
                        title: Text(WhatsAppLauncher.tooltip),
                      ),
                    ),
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(leading: HugeIcon(icon: HugeIcons.strokeRoundedEdit02), title: Text(tr.actionEdit)),
                  ),
                  PopupMenuItem(
                    value: 'stage',
                    child: ListTile(leading: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeftRight), title: Text(tr.changeStage)),
                  ),
                  PopupMenuItem(
                    value: 'activity',
                    child: ListTile(leading: HugeIcon(icon: HugeIcons.strokeRoundedMessageAdd01), title: Text(tr.addActivity)),
                  ),
                  PopupMenuItem(
                    value: 'followup',
                    child: ListTile(leading: HugeIcon(icon: HugeIcons.strokeRoundedCalendarCheck01), title: Text(tr.scheduleFollowUp)),
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
