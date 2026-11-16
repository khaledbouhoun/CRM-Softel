import '../../../scheduling/data/models/scheduling_settings.dart';
import '../../domain/workflow_config_repository.dart';
import '../datasources/workflow_config_remote_data_source.dart';
import '../models/config_models.dart';

class WorkflowConfigRepositoryImpl implements WorkflowConfigRepository {
  const WorkflowConfigRepositoryImpl(this._remote);

  final WorkflowConfigRemoteDataSource _remote;

  @override
  Future<List<ConfigRow>> getRows(String entity) => _remote.getRows(entity);

  @override
  Future<ConfigRow> create(String entity, Map<String, dynamic> data) =>
      _remote.create(entity, data);

  @override
  Future<ConfigRow> update(String entity, int id, Map<String, dynamic> data) =>
      _remote.update(entity, id, data);

  @override
  Future<ConfigRow> deactivate(String entity, int id) =>
      _remote.deactivate(entity, id);

  @override
  Future<ConfigRow> reactivate(String entity, int id) =>
      _remote.update(entity, id, const {'is_active': true});

  @override
  Future<SchedulingSettings> getScheduling() => _remote.getScheduling();

  @override
  Future<SchedulingSettings> updateScheduling(SchedulingSettings settings) =>
      _remote.updateScheduling(settings);
}
