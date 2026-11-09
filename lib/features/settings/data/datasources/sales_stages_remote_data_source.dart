import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/sales_stage.dart';

class SalesStagesRemoteDataSource {
  const SalesStagesRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<SalesStage>> fetchAll({bool includeInactive = false}) async {
    final body = await _api.get(
      ApiEndpoints.salesStages,
      // The API lists every stage unless filtered on is_active.
      query: {'is_active': includeInactive ? null : 1},
    );
    return ApiResponse.list(body, SalesStage.fromJson);
  }

  Future<SalesStage> create(SalesStagePayload payload) async {
    final body = await _api.post(
      ApiEndpoints.salesStages,
      data: payload.toJson(),
    );
    return SalesStage.fromJson(ApiResponse.object(body));
  }

  Future<SalesStage> update(int id, SalesStagePayload payload) async {
    final body = await _api.put(
      ApiEndpoints.salesStage(id),
      data: payload.toJson(),
    );
    return SalesStage.fromJson(ApiResponse.object(body));
  }

  Future<SalesStage> setActive(int id, bool isActive) async {
    final body = await _api.patch(
      ApiEndpoints.salesStage(id),
      data: {'is_active': isActive},
    );
    return SalesStage.fromJson(ApiResponse.object(body));
  }

  Future<List<SalesStage>> reorder(List<int> orderedIds) async {
    final body = await _api.post(
      ApiEndpoints.salesStagesReorder,
      data: {'ids': orderedIds},
    );
    return ApiResponse.list(body, SalesStage.fromJson);
  }

  Future<void> delete(int id) => _api.delete(ApiEndpoints.salesStage(id));
}
