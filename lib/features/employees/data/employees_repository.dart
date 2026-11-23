import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import 'models/employee_session.dart';

/// Employees as the CRM knows them (heartbeat sessions).
abstract interface class EmployeesRepository {
  Future<EmployeesOverview> getEmployees();

  /// Registers this workstation. Best effort: callers ignore failures.
  Future<void> sendHeartbeat({
    required String employeeId,
    required String username,
    String? deviceName,
  });

  /// Workstation nickname and department. A blank [customName] clears it.
  Future<void> updateEmployee(
    String employeeId, {
    String? customName,
    String? role,
  });

  /// Presence of this workstation (`available`, `busy`, `away`, `break`).
  Future<void> updatePresence({
    required String employeeId,
    required String presenceStatus,
    String? statusNote,
  });
}

class EmployeesRepositoryImpl implements EmployeesRepository {
  const EmployeesRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<EmployeesOverview> getEmployees() async => EmployeesOverview.fromJson(
    ApiResponse.object(await _api.get(ApiEndpoints.employees)),
  );

  @override
  Future<void> sendHeartbeat({
    required String employeeId,
    required String username,
    String? deviceName,
  }) async {
    await _api.post(
      ApiEndpoints.heartbeat,
      data: {
        'employee_id': employeeId,
        'username': username,
        'device_name': ?deviceName,
      },
    );
  }

  @override
  Future<void> updateEmployee(
    String employeeId, {
    String? customName,
    String? role,
  }) async {
    await _api.put(
      '${ApiEndpoints.employees}/${Uri.encodeComponent(employeeId)}',
      data: {'custom_name': ?customName, 'role': ?role},
    );
  }

  @override
  Future<void> updatePresence({
    required String employeeId,
    required String presenceStatus,
    String? statusNote,
  }) async {
    await _api.post(
      ApiEndpoints.employeePresence,
      data: {
        'employee_id': employeeId,
        'presence_status': presenceStatus,
        'status_note': ?statusNote,
      },
    );
  }
}
