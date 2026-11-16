# -*- coding: utf-8 -*-
"""Activities list: linked filter, link/open actions, details dialog."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import add_many, edit  # noqa: E402

FU = 'lib/features/follow_ups/data/models/follow_up.dart'
edit(FU, """        if (clean(description, 5000) != null) 'activity_description': clean(description, 5000),
        if (clean(outcome, 5000) != null) 'activity_outcome': clean(outcome, 5000),
        if (occurredAt != null) 'activity_at': toApiDateTime(occurredAt!),
        if (fallbackType != null) 'activity_type': fallbackType!.apiValue,""",
     """        'activity_description': ?clean(description, 5000),
        'activity_outcome': ?clean(outcome, 5000),
        if (occurredAt != null) 'activity_at': toApiDateTime(occurredAt!),
        'activity_type': ?fallbackType?.apiValue,""")

AC = 'lib/features/activities/presentation/controllers/activities_controller.dart'
edit(AC, "  void setDateRange(", "  /// true = linked only, false = unlinked only, null = all.\n  void setLinked(bool? linked) =>\n      _apply(filter.value.copyWith(linked: linked, page: 1));\n\n  /// Replaces one row after the server confirmed a change (e.g. a link).\n  void replaceActivity(Activity updated) {\n    final items = [for (final a in page.value.items) a.id == updated.id ? updated : a];\n    page.value = page.value.copyWith(items: items);\n  }\n\n  void setDateRange(")

PG = 'lib/features/activities/presentation/pages/activities_page.dart'
edit(PG, """                DateRangeFilterButton(
                  label: tr.period,""", """                FilterDropdown<bool>(
                  label: tr.colLink,
                  value: f.linked,
                  items: const [true, false],
                  itemLabel: (linked) => linked ? tr.filterLinkOnlyLinked : tr.filterLinkOnlyUnlinked,
                  allLabel: tr.filterLinkAll,
                  width: 230,
                  onChanged: controller.setLinked,
                ),
                DateRangeFilterButton(
                  label: tr.period,""")
edit(PG, "                  items: ActivityType.values,", "                  items: ActivityType.selectable,")
edit(PG, "                        builder: (_) => _ActivitiesTable(page.items),", "                        builder: (_) => _ActivitiesTable(page.items, controller),")

src = open(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), PG), encoding='utf-8').read()
start = src.index('class _ActivitiesTable')
table = '''class _ActivitiesTable extends StatelessWidget {
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
        cell: (a) => CellText(Formatters.date(a.occurredAt), secondary: Formatters.time(a.occurredAt)),
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
                style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (a.title != null && a.description.trim().isNotEmpty)
                Text(
                  a.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
      CrmColumn(
        label: tr.colLink,
        flex: 4,
        cell: (a) => a.prospect == null
            ? const Align(alignment: AlignmentDirectional.centerStart, child: ActivityLinkPill(linked: false))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.prospect!.companyName.isEmpty ? tr.prospectNumber(a.prospect!.id) : a.prospect!.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (a.prospect!.stage != null) StageChip(stage: a.prospect!.stage, dense: true),
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
'''
open(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), PG), 'w', encoding='utf-8', newline='\n').write(src[:start] + table)
edit(PG, "import '../dialogs/activity_form_dialog.dart';",
     "import '../../../settings/presentation/widgets/stage_widgets.dart';\nimport '../dialogs/activity_details_dialog.dart';\nimport '../dialogs/activity_form_dialog.dart';\nimport '../dialogs/link_activity_flow.dart';")
print('ui1 ok')
