import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_crm/core/widgets/whatsapp_button.dart';

import '../../../../app/l10n/l10n.dart';
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
import '../../data/models/follow_up.dart';
import '../controllers/follow_ups_controller.dart';
import '../dialogs/follow_up_dialogs.dart';
import '../widgets/follow_up_widgets.dart';

class FollowUpsPage extends GetView<FollowUpsController> {
  const FollowUpsPage({super.key});

  Future<void> _after(Future<FollowUp?> action) async {
    if (await action != null) await controller.refreshAfterMutation();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.followUps,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: tr.navFollowUps,
          subtitle: tr.followUpsSubtitle,
          actions: [
            Obx(
              () => OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.refreshAfterMutation,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _after(showFollowUpFormDialog()),
              icon: const Icon(Icons.add, size: 18),
              label: Text(tr.scheduleFollowUp),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ViewTabs(controller),
              SearchField(
                initialValue: controller.search.value,
                hint: tr.followUpSearchHint,
                onChanged: controller.setSearch,
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
                final page = controller.page.value;
                final view = controller.view.value;
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
                          icon: view == FollowUpView.overdue
                              ? Icons.celebration_outlined
                              : Icons.event_available_outlined,
                          title: switch (view) {
                            FollowUpView.today => tr.noFollowUpsToday,
                            FollowUpView.overdue => tr.noFollowUpsOverdue,
                            FollowUpView.upcoming => tr.noFollowUpsUpcoming,
                            FollowUpView.completed => tr.noFollowUpsDone,
                            FollowUpView.cancelled => tr.noFollowUpsCancelled,
                          },
                        ),
                        builder: (_) => _FollowUpsTable(
                          items: page.items,
                          onComplete: (f) => _after(showCompleteFollowUpDialog(f)),
                          onEdit: (f) => _after(showFollowUpFormDialog(existing: f)),
                          onCancel: (f) => _after(showCancelFollowUpDialog(f)),
                        ),
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

class _ViewTabs extends StatelessWidget {
  const _ViewTabs(this.c);

  final FollowUpsController c;

  @override
  Widget build(BuildContext context) => Obx(() {
    final crm = context.crm;
    return SegmentedButton<FollowUpView>(
      showSelectedIcon: false,
      segments: [
        for (final v in FollowUpView.values)
          ButtonSegment(
            value: v,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(v.label),
                if (c.counts[v] != null && c.counts[v]! > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: v == FollowUpView.overdue ? crm.danger : context.colors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${c.counts[v]}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
      selected: {c.view.value},
      onSelectionChanged: (s) => c.setView(s.first),
    );
  });
}

class _FollowUpsTable extends StatelessWidget {
  const _FollowUpsTable({required this.items, required this.onComplete, required this.onEdit, required this.onCancel});

  final List<FollowUp> items;
  final ValueChanged<FollowUp> onComplete;
  final ValueChanged<FollowUp> onEdit;
  final ValueChanged<FollowUp> onCancel;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    return CrmDataTable<FollowUp>(
      rows: items,
      rowHeight: 60,
      highlight: (f) => f.isOverdue() ? crm.dangerContainer.withValues(alpha: 0.45) : null,
      onRowTap: (f) {
        if (f.prospect != null) AppNavigation.openProspect(f.prospect!.id);
      },
      columns: [
        CrmColumn(
          label: tr.colDueDate,
          width: 170,
          cell: (f) {
            final overdue = f.isOverdue();
            return Row(
              children: [
                if (overdue) ...[
                  Icon(Icons.warning_amber_rounded, size: 18, color: crm.danger),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: CellText(
                    Formatters.dateTime(f.dueAt),
                    secondary: Formatters.relative(f.dueAt),
                    bold: overdue,
                    color: overdue ? crm.danger : null,
                  ),
                ),
              ],
            );
          },
        ),
        CrmColumn(
          label: tr.colProspect,
          flex: 3,
          cell: (f) => Row(
            children: [
              CellText(
                f.prospect?.companyName ?? '',
                secondary: [f.prospect?.contactName, f.prospect?.phone].whereType<String>().join(' · '),
                bold: true,
              ),
              const SizedBox(width: 15),
              if (f.prospect?.phone != null)
                WhatsAppIconButton(phone: f.prospect!.phone, message: f.description, size: 28, iconSize: 23),
            ],
          ),
        ),
        CrmColumn(label: tr.fieldType, width: 140, cell: (f) => FollowUpTypeLabel(f)),
        CrmColumn(
          label: tr.fieldDescription,
          flex: 5,
          cell: (f) =>
              Text(f.description ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodyMedium),
        ),
        CrmColumn(label: tr.colStatus, width: 120, cell: (f) => FollowUpStatusPill(f)),
        CrmColumn(
          label: '',
          width: 212,
          alignment: AlignmentDirectional.centerEnd,
          cell: (f) => !f.isPending
              ? const SizedBox.shrink()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: tr.markAsDone,
                      icon: Icon(Icons.task_alt, color: crm.success),
                      onPressed: () => onComplete(f),
                    ),
                    IconButton(
                      tooltip: tr.actionEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => onEdit(f),
                    ),
                    IconButton(
                      tooltip: tr.actionCancel,
                      icon: const Icon(Icons.event_busy_outlined, size: 20),
                      onPressed: () => onCancel(f),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
