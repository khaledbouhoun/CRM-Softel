import 'package:get/get.dart';

import '../../features/employees/data/employee_options.dart';
import '../../features/employees/data/employees_repository.dart';
import 'employee_identity.dart';

/// Presence of this workstation, shown in the top bar and shared with the team.
/// Loaded on demand (when the menu opens), never at startup.
class PresenceService extends GetxService {
  PresenceService({
    required EmployeesRepository employees,
    required EmployeeIdentity identity,
  }) : _employees = employees,
       _identity = identity;

  final EmployeesRepository _employees;
  final EmployeeIdentity _identity;

  final current = EmployeePresence.available.obs;

  /// Picks up the presence stored by the server (best effort).
  Future<void> refresh() async {
    try {
      final overview = await _employees.getEmployees();
      final mine = overview.employees
          .where((e) => e.employeeId == _identity.employeeId)
          .firstOrNull;
      if (mine != null) current.value = EmployeePresence.parse(mine.presenceStatus);
    } catch (_) {
      // Offline: keep the last known value.
    }
  }

  /// Updates the indicator immediately and rolls back if the server refuses.
  Future<bool> set(EmployeePresence presence, {String? note}) async {
    final previous = current.value;
    current.value = presence;
    try {
      await _employees.updatePresence(
        employeeId: _identity.employeeId,
        presenceStatus: presence.value,
        statusNote: note,
      );
      return true;
    } catch (_) {
      current.value = previous;
      return false;
    }
  }
}
