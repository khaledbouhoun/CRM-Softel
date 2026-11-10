import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/prospect_form_option.dart';

class ProspectFormOptionsRemoteDataSource {
  const ProspectFormOptionsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<ProspectFormOption>> fetchAll({
    String? type,
    bool includeInactive = false,
  }) async {
    final body = await _api.get(
      ApiEndpoints.prospectFormOptions,
      query: {
        if (type != null && type.isNotEmpty) 'type': type,
        'is_active': includeInactive ? null : 1,
      },
    );
    return ApiResponse.list(body, ProspectFormOption.fromJson);
  }

  Future<ProspectFormOption> create(ProspectFormOptionPayload payload) async {
    final body = await _api.post(
      ApiEndpoints.prospectFormOptions,
      data: payload.toJson(),
    );
    return ProspectFormOption.fromJson(ApiResponse.object(body));
  }

  Future<ProspectFormOption> update(
    int id,
    ProspectFormOptionPayload payload,
  ) async {
    final body = await _api.put(
      ApiEndpoints.prospectFormOption(id),
      data: payload.toJson(),
    );
    return ProspectFormOption.fromJson(ApiResponse.object(body));
  }

  Future<ProspectFormOption> setActive(int id, bool isActive) async {
    final body = await _api.put(
      ApiEndpoints.prospectFormOption(id),
      data: {'is_active': isActive},
    );
    return ProspectFormOption.fromJson(ApiResponse.object(body));
  }

  Future<List<ProspectFormOption>> reorder(
    String type,
    List<int> orderedIds,
  ) async {
    final body = await _api.post(
      ApiEndpoints.prospectFormOptionsReorder,
      data: {'type': type, 'ids': orderedIds},
    );
    return ApiResponse.list(body, ProspectFormOption.fromJson);
  }

  Future<void> delete(int id) async {
    await _api.delete(ApiEndpoints.prospectFormOption(id));
  }
}
