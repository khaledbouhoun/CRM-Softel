import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/network/api_exceptions.dart';
import '../../features/employees/data/employees_repository.dart';
import '../../features/scheduling/data/models/scheduling_settings.dart';
import '../../features/workflow_settings/data/models/config_models.dart';
import '../../features/workflow_settings/domain/workflow_config_repository.dart';
import 'employee_identity.dart';

/// Shared cache of the configurable workflow data: appointment types,
/// intervention types / statuses / priorities, scheduling settings and the
/// employee names. Everything comes from the CRM; nothing is hard-coded.
///
/// Loaded lazily by the screens that need it (so the app still starts when
/// the server is down) and refreshed after settings changes.
class WorkflowLookupService extends GetxService {
  WorkflowLookupService({
    required WorkflowConfigRepository config,
    required EmployeesRepository employees,
    EmployeeIdentity? identity,
  }) : _config = config,
       _employees = employees,
       identity = identity ?? EmployeeIdentity();

  final WorkflowConfigRepository _config;
  final EmployeesRepository _employees;
  final EmployeeIdentity identity;

  final appointmentTypes = <AppointmentType>[].obs;
  final interventionTypes = <InterventionType>[].obs;
  final interventionStatuses = <InterventionStatus>[].obs;
  final interventionPriorities = <InterventionPriority>[].obs;
  final scheduling = Rxn<SchedulingSettings>();
  final employeeNames = <String>[].obs;
  final isLoaded = false.obs;
  final lastError = Rxn<ApiException>();

  Future<void>? _pending;

  List<AppointmentType> get activeAppointmentTypes =>
      appointmentTypes.where((t) => t.isActive).toList(growable: false);

  /// Active appointment types of one group (`training`, `accompaniment`...).
  List<AppointmentType> typesOfGroup(String group) => appointmentTypes
      .where((t) => t.isActive && t.group == group)
      .toList(growable: false);

  List<InterventionType> get activeInterventionTypes =>
      interventionTypes.where((t) => t.isActive).toList(growable: false);

  /// Types retired from the pickers: product updates and release notes now
  /// live in the Product Releases module. Old records keep their type, so
  /// filters and detail screens still show them.
  static const retiredInterventionTypeCodes = {'update', 'release'};

  /// Types an employee may create (`source` employee or both), without the
  /// retired `update` / `release` types.
  List<InterventionType> get employeeInterventionTypes => interventionTypes
      .where(
        (t) =>
            t.isActive &&
            t.allowsEmployee &&
            !retiredInterventionTypeCodes.contains(t.code),
      )
      .toList(growable: false);

  List<InterventionPriority> get activePriorities =>
      interventionPriorities.where((p) => p.isActive).toList(growable: false);

  InterventionStatus? statusById(int? id) =>
      interventionStatuses.firstWhereOrNull((s) => s.id == id);

  InterventionPriority? priorityById(int? id) =>
      interventionPriorities.firstWhereOrNull((p) => p.id == id);

  InterventionType? interventionTypeById(int? id) =>
      interventionTypes.firstWhereOrNull((t) => t.id == id);

  AppointmentType? appointmentTypeById(int? id) =>
      appointmentTypes.firstWhereOrNull((t) => t.id == id);

  Future<void> ensureLoaded() {
    if (isLoaded.value) return Future.value();
    return refresh();
  }

  /// Reloads everything; concurrent calls share one run. A failing part is
  /// recorded in [lastError] and leaves the previous data in place.
  Future<void> refresh() => _pending ??= _load().whenComplete(() {
    _pending = null;
  });

  Future<void> refreshQuietly() async {
    try {
      await refresh();
    } catch (e) {
      if (kDebugMode) debugPrint('[Workflow] refresh failed: $e');
    }
  }

  Future<void> _load() async {
    ApiException? error;

    Future<void> part(Future<void> Function() task) async {
      try {
        await task();
      } catch (e) {
        error = ApiException.from(e);
      }
    }

    await Future.wait([
      part(() async {
        final rows = await _config.getRows(ConfigEntities.appointmentTypes);
        appointmentTypes.assignAll(
          rows.map((r) => AppointmentType.fromJson(r.data)),
        );
      }),
      part(() async {
        final rows = await _config.getRows(ConfigEntities.interventionTypes);
        interventionTypes.assignAll(
          rows.map((r) => InterventionType.fromJson(r.data)),
        );
      }),
      part(() async {
        final rows = await _config.getRows(ConfigEntities.interventionStatuses);
        interventionStatuses.assignAll(
          rows.map((r) => InterventionStatus.fromJson(r.data)),
        );
      }),
      part(() async {
        final rows = await _config.getRows(
          ConfigEntities.interventionPriorities,
        );
        interventionPriorities.assignAll(
          rows.map((r) => InterventionPriority.fromJson(r.data)),
        );
      }),
      part(() async {
        scheduling.value = await _config.getScheduling();
      }),
      part(() async {
        final overview = await _employees.getEmployees();
        final names = <String>{
          for (final e in overview.employees)
            if (e.username.isNotEmpty) e.username,
          if (identity.username.isNotEmpty) identity.username,
        };
        employeeNames.assignAll(names.toList()..sort());
      }),
    ]);

    lastError.value = error;
    if (error == null) isLoaded.value = true;
  }
}
