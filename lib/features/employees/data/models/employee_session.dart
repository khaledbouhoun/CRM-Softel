import '../../../../core/utils/json_utils.dart';

/// A workstation known to the CRM through its heartbeat. The `username` is
/// the label used for assignments (`assigned_employee`): all employees share
/// the same access level, there is no employee login.
class EmployeeSession {
  const EmployeeSession({
    required this.employeeId,
    required this.username,
    required this.status,
    this.deviceName,
    this.ipAddress,
    this.lastActivity,
    this.lastRequest,
  });

  final String employeeId;
  final String username;
  final String? deviceName;
  final String? ipAddress;

  /// `Online`, `Idle` or `Offline`.
  final String status;
  final DateTime? lastActivity;
  final String? lastRequest;

  bool get isOnline => status.toLowerCase() == 'online';

  factory EmployeeSession.fromJson(JsonMap json) => EmployeeSession(
    employeeId: asString(json['employee_id']),
    username: asString(json['username']),
    deviceName: asStringOrNull(json['device_name']),
    ipAddress: asStringOrNull(json['ip_address']),
    status: asString(json['status'], fallback: 'Offline'),
    lastActivity: asDateTimeOrNull(json['last_activity']),
    lastRequest: asStringOrNull(json['last_request']),
  );
}

/// `GET /system/employees`.
class EmployeesOverview {
  const EmployeesOverview({this.employees = const [], this.activeCount = 0});

  final List<EmployeeSession> employees;
  final int activeCount;

  factory EmployeesOverview.fromJson(JsonMap json) {
    final summary = asMapOrNull(json['summary']) ?? const <String, dynamic>{};
    return EmployeesOverview(
      employees: asList(json['employees'], EmployeeSession.fromJson),
      activeCount: asInt(summary['active_employees']),
    );
  }
}
