import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/intervention.dart';

class InterventionsRemoteDataSource {
  const InterventionsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Intervention>> getInterventions(
    InterventionFilter filter,
  ) async => ApiResponse.paginated(
    await _api.get(ApiEndpoints.interventions, query: filter.toQuery()),
    Intervention.fromJson,
  );

  Future<Intervention> getIntervention(int id) async => Intervention.fromJson(
    ApiResponse.object(await _api.get(ApiEndpoints.intervention(id))),
  );

  Future<Intervention> create(InterventionPayload payload) async =>
      Intervention.fromJson(
        ApiResponse.object(
          await _api.post(ApiEndpoints.interventions, data: payload.toJson()),
        ),
      );

  Future<Intervention> update(int id, Map<String, dynamic> changes) async =>
      Intervention.fromJson(
        ApiResponse.object(
          await _api.patch(ApiEndpoints.intervention(id), data: changes),
        ),
      );

  Future<List<AllowedTransition>> getTransitions(int id) async =>
      ApiResponse.list(
        await _api.get(ApiEndpoints.interventionAction(id, 'transitions')),
        AllowedTransition.fromJson,
      );

  Future<Intervention> post(
    int id,
    String action,
    Map<String, dynamic> data,
  ) async => Intervention.fromJson(
    ApiResponse.object(
      await _api.post(ApiEndpoints.interventionAction(id, action), data: data),
    ),
  );
}
