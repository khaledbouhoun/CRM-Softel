# -*- coding: utf-8 -*-
"""Data layer: native activities, linking, atomic follow-up completion."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import edit  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def write(path, text):
    with open(os.path.join(ROOT, path), 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


# ---------------------------------------------------------------- endpoints
edit('lib/core/network/api_endpoints.dart',
     "  static const activities = '/activities';",
     "  static const activities = '/activities';\n"
     "  static String activity(int id) => '/activities/$id';\n"
     "  static String activityLinkProspect(int id) => '/activities/$id/link-prospect';")
edit('lib/core/network/api_endpoints.dart',
     "  static String followUpCancel(int id) => '/follow-ups/$id/cancel';",
     "  static String followUpCancel(int id) => '/follow-ups/$id/cancel';\n"
     "  static String followUpConvert(int id) => '/follow-ups/$id/convert-to-activity';")

# ---------------------------------------------------------------- activities data source / repo
write('lib/features/activities/data/datasources/activities_remote_data_source.dart', """import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/activity.dart';

class ActivitiesRemoteDataSource {
  const ActivitiesRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Activity>> fetchPage(ActivityFilter filter) async {
    final body = await _api.get(ApiEndpoints.activities, query: filter.toQuery());
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
    final body = await _api.post(ApiEndpoints.activities, data: payload.toNativeJson());
    return Activity.fromJson(ApiResponse.object(body));
  }

  /// Links the existing activity to a prospect (no new activity is created).
  Future<Activity> linkProspect(int activityId, int prospectId, {bool confirmRelink = false}) async {
    final body = await _api.post(
      ApiEndpoints.activityLinkProspect(activityId),
      data: {'prospect_id': prospectId, if (confirmRelink) 'confirm_relink': true},
    );
    return Activity.fromJson(ApiResponse.object(body));
  }
}
""")
write('lib/features/activities/data/repositories/activities_repository_impl.dart', """import '../../../../core/network/api_response.dart';
import '../../domain/activities_repository.dart';
import '../datasources/activities_remote_data_source.dart';
import '../models/activity.dart';

class ActivitiesRepositoryImpl implements ActivitiesRepository {
  const ActivitiesRepositoryImpl(this._remote);

  final ActivitiesRemoteDataSource _remote;

  @override
  Future<Paginated<Activity>> getActivities(ActivityFilter filter) =>
      _remote.fetchPage(filter);

  @override
  Future<Activity> getActivity(int id) => _remote.fetchOne(id);

  @override
  Future<Activity> createActivity(ActivityPayload payload) =>
      payload.prospectId == null
          ? _remote.createNative(payload)
          : _remote.create(payload);

  @override
  Future<Activity> createNativeActivity(ActivityPayload payload) =>
      _remote.createNative(payload);

  @override
  Future<Activity> linkToProspect(int activityId, int prospectId, {bool confirmRelink = false}) =>
      _remote.linkProspect(activityId, prospectId, confirmRelink: confirmRelink);
}
""")
write('lib/features/activities/domain/activities_repository.dart', """import '../../../core/network/api_response.dart';
import '../data/models/activity.dart';

/// Activities are append-only: content and dates never change. The only
/// change after creation is linking an activity to a prospect.
abstract interface class ActivitiesRepository {
  Future<Paginated<Activity>> getActivities(ActivityFilter filter);
  Future<Activity> getActivity(int id);

  /// Created under [ActivityPayload.prospectId] when set, else on its own.
  Future<Activity> createActivity(ActivityPayload payload);

  /// Created on its own through POST `/activities` (prospect optional).
  Future<Activity> createNativeActivity(ActivityPayload payload);

  /// Links an existing activity to a prospect. Moving an activity that
  /// already belongs to another prospect needs [confirmRelink].
  Future<Activity> linkToProspect(int activityId, int prospectId, {bool confirmRelink = false});
}
""")

# ---------------------------------------------------------------- follow-ups data source / repo
edit('lib/features/follow_ups/data/datasources/follow_ups_remote_data_source.dart',
     """  Future<Activity> createActivity(ActivityPayload payload) async {
    final body = await _api.post(
      ApiEndpoints.prospectActivities(payload.prospectId),
      data: payload.toJson(),
    );
    return Activity.fromJson(ApiResponse.object(body));
  }
