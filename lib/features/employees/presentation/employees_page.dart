import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/l10n/l10n.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_shell.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/layout_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/workflow_widgets.dart';
import '../data/models/employee_session.dart';
import 'employees_controller.dart';

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
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ),
          ],
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
                    Expanded(flex: 4, child: list),
                    const SizedBox(width: 16),
                    Expanded(flex: 6, child: detail),
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

class _EmployeeList extends StatelessWidget {
  const _EmployeeList(this.c);

  final EmployeesController c;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Obx(() {
      final employees = c.overview.value.employees;
      return LoadStateView(
        state: c.state,
        isEmpty: employees.isEmpty,
        onRetry: c.load,
        empty: EmptyView(
          icon: Icons.badge_outlined,
          title: tr.wfNoEmployees,
          message: tr.wfNoEmployeesHint,
        ),
        builder: (_) => ListView.separated(
          itemCount: employees.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final e = employees[i];
            final selected = c.selected.value?.employeeId == e.employeeId;
            return ListTile(
              selected: selected,
              leading: CircleAvatar(
                backgroundColor:
                    (e.isOnline ? context.crm.success : context.colors.outline)
                        .withValues(alpha: 0.15),
                child: Icon(
                  Icons.person_outline,
                  color: e.isOnline
                      ? context.crm.success
                      : context.colors.outline,
                ),
              ),
              title: Text(e.username),
              subtitle: Text(
                joinNonEmpty([
                  e.deviceName,
                  Formatters.relative(e.lastActivity),
                ]),
              ),
              trailing: StatusBadge(
                label: _statusLabel(e),
                color: e.isOnline
                    ? context.crm.success
                    : context.colors.outline,
              ),
              onTap: () => c.select(e),
            );
          },
        ),
      );
    }),
  );

  static String _statusLabel(EmployeeSession e) =>
      switch (e.status.toLowerCase()) {
        'online' => tr.connOnline,
        'idle' => tr.wfIdle,
        _ => tr.connOffline,
      };
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
          icon: Icons.touch_app_outlined,
          title: tr.wfSelectEmployee,
        ),
      );
    }
    return ListView(
      children: [
        SectionCard(
          title: tr.wfAssignedAppointments(employee.username),
          icon: Icons.event_outlined,
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
          title: tr.wfAssignedInterventions(employee.username),
          icon: Icons.build_circle_outlined,
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
