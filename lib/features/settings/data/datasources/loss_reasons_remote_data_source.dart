import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/loss_reason.dart';

class LossReasonsRemoteDataSource {
  const LossReasonsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<LossReason>> fetchAll({bool includeInactive = false}) async {
    final body = await _api.get(
      ApiEndpoints.lossReasons,
      // The API lists every reason unless filtered on is_active.
      query: {'is_active': includeInactive ? null : 1},
    );
    return ApiResponse.list(body, LossReason.fromJson);
  }

  Future<LossReason> create(LossReasonPayload payload) async {
    final body = await _api.post(
      ApiEndpoints.lossReasons,
      data: payload.toJson(),
    );
    return LossReason.fromJson(ApiResponse.object(body));
  }

  Future<LossReason> update(int id, LossReasonPayload payload) async {
    final body = await _api.put(
      ApiEndpoints.lossReason(id),
      data: payload.toJson(),
    );
    return LossReason.fromJson(ApiResponse.object(body));
  }

  Future<LossReason> setActive(int id, bool isActive) async {
    final body = await _api.patch(
      ApiEndpoints.lossReason(id),
      data: {'is_active': isActive},
    );
    return LossReason.fromJson(ApiResponse.object(body));
  }

  Future<List<LossReason>> reorder(List<int> orderedIds) async {
    final body = await _api.post(
      ApiEndpoints.lossReasonsReorder,
      data: {'ids': orderedIds},
    );
    return ApiResponse.list(body, LossReason.fromJson);
  }
}