""", """  /// Idempotent: returns the activity already created for this follow-up.
  Future<Activity> convertToActivity(int id) async {
    final body = await _api.post(ApiEndpoints.followUpConvert(id));
    return Activity.fromJson(ApiResponse.object(body));
  }
""")
edit('lib/features/follow_ups/data/repositories/follow_ups_repository_impl.dart',
     """  /// Completion first: it is the state change the server guards (a second
  /// attempt is refused), so a retry can never log the activity twice.
  @override
  Future<FollowUpCompletion> completeFollowUp(int id, CompleteFollowUpRequest request) async {
    final followUp = await _remote.complete(id, request);
    final activity = request.activity;
    if (activity == null) return FollowUpCompletion(followUp: followUp);
    try {
      return FollowUpCompletion(
        followUp: followUp,
        activity: await _remote.createActivity(activity),
      );
    } catch (e) {
      return FollowUpCompletion(followUp: followUp, activityError: ApiException.from(e));
    }
  }
""", """  /// One request: the server completes the follow-up and, when asked, creates
  /// its activity in the same transaction (never twice).
  @override
  Future<FollowUpCompletion> completeFollowUp(int id, CompleteFollowUpRequest request) async =>
      FollowUpCompletion(followUp: await _remote.complete(id, request));

  @override
  Future<Activity> convertToActivity(int id) => _remote.convertToActivity(id);
""")
edit('lib/features/follow_ups/data/repositories/follow_ups_repository_impl.dart',
     "import '../../../../core/network/api_exceptions.dart';\nimport '../../../../core/network/api_response.dart';",
     "import '../../../../core/network/api_response.dart';\nimport '../../../activities/data/models/activity.dart';")
write('lib/features/follow_ups/domain/follow_ups_repository.dart', """import '../../../core/network/api_response.dart';
import '../../activities/data/models/activity.dart';
import '../data/models/follow_up.dart';

/// Result of completing a follow-up. [FollowUp.activityId] tells whether the
/// server also recorded the activity.
class FollowUpCompletion {
  const FollowUpCompletion({required this.followUp});

  final FollowUp followUp;

  bool get activityRecorded => followUp.activityId != null;
}

abstract interface class FollowUpsRepository {
  /// [view] null → every follow-up (used by the prospect details page).
  Future<Paginated<FollowUp>> getFollowUps({
    FollowUpView? view,
    int? prospectId,
    String? search,
    int page = 1,
    int perPage = 25,
  });

  Future<FollowUp> createFollowUp(FollowUpPayload payload);

  /// Only pending follow-ups can be edited.
  Future<FollowUp> updateFollowUp(int id, FollowUpPayload payload);

  /// Completes the follow-up. With [CompleteFollowUpRequest.recordActivity]
  /// the server creates the activity (type and prospect copied from the
  /// follow-up) in the same transaction.
  Future<FollowUpCompletion> completeFollowUp(int id, CompleteFollowUpRequest request);

  /// Turns a completed follow-up into an activity; repeated calls return the
  /// same activity.
  Future<Activity> convertToActivity(int id);

  Future<FollowUp> cancelFollowUp(int id, {String? reason});
}
""")

# ---------------------------------------------------------------- widgets
edit('lib/features/activities/presentation/widgets/activity_widgets.dart',
     "  ActivityType.meeting => Icons.groups_outlined,",
     "  ActivityType.meeting || ActivityType.appointment => Icons.groups_outlined,")
edit('lib/features/activities/presentation/widgets/activity_widgets.dart',
     "  ActivityType.meeting => const Color(0xFF7C3AED),",
     "  ActivityType.meeting || ActivityType.appointment => const Color(0xFF7C3AED),")
print('data layer ok')
