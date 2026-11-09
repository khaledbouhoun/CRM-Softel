import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../prospects/presentation/dialogs/prospect_search_dialog.dart';
import '../../data/models/activity.dart';
import '../controllers/activity_link_controller.dart';
import 'activity_form_dialog.dart';

/// "Link to prospect" for an existing activity: search a prospect (all
/// stages, by name, company, phone or id), confirm when this changes an
/// existing link, then link. Resolves with the updated activity, or null when
/// cancelled or refused. The caller refreshes its view after this returns.
Future<Activity?> linkActivityToProspect(Activity activity) async {
  if (activity.isFromFollowUp) {
    AppFeedback.warning(tr.activityFromFollowUpLocked);
    return null;
  }
  final target = await showProspectSearchDialog(
    title: activity.isLinked ? tr.changeLinkedProspect : tr.linkToProspect,
    excludeProspectId: activity.prospect?.id,
  );
  if (target == null) return null;

  final linker = ActivityLinkController(repository: Get.find());
  final needsConfirmation = linker.needsConfirmation(activity, target);
  if (needsConfirmation) {
    final ok = await confirmRelink(
      from: activity.prospect!.companyName,
      to: target.companyName,
    );
    if (!ok) return null;
  }
  final result = await linker.link(
    activity,
    target,
    confirmRelink: needsConfirmation,
  );
  if (!result.isSuccess) {
    AppFeedback.error(result.error!);
    return null;
  }
  AppFeedback.success(tr.activityLinkedTo(target.companyName));
  return result.value;
}
