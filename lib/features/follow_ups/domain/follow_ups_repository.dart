import '../../../core/network/api_response.dart';
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
  Future<FollowUpCompletion> completeFollowUp(
    int id,
    CompleteFollowUpRequest request,
  );

  /// Turns a completed follow-up into an activity; repeated calls return the
  /// same activity.
  Future<Activity> convertToActivity(int id);

  Future<FollowUp> cancelFollowUp(int id, {String? reason});
}
