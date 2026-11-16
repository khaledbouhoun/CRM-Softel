import 'package:get/get.dart';

import '../../../core/state/load_state.dart';
import '../../interventions/data/models/intervention.dart';
import '../../interventions/domain/interventions_repository.dart';
import '../../scheduling/data/models/calendar_item.dart';
import '../../scheduling/domain/scheduling_repository.dart';
import '../data/employees_repository.dart';
import '../data/models/employee_session.dart';

/// Employees known to the CRM (heartbeat) with their workload: upcoming
/// appointments and open interventions assigned to them. There is no role
/// or permission here: every employee has the same access.
class EmployeesController extends GetxController {
  EmployeesController({
    required EmployeesRepository employees,
    required SchedulingRepository scheduling,
    required InterventionsRepository interventions,
    this.horizonDays = 30,
    DateTime Function()? clock,
  }) : _employees = employees,
       _scheduling = scheduling,
       _interventions = interventions,
       _clock = clock ?? DateTime.now;

  final EmployeesRepository _employees;
  final SchedulingRepository _scheduling;
  final InterventionsRepository _interventions;
  final DateTime Function() _clock;

  /// How far ahead the assigned appointments are listed.
  final int horizonDays;

  final overview = const EmployeesOverview().obs;
  final state = LoadState();

  final selected = Rxn<EmployeeSession>();
  final appointments = <CalendarItem>[].obs;
  final interventions = <Intervention>[].obs;
  final workloadState = LoadState();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    overview.value = await _employees.getEmployees();
    final current = selected.value;
    if (current != null) {
      selected.value = overview.value.employees
          .where((e) => e.employeeId == current.employeeId)
          .firstOrNull;
    }
  });

  Future<void> select(EmployeeSession? employee) async {
    selected.value = employee;
    appointments.clear();
    interventions.clear();
    if (employee == null) return;
    await loadWorkload();
  }

  /// Loads the work assigned to the selected employee. Assignments use the
  /// employee's username (the `assigned_employee` label).
  Future<void> loadWorkload() async {
    final employee = selected.value;
    if (employee == null) return;
    final name = employee.username;
    final now = _clock();
    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(Duration(days: horizonDays));
    await workloadState.run(() async {
      // Both requests start together; each one is awaited below.
      final calendarRequest = _scheduling.getCalendar(
        from,
        to,
        CalendarFilter(employee: name, kinds: const [CalendarKind.appointment]),
      );
      final interventionsRequest = _interventions.getInterventions(
        InterventionFilter(assignedEmployee: name, open: true, perPage: 100),
      );
      final items = await calendarRequest;
      final page = await interventionsRequest;
      if (selected.value?.employeeId != employee.employeeId) return;
      appointments.assignAll(items);
      interventions.assignAll(page.items);
    });
  }
}
