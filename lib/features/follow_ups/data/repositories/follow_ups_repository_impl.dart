import '../../../../core/network/api_response.dart';
import '../../../activities/data/models/activity.dart';
import '../../domain/follow_ups_repository.dart';
import '../datasources/follow_ups_remote_data_source.dart';
import '../models/follow_up.dart';

class FollowUpsRepositoryImpl implements FollowUpsRepository {
  const FollowUpsRepositoryImpl(this._remote);

  final FollowUpsRemoteDataSource _remote;

  @override
  Future<Paginated<FollowUp>> getFollowUps({
    FollowUpView? view,
    int? prospectId,
    String? search,
    int page = 1,
    int perPage = 25,
  }) => _remote.fetchPage(view: view, prospectId: prospectId, search: search, page: page, perPage: perPage);

  @override
  Future<FollowUp> createFollowUp(FollowUpPayload payload) => _remote.create(payload);

  @override
  Future<FollowUp> updateFollowUp(int id, FollowUpPayload payload) => _remote.update(id, payload);

  /// One request: the server completes the follow-up and, when asked, creates
  /// its activity in the same transaction (never twice).
  @override
  Future<FollowUpCompletion> completeFollowUp(int id, CompleteFollowUpRequest request) async =>
      FollowUpCompletion(followUp: await _remote.complete(id, request));

  @override
  Future<Activity> convertToActivity(int id) => _remote.convertToActivity(id);

  @override
  Future<FollowUp> cancelFollowUp(int id, {String? reason}) => _remote.cancel(id, reason: reason);
}
