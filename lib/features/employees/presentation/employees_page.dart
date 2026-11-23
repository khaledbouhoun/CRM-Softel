import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/l10n/l10n.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_shell.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/huge_data.dart';
import '../../../core/widgets/layout_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/workflow_widgets.dart';
import '../data/employee_options.dart';
import '../data/models/employee_session.dart';
import 'employees_controller.dart';
import 'workstation_dialog.dart';

import 'package:hugeicons/hugeicons.dart';
class EmployeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => EmployeesController(
        employees: Get.find(),
        scheduling: Get.find(),
        interventions: Get.find(),
      ),
    );
  }
}

/// Employees and the work assigned to each of them.
class EmployeesPage extends GetView<EmployeesController> {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.employees,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: tr.navEmployees,
          subtitle: tr.wfEmployeesSubtitle,
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
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 12),
          child: _SummaryRow(controller),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final list = _EmployeeList(controller);
                final detail = _Workload(controller);
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      Expanded(child: list),
                      const SizedBox(height: 12),
                      Expanded(child: detail),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 6, child: list),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: detail),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.c);

  final EmployeesController c;

  @override
  Widget build(BuildContext context) => Obx(() {
    final o = c.overview.value;
    final tiles = [
      _Metric(
        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
        color: context.crm.success,
        label: tr.empOnlineNow,
        value: o.activeCount,
      ),
      _Metric(
        icon: EmployeeRole.sales.icon,
        color: EmployeeRole.sales.color,
        label: tr.empSalesActive,
        value: o.salesOnline,
      ),
      _Metric(
        icon: EmployeeRole.support.icon,
        color: EmployeeRole.support.color,
        label: tr.empSupportActive,
        value: o.supportOnline,
      ),
      _Metric(
        icon: HugeIcons.strokeRoundedChartIncrease,
        color: context.colors.primary,
        label: tr.empTeamActionsToday,
        value: o.teamActionsToday,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final t in tiles) SizedBox(width: width, child: t)],
        );
      },
    );
  });
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final HugeData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: HugeIcon(icon: icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmployeeList extends StatelessWidget {
  const _EmployeeList(this.c);

  final EmployeesController c;

  @override
  Widget build(BuildContext context) => Obx(() {
    final employees = c.overview.value.employees;
    final selectedId = c.selected.value?.employeeId;
    return LoadStateView(
      state: c.state,
      isEmpty: employees.isEmpty,
      onRetry: c.load,
      empty: EmptyView(
        icon: HugeIcons.strokeRoundedId,
        title: tr.wfNoEmployees,
        message: tr.wfNoEmployeesHint,
      ),
      builder: (_) => SingleChildScrollView(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final e in employees)
              SizedBox(
                width: 320,
                child: _WorkstationCard(
                  employee: e,
                  selected: selectedId == e.employeeId,
                  onTap: () => c.select(e),
                  onEdit: () => showWorkstationDialog(c, e),
                ),
              ),
          ],
        ),
      ),
    );
  });
}

class _WorkstationCard extends StatelessWidget {
  const _WorkstationCard({
    required this.employee,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  final EmployeeSession employee;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  static String _statusLabel(EmployeeSession e) =>
      switch (e.status.toLowerCase()) {
        'online' => tr.connOnline,
        'idle' => tr.wfIdle,
        _ => tr.connOffline,
      };

  @override
  Widget build(BuildContext context) {
    final e = employee;
    final role = EmployeeRole.parse(e.role);
    final presence = EmployeePresence.parse(e.presenceStatus);
    final dot = switch (e.status.toLowerCase()) {
      'online' => presence == EmployeePresence.available
          ? context.crm.success
          : presence.color(context),
      'idle' => context.crm.warning,
      _ => context.colors.outline,
    };
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: selected ? context.colors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusDot(color: dot, pulsing: e.isOnline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: tr.empEditWorkstation,
                    visualDensity: VisualDensity.compact,
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit01,
                      size: 18,
                    ),
                    onPressed: onEdit,
                  ),
                ],
              ),
              if ((e.customName ?? '').trim().isNotEmpty)
                Text(
                  '${e.username}@${e.deviceName ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusBadge(
                    label: role.label,
                    color: role.color,
                    icon: role.icon,
                  ),
                  StatusBadge(
                    label: e.isOnline ? presence.label : _statusLabel(e),
                    color: e.isOnline ? presence.color(context) : dot,
                    icon: e.isOnline ? presence.icon : null,
                  ),
                ],
              ),
              if ((e.statusNote ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  e.statusNote!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                joinNonEmpty([e.ipAddress, Formatters.relative(e.lastActivity)]),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tr.empActionsToday,
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusBadge(
                    label: tr.empFollowUpsCount(e.activitiesToday),
                    color: context.colors.primary,
                    icon: HugeIcons.strokeRoundedCall,
                  ),
                  StatusBadge(
                    label: tr.empTicketsCount(e.interventionsToday),
                    color: EmployeeRole.support.color,
                    icon: HugeIcons.strokeRoundedCustomerService,
                  ),
                  StatusBadge(
                    label: tr.empAppointmentsCount(e.appointmentsToday),
                    color: context.crm.success,
                    icon: HugeIcons.strokeRoundedCalendar01,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status dot; online workstations get a soft pulsing halo.
class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.color, required this.pulsing});

  final Color color;
  final bool pulsing;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulsing) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_StatusDot old) {
    super.didUpdateWidget(old);
    if (widget.pulsing && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.pulsing && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _pulse,
    builder: (_, _) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: widget.pulsing
            ? [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.45 * (1 - _pulse.value)),
                  blurRadius: 2 + 6 * _pulse.value,
                  spreadRadius: 4 * _pulse.value,
                ),
              ]
            : null,
      ),
    ),
  );
}

class _Workload extends StatelessWidget {
  const _Workload(this.c);

  final EmployeesController c;

  @override
  Widget build(BuildContext context) => Obx(() {
    final employee = c.selected.value;
    if (employee == null) {
      return Card(
        child: EmptyView(
          icon: HugeIcons.strokeRoundedTouchInteraction01,
          title: tr.wfSelectEmployee,
        ),
      );
    }
    return ListView(
      children: [
        SectionCard(
          title: tr.wfAssignedAppointments(employee.displayName),
          icon: HugeIcons.strokeRoundedCalendar01,
          child: LoadStateView(
            state: c.workloadState,
            compact: true,
            isEmpty: c.appointments.isEmpty,
            onRetry: c.loadWorkload,
            empty: EmptyView(compact: true, title: tr.wfNothingAssigned),
            builder: (_) => Column(
              children: [
                for (final item in c.appointments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: CalendarEventCard(item: item),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: tr.wfAssignedInterventions(employee.displayName),
          icon: HugeIcons.strokeRoundedWrench01,
          child: LoadStateView(
            state: c.workloadState,
            compact: true,
            isEmpty: c.interventions.isEmpty,
            onRetry: c.loadWorkload,
            empty: EmptyView(compact: true, title: tr.wfNothingAssigned),
            builder: (_) => Column(
              children: [
                for (final i in c.interventions)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${i.reference} · ${i.title}'),
                    subtitle: Text(
                      joinNonEmpty([i.type?.name, i.product?.name]),
                    ),
                    trailing: PriorityChip(priority: i.priority),
                    onTap: () => Get.toNamed(Routes.afterSalesDetail(i.id)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  });
}
