import '../../scheduling/data/models/scheduling_settings.dart';
import '../data/models/config_models.dart';

/// Names of the configurable lists served by `/config/{entity}`.
abstract final class ConfigEntities {
  static const appointmentTypes = 'appointment-types';
  static const holidays = 'holidays';
  static const interventionTypes = 'intervention-types';
  static const interventionStatuses = 'intervention-statuses';
  static const interventionTransitions = 'intervention-transitions';
  static const interventionPriorities = 'intervention-priorities';
  static const messageTemplates = 'message-templates';
  static const productResources = 'product-resources';
}

/// Configuration kept in the CRM (never hard-coded in the client). Rows are
/// **deactivated, never deleted**, because history references them.
abstract interface class WorkflowConfigRepository {
  Future<List<ConfigRow>> getRows(String entity);
  Future<ConfigRow> create(String entity, Map<String, dynamic> data);
  Future<ConfigRow> update(String entity, int id, Map<String, dynamic> data);
  Future<ConfigRow> deactivate(String entity, int id);
  Future<ConfigRow> reactivate(String entity, int id);

  Future<SchedulingSettings> getScheduling();
  Future<SchedulingSettings> updateScheduling(SchedulingSettings settings);
}
