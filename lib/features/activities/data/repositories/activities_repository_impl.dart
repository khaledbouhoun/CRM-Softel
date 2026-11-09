import '../../../../core/network/api_response.dart';
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
      // POST /activities accepts an optional prospect_id and a title-only
      // activity; the nested prospect route would insist on a description.
      _remote.createNative(payload);

  @override
  Future<Activity> createNativeActivity(ActivityPayload payload) =>
      _remote.createNative(payload);

  @override
  Future<Activity> linkToProspect(
    int activityId,
    int prospectId, {
    bool confirmRelink = false,
  }) => _remote.linkProspect(
    activityId,
    prospectId,
    confirmRelink: confirmRelink,
  );
}
