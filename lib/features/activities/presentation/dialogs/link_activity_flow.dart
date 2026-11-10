import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../follow_ups/presentation/dialogs/follow_up_search_dialog.dart';
import '../../data/models/activity.dart';
import '../../domain/activities_repository.dart';

/// "Link to follow-up" flow for an activity that is not yet linked to a follow-up.
///
/// If the activity already belongs to a prospect, only follow-ups for that
/// prospect can be chosen, guaranteeing consistency. Once linked to a follow-up,
/// the link cannot be changed.
Future<Activity?> linkActivityToFollowUp(Activity activity) async {
  if (activity.isLinkedToFollowUp) {
    AppFeedback.warning(
      'This activity is already linked to a follow-up and cannot be changed.',
    );
    return null;
  }

  final followUp = await showFollowUpSearchDialog(
    prospectId: activity.prospect?.id,
    prospectName: activity.prospect?.companyName,
  );
  if (followUp == null) return null;

  // Enforce same prospect if activity already had a prospect
  if (activity.prospect != null &&
      followUp.prospect != null &&
      activity.prospect!.id != followUp.prospect!.id) {
    AppFeedback.error(
      BadRequestException(
        'The selected follow-up belongs to another prospect.',
      ),
    );
    return null;
  }

  try {
    final repo = Get.find<ActivitiesRepository>();
    final updated = await repo.linkToFollowUp(activity.id, followUp.id);
    AppFeedback.success('Activity linked to follow-up successfully.');
    return updated;
  } catch (e) {
    AppFeedback.error(ApiException.from(e));
    return null;
  }
}
