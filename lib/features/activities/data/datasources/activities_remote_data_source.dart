import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/activity.dart';

class ActivitiesRemoteDataSource {
  const ActivitiesRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Activity>> fetchPage(ActivityFilter filter) async {
    final body = await _api.get(
      ApiEndpoints.activities,
      query: filter.toQuery(),
    );
    return ApiResponse.paginated(body, Activity.fromJson);
  }

  Future<Activity> fetchOne(int id) async {
    final body = await _api.get(ApiEndpoints.activity(id));
    return Activity.fromJson(ApiResponse.object(body));
  }

  /// Activity created from a prospect page (the prospect is in the URL).
  Future<Activity> create(ActivityPayload payload) async {
    final body = await _api.post(
      ApiEndpoints.prospectActivities(payload.prospectId!),
      data: payload.toJson(),
    );
    return Activity.fromJson(ApiResponse.object(body));
  }

  /// Activity created on its own; the prospect is optional.
  Future<Activity> createNative(ActivityPayload payload) async {
    final body = await _api.post(
      ApiEndpoints.activities,
      data: payload.toNativeJson(),
    );
    return Activity.fromJson(ApiResponse.object(body));
  }

  /// Links the existing activity to a prospect (no new activity is created).
  Future<Activity> linkProspect(
    int activityId,
    int prospectId, {
    bool confirmRelink = false,
  }) async {
    final body = await _api.post(
      ApiEndpoints.activityLinkProspect(activityId),
      data: {
        'prospect_id': prospectId,
        if (confirmRelink) 'confirm_relink': true,
      },
    );
    return Activity.fromJson(ApiResponse.object(body));
  }
}
