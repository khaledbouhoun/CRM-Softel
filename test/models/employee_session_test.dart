import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/features/employees/data/models/employee_session.dart';

void main() {
  Map<String, dynamic> json([Map<String, dynamic> extra = const {}]) => {
    'employee_id': 'sara@PC-1',
    'username': 'sara',
    'device_name': 'PC-1',
    'status': 'Online',
    ...extra,
  };

  test('older servers: clean fallbacks and user@computer display name', () {
    final e = EmployeeSession.fromJson(json());
    expect(e.role, 'sales');
    expect(e.presenceStatus, 'available');
    expect(e.today.total, 0);
    expect(e.displayName, 'sara@PC-1');
  });

  test('nickname wins over user@computer; blank nickname is ignored', () {
    expect(
      EmployeeSession.fromJson(json({'custom_name': 'Reception'})).displayName,
      'Reception',
    );
    expect(
      EmployeeSession.fromJson(json({'custom_name': '  '})).displayName,
      'sara@PC-1',
    );
  });

  test('overview counts online staff by role and sums the team actions', () {
    final overview = EmployeesOverview.fromJson({
      'employees': [
        json({
          'role': 'sales',
          'today_stats': {'activities_count': 2, 'appointments_count': 1},
        }),
        json({
          'employee_id': 'b@PC-2',
          'role': 'support',
          'today_stats': {'interventions_count': 4},
        }),
        json({'employee_id': 'c@PC-3', 'role': 'support', 'status': 'Offline'}),
      ],
    });
    expect(overview.salesOnline, 1);
    expect(overview.supportOnline, 1);
    expect(overview.teamActionsToday, 7);
  });
}
