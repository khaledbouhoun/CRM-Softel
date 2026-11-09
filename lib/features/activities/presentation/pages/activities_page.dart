import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/models/activity.dart';
import '../../data/models/activity_type.dart';
import '../controllers/activities_controller.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../dialogs/activity_details_dialog.dart';
import '../dialogs/activity_form_dialog.dart';
import '../dialogs/link_activity_flow.dart';
import '../widgets/activity_widgets.dart';
import '../../../../app/l10n/l10n.dart';

class ActivitiesPage extends GetView<ActivitiesController> {
  const ActivitiesPage({super.key});

  Future<void> _create() async {
    final result = await showActivityFormDialog();
    if (result != null) await controller.load();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.activities,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => PageHeader(
            title: tr.navActivities,
            subtitle: controller.page.value.total > 0
                ? tr.activitiesCountSubtitle(controller.page.value.total)
                : tr.activitiesSubtitle,
            actions: [
              OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add, size: 18),
                label: Text(tr.newActivity),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Obx(() {
            final f = controller.filter.value;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SearchField(
                  initialValue: f.search,
                  hint: tr.activitySearchHint,
                  onChanged: controller.setSearch,
                ),
                FilterDropdown<ActivityType>(
                  label: tr.fieldType,
                  value: f.type,
                  items: ActivityType.selectable,
                  itemLabel: (t) => t.label,
                  leading: (t) =>
                      Icon(activityIcon(t), size: 16, color: activityColor(t)),
                  allLabel: tr.allTypes,
                  onChanged: controller.setType,
                ),
                FilterDropdown<bool>(
                  label: tr.colLink,
                  value: f.linked,
                  items: const [true, false],
                  itemLabel: (linked) => linked
                      ? tr.filterLinkOnlyLinked
                      : tr.filterLinkOnlyUnlinked,
                  allLabel: tr.filterLinkAll,
                  width: 230,
                  onChanged: controller.setLinked,
                ),
                DateRangeFilterButton(
                  label: tr.period,
                  from: f.dateFrom,
                  to: f.dateTo,
                  onChanged: controller.setDateRange,
                ),
                if (f.hasActiveFilters)
                  TextButton.icon(
                    onPressed: controller.clearFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                    label: Text(tr.actionReset),
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
                          icon: Icons.history_toggle_off,
                          title: controller.filter.value.hasActiveFilters
                              ? tr.noActivityMatchesFilters
                              : tr.noActivities,
                        ),
                        builder: (_) =>
                            _ActivitiesTable(page.items, controller),
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

class _ActivitiesTable extends StatelessWidget {
  const _ActivitiesTable(this.items, this.controller);

  final List<Activity> items;
  final ActivitiesController controller;

  Future<void> _details(Activity a) async {
    final updated = await showActivityDetailsDialog(a);
    if (updated != null) controller.replaceActivity(updated);
  }

  Future<void> _link(Activity a) async {
    final updated = await linkActivityToProspect(a);
    if (updated != null) controller.replaceActivity(updated);
  }

  @override
  Widget build(BuildContext context) => CrmDataTable<Activity>(
    rows: items,
    rowHeight: 64,
    onRowTap: _details,
    columns: [
      CrmColumn(
        label: tr.colDate,
        width: 120,
        cell: (a) => CellText(
          Formatters.date(a.occurredAt),
          secondary: Formatters.time(a.occurredAt),
        ),
      ),
      CrmColumn(
        label: tr.fieldType,
        width: 150,
        cell: (a) => Row(
          children: [
            ActivityTypeAvatar(a.type, size: 26),
            const SizedBox(width: 8),
            Expanded(child: CellText(a.type.label)),
          ],
        ),
      ),
      CrmColumn(
        label: tr.colTitle,
        flex: 5,
        cell: (a) => Tooltip(
          message: a.description.isEmpty ? a.headline : a.description,
          waitDuration: const Duration(milliseconds: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (a.title != null && a.description.trim().isNotEmpty)
                Text(
                  a.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
      CrmColumn(
        label: tr.colLink,
        flex: 4,
        cell: (a) => a.prospect == null
            ? const Align(
                alignment: AlignmentDirectional.centerStart,
                child: ActivityLinkPill(linked: false),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.prospect!.companyName.isEmpty
                        ? tr.prospectNumber(a.prospect!.id)
                        : a.prospect!.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (a.prospect!.stage != null)
                    StageChip(stage: a.prospect!.stage, dense: true),
                ],
              ),
      ),
      CrmColumn(
        label: tr.colActions,
        width: 120,
        cell: (a) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (a.prospect == null)
              IconButton(
                tooltip: tr.linkToProspect,
                icon: const Icon(Icons.add_link, size: 20),
                onPressed: () => _link(a),
              )
            else ...[
              IconButton(
                tooltip: tr.openProspect,
                icon: const Icon(Icons.open_in_new, size: 19),
                onPressed: () => AppNavigation.openProspect(a.prospect!.id),
              ),
              if (!a.isFromFollowUp)
                IconButton(
                  tooltip: tr.changeLinkedProspect,
                  icon: const Icon(Icons.link, size: 20),
                  onPressed: () => _link(a),
                ),
            ],
          ],
        ),
      ),
    ],
  );
}
