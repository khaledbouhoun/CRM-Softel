import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../scheduling/data/models/scheduling_settings.dart';
import '../models/config_models.dart';

class WorkflowConfigRemoteDataSource {
  const WorkflowConfigRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<ConfigRow>> getRows(String entity) async => ApiResponse.list(
    await _api.get(ApiEndpoints.config(entity)),
    ConfigRow.fromJson,
  );

  Future<ConfigRow> create(String entity, Map<String, dynamic> data) async =>
      ConfigRow.fromJson(
        ApiResponse.object(
          await _api.post(ApiEndpoints.config(entity), data: data),
        ),
      );

  Future<ConfigRow> update(
    String entity,
    int id,
    Map<String, dynamic> data,
  ) async => ConfigRow.fromJson(
    ApiResponse.object(
      await _api.patch(ApiEndpoints.configRow(entity, id), data: data),
    ),
  );

  /// The API never deletes: DELETE only deactivates the row.
  Future<ConfigRow> deactivate(String entity, int id) async =>
      ConfigRow.fromJson(
        ApiResponse.object(
          await _api.delete(ApiEndpoints.configRow(entity, id)),
        ),
      );

  Future<SchedulingSettings> getScheduling() async =>
      SchedulingSettings.fromJson(
        ApiResponse.object(await _api.get(ApiEndpoints.schedulingSettings)),
      );

  Future<SchedulingSettings> updateScheduling(
    SchedulingSettings settings,
  ) async => SchedulingSettings.fromJson(
    ApiResponse.object(
      await _api.put(ApiEndpoints.schedulingSettings, data: settings.toJson()),
    ),
  );
}
