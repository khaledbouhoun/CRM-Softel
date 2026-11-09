import '../../../core/network/api_response.dart';
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
  Future<Activity> linkToProspect(
    int activityId,
    int prospectId, {
    bool confirmRelink = false,
  });
}
