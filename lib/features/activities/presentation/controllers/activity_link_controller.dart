import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/action_result.dart';
import '../../../prospects/data/models/prospect_ref.dart';
import '../../data/models/activity.dart';
import '../../domain/activities_repository.dart';

/// Links an existing activity to a prospect. The activity is updated in
/// place on the server (no new activity is created) and callers refresh
/// their lists only after the server confirmed.
class ActivityLinkController extends GetxController {
  ActivityLinkController({required ActivitiesRepository repository})
    : _repository = repository;

  final ActivitiesRepository _repository;

  final isLinking = false.obs;

  /// Whether linking [activity] to [target] replaces another prospect and
  /// therefore needs the user's confirmation first.
  bool needsConfirmation(Activity activity, ProspectRef target) =>
      activity.isLinked && activity.prospect!.id != target.id;

  Future<ActionResult<Activity>> link(
    Activity activity,
    ProspectRef target, {
    bool confirmRelink = false,
  }) async {
    if (isLinking.value) {
      return ActionResult.failure(CancelledApiException(tr.errBusy));
    }
    if (activity.isFromFollowUp && needsConfirmation(activity, target)) {
      return ActionResult.failure(
        BadRequestException(tr.activityFromFollowUpLocked),
      );
    }
    if (needsConfirmation(activity, target) && !confirmRelink) {
      return ActionResult.failure(BadRequestException(tr.relinkTitle));
    }
    isLinking.value = true;
    try {
      return await ActionResult.guard(
        () => _repository.linkToProspect(
          activity.id,
          target.id,
          confirmRelink: confirmRelink,
        ),
      );
    } finally {
      isLinking.value = false;
    }
  }
}
