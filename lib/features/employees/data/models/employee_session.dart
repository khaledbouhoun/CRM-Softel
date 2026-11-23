import '../../../../core/utils/json_utils.dart';

/// Work done today by an employee label (`GET /system/employees` → `today_stats`).
class EmployeeTodayStats {
  const EmployeeTodayStats({
    this.activities = 0,
    this.interventions = 0,
    this.appointments = 0,
  });

  final int activities;
  final int interventions;
  final int appointments;

  int get total => activities + interventions + appointments;

  factory EmployeeTodayStats.fromJson(JsonMap? json) => EmployeeTodayStats(
    activities: asInt(json?['activities_count']),
    interventions: asInt(json?['interventions_count']),
    appointments: asInt(json?['appointments_count']),
  );
}

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
    this.customName,
    this.role = 'sales',
    this.presenceStatus = 'available',
    this.statusNote,
    this.today = const EmployeeTodayStats(),
  });

  final String employeeId;
  final String username;
  final String? deviceName;
  final String? ipAddress;

  /// `Online`, `Idle` or `Offline`.
  final String status;
  final DateTime? lastActivity;
  final String? lastRequest;

  /// Friendly nickname of the desk/PC, e.g. "Reception".
  final String? customName;

  /// `sales`, `support`, `management` or `training`.
  final String role;

  /// `available`, `busy`, `away` or `break`.
  final String presenceStatus;
  final String? statusNote;
  final EmployeeTodayStats today;

  int get activitiesToday => today.activities;
  int get interventionsToday => today.interventions;
  int get appointmentsToday => today.appointments;

  bool get isOnline => status.toLowerCase() == 'online';

  /// The nickname, otherwise `user@computer`.
  String get displayName {
    final nickname = customName?.trim() ?? '';
    if (nickname.isNotEmpty) return nickname;
    final device = deviceName?.trim() ?? '';
    return device.isEmpty ? username : '$username@$device';
  }

  factory EmployeeSession.fromJson(JsonMap json) => EmployeeSession(
    employeeId: asString(json['employee_id']),
    username: asString(json['username']),
    deviceName: asStringOrNull(json['device_name']),
    ipAddress: asStringOrNull(json['ip_address']),
    status: asString(json['status'], fallback: 'Offline'),
    lastActivity: asDateTimeOrNull(json['last_activity']),
    lastRequest: asStringOrNull(json['last_request']),
    customName: asStringOrNull(json['custom_name']),
    role: asString(json['role'], fallback: 'sales'),
    presenceStatus: asString(json['presence_status'], fallback: 'available'),
    statusNote: asStringOrNull(json['status_note']),
    today: EmployeeTodayStats.fromJson(asMapOrNull(json['today_stats'])),
  );
}

/// `GET /system/employees`.
class EmployeesOverview {
  const EmployeesOverview({
    this.employees = const [],
    this.activeCount = 0,
    this.teamActionsToday = 0,
  });

  final List<EmployeeSession> employees;
  final int activeCount;
  final int teamActionsToday;

  int get salesOnline => _online('sales');
  int get supportOnline => _online('support');

  int _online(String role) =>
      employees.where((e) => e.isOnline && e.role == role).length;

  factory EmployeesOverview.fromJson(JsonMap json) {
    final summary = asMapOrNull(json['summary']) ?? const <String, dynamic>{};
    final employees = asList(json['employees'], EmployeeSession.fromJson);
    return EmployeesOverview(
      employees: employees,
      activeCount: asInt(summary['active_employees']),
      teamActionsToday: summary.containsKey('team_actions_today')
          ? asInt(summary['team_actions_today'])
          : employees.fold(0, (sum, e) => sum + e.today.total),
    );
  }
}
