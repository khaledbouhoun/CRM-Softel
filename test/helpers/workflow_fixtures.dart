/// JSON shaped like the CRM workflow endpoints (backend
/// `docs/PORTAL_AND_WORKFLOWS.md`, section 3) and the wiring of the new
/// repositories onto the shared [TestEnv] HTTP mock.
library;

import 'package:softel_crm/app/services/employee_identity.dart';
import 'package:softel_crm/app/services/workflow_lookup_service.dart';
import 'package:softel_crm/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:softel_crm/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:softel_crm/features/customers/domain/customers_repository.dart';
import 'package:softel_crm/features/employees/data/employees_repository.dart';
import 'package:softel_crm/features/interventions/data/datasources/interventions_remote_data_source.dart';
import 'package:softel_crm/features/interventions/data/repositories/interventions_repository_impl.dart';
import 'package:softel_crm/features/interventions/domain/interventions_repository.dart';
import 'package:softel_crm/features/scheduling/data/datasources/scheduling_remote_data_source.dart';
import 'package:softel_crm/features/scheduling/data/repositories/scheduling_repository_impl.dart';
import 'package:softel_crm/features/scheduling/domain/scheduling_repository.dart';
import 'package:softel_crm/features/workflow_settings/data/datasources/workflow_config_remote_data_source.dart';
import 'package:softel_crm/features/workflow_settings/data/repositories/workflow_config_repository_impl.dart';
import 'package:softel_crm/features/workflow_settings/domain/workflow_config_repository.dart';

import 'fixtures.dart';
import 'test_env.dart';

Map<String, dynamic> appointmentJson({
  int id = 7,
  String status = 'held',
  String group = 'demo',
  String typeName = 'Démo',
  bool holdExpired = false,
  String? holdExpiresAt = '2026-11-02T10:00:00+01:00',
  String startsAt = '2026-11-03T10:00:00+01:00',
  String endsAt = '2026-11-03T11:00:00+01:00',
  int? seriesId,
  Map<String, dynamic>? whatsapp,
  String? meetingUrl,
  int? activityId,
  String? phone = '0550123456',
}) => {
  'id': id,
  'kind': 'appointment',
  'title': null,
  'status': status,
  'is_hold_expired': holdExpired,
  'starts_at': startsAt,
  'ends_at': endsAt,
  'hold_expires_at': holdExpiresAt,
  'type': {
    'id': 1,
    'code': group,
    'name': typeName,
    'group': group,
    'color': '#3B82F6',
  },
  'prospect': {
    'id': 42,
    'name': 'SARL Exemple',
    'contact_person': 'Amine',
    'phone': phone,
    'is_customer': false,
  },
  'product': {'id': 1, 'name': 'GestCom'},
  'portal_account_id': 3,
  'assigned_employee': null,
  'meeting_url': meetingUrl,
  'internal_notes': null,
  'customer_message': null,
  'outcome': null,
  'activity_id': activityId,
  'series_id': seriesId,
  'training_kind': null,
  'send_whatsapp': whatsapp != null,
  'resource_url': null,
  'whatsapp': whatsapp,
  'decided_by': null,
  'decided_at': null,
  'created_at': '2026-11-01T09:00:00+01:00',
};

Map<String, dynamic> errorBody(
  String message,
  String code, {
  Map<String, dynamic>? errors,
}) => {
  'success': false,
  'message': message,
  'error_code': code,
  'errors': errors ?? <String, dynamic>{},
};

Map<String, dynamic> statusJson(
  int id,
  String code,
  String name, {
  bool initial = false,
  bool closed = false,
  String label = '',
}) => {
  'id': id,
  'code': code,
  'name': name,
  'customer_label': label.isEmpty ? name : label,
  'color': '#3B82F6',
  'is_initial': initial,
  'is_closed': closed,
  'awaits_customer': false,
  'is_delivered': false,
  'sort_order': id,
  'is_active': true,
};

Map<String, dynamic> priorityJson(int id, String name, int order) => {
  'id': id,
  'code': name.toLowerCase(),
  'name': name,
  'color': '#EF4444',
  'response_target_hours': 4,
  'sort_order': order,
  'is_active': true,
};

