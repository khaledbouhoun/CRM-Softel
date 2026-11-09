import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../activities/data/models/activity.dart';
import '../models/follow_up.dart';

class FollowUpsRemoteDataSource {
  const FollowUpsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<FollowUp>> fetchPage({
    FollowUpView? view,
    int? prospectId,
    String? search,
    required int page,
    required int perPage,
  }) async {
    final body = await _api.get(
      prospectId == null
          ? ApiEndpoints.followUps
          : ApiEndpoints.prospectFollowUps(prospectId),
      query: {
        ...?view?.toQuery(),
        'search': search,
        'page': page,
        'per_page': perPage,
      },
    );
    return ApiResponse.paginated(body, FollowUp.fromJson);
  }

  Future<FollowUp> create(FollowUpPayload payload) async {
    final body = await _api.post(
      ApiEndpoints.prospectFollowUps(payload.prospectId),
      data: payload.toJson(),
    );
    return FollowUp.fromJson(ApiResponse.object(body));
  }

  Future<FollowUp> update(int id, FollowUpPayload payload) async {
    final body = await _api.put(
      ApiEndpoints.followUp(id),
      data: payload.toJson(),
    );
    return FollowUp.fromJson(ApiResponse.object(body));
  }

  Future<FollowUp> complete(int id, CompleteFollowUpRequest request) async {
    final body = await _api.post(
      ApiEndpoints.followUpComplete(id),
      data: request.toJson(),
    );
    return FollowUp.fromJson(ApiResponse.object(body));
  }

  /// Idempotent: returns the activity already created for this follow-up.
  Future<Activity> convertToActivity(int id) async {
    final body = await _api.post(ApiEndpoints.followUpConvert(id));
    return Activity.fromJson(ApiResponse.object(body));
  }

  Future<FollowUp> cancel(int id, {String? reason}) async {
    final trimmed = reason?.trim();
    final body = await _api.post(
      ApiEndpoints.followUpCancel(id),
      data: {
        if (trimmed != null && trimmed.isNotEmpty) 'closing_note': trimmed,
      },
    );
    return FollowUp.fromJson(ApiResponse.object(body));
  }
}