Map<String, dynamic> interventionJson({
  int id = 5,
  Map<String, dynamic>? status,
  Map<String, dynamic>? priority,
  List<Map<String, dynamic>> messages = const [],
  bool published = false,
}) => {
  'id': id,
  'reference': 'INT-$id',
  'source': 'customer',
  'title': 'Impression bloquée',
  'description': 'Le ticket ne sort pas.',
  'type': {
    'id': 1,
    'code': 'bug',
    'name': 'Bug',
    'source': 'both',
    'color': '#EF4444',
    'sort_order': 1,
    'is_active': true,
  },
  'status': status ?? statusJson(1, 'new', 'Nouveau', initial: true),
  'priority': priority,
  'prospect': {'id': 42, 'name': 'SARL Exemple'},
  'product': {'id': 1, 'name': 'GestCom'},
  'customers': [
    {'id': 42, 'name': 'SARL Exemple'},
  ],
  'assigned_employee': null,
  'is_published': published,
  'published_at': null,
  'customer_resolution': null,
  'scheduled_at': null,
  'closed_at': null,
  'messages': messages,
  'attachments': <Map<String, dynamic>>[],
  'created_at': '2026-11-01T09:00:00+01:00',
  'updated_at': '2026-11-01T09:00:00+01:00',
};

Map<String, dynamic> schedulingJson() => {
  'working_days': [0, 1, 2, 3, 4],
  'work_start': '09:00',
  'work_end': '17:00',
  'slot_minutes': 60,
  'hold_expiry_minutes': 1440,
  'booking_horizon_days': 30,
  'min_notice_hours': 2,
  'demo_capacity': 1,
  'accompaniment_occurrences': 4,
  'accompaniment_interval_days': 7,
  'trial_default_days': 14,
  'whatsapp_country_code': '213',
};

/// The workflow repositories wired onto [TestEnv]'s mocked HTTP client.
class WorkflowTestEnv {
  WorkflowTestEnv(this.base) {
    final api = base.api;
    scheduling = SchedulingRepositoryImpl(SchedulingRemoteDataSource(api));
    customers = CustomersRepositoryImpl(CustomersRemoteDataSource(api));
    interventions = InterventionsRepositoryImpl(
      InterventionsRemoteDataSource(api),
    );
    config = WorkflowConfigRepositoryImpl(WorkflowConfigRemoteDataSource(api));
    employees = EmployeesRepositoryImpl(api);
    workflow = WorkflowLookupService(
      config: config,
      employees: employees,
      identity: EmployeeIdentity(username: 'salim', deviceName: 'PC1'),
    );
  }

  final TestEnv base;
  late final SchedulingRepository scheduling;
  late final CustomersRepository customers;
  late final InterventionsRepository interventions;
  late final WorkflowConfigRepository config;
  late final EmployeesRepository employees;
  late final WorkflowLookupService workflow;

  /// Statuses 1 new -> 2 in progress -> 3 resolved (closed).
  static final newStatus = statusJson(1, 'new', 'Nouveau', initial: true);
  static final progressStatus = statusJson(2, 'in_progress', 'En cours');
  static final resolvedStatus = statusJson(
    3,
    'resolved',
    'Résolu',
    closed: true,
  );

  void stubLookups() {
    base.adapter
      ..reply(
        'GET',
        '/config/appointment-types',
        wrap([
          {
            'id': 1,
            'code': 'training',
            'name': 'Formation',
            'group': 'training',
            'default_duration_minutes': 90,
            'color': '#10B981',
            'customer_bookable': false,
            'sort_order': 1,
            'is_active': true,
          },
          {
            'id': 2,
            'code': 'accompaniment',
            'name': 'Accompagnement',
            'group': 'accompaniment',
            'default_duration_minutes': 60,
            'color': '#F59E0B',
            'customer_bookable': false,
            'sort_order': 2,
            'is_active': true,
          },
        ]),
      )
      ..reply(
        'GET',
        '/config/intervention-types',
        wrap([
          {
            'id': 1,
            'code': 'bug',
            'name': 'Bug',
            'source': 'both',
            'color': '#EF4444',
            'sort_order': 1,
            'is_active': true,
          },
          {
            'id': 2,
            'code': 'fix',
            'name': 'Correctif',
            'source': 'employee',
            'color': '#22C55E',
            'sort_order': 2,
            'is_active': true,
          },
        ]),
      )
      ..reply(
        'GET',
        '/config/intervention-statuses',
        wrap([newStatus, progressStatus, resolvedStatus]),
      )
      ..reply(
        'GET',
        '/config/intervention-priorities',
        wrap([priorityJson(1, 'Urgent', 1), priorityJson(2, 'Normale', 5)]),
      )
      ..reply('GET', '/settings/scheduling', wrap(schedulingJson()))
      ..reply(
        'GET',
        '/system/employees',
        wrap({
          'summary': {'active_employees': 1},
          'employees': [
            {
              'employee_id': 'salim@PC1',
              'username': 'salim',
              'device_name': 'PC1',
              'ip_address': '192.168.1.5',
              'status': 'Online',
              'last_activity': '2026-11-01T09:00:00+01:00',
              'last_request': '/api/v1/health',
            },
          ],
        }),
      );
  }
}
