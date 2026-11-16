# -*- coding: utf-8 -*-
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import add_many, edit  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def write(path, text):
    with open(os.path.join(ROOT, path), 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


add_many([
    dict(key='validFieldTitle', fr='Le titre', en='The title', ar='العنوان'),
    dict(key='validMinLength', params={'min': 'Object'}, fr='{min} caractères minimum.',
         en='{min} characters minimum.', ar='{min} أحرف كحد أدنى.'),
])

edit('lib/core/utils/validators.dart', "  static String? maxLength(String? value, int max) {",
     "  static String? minLength(String? value, int min) {\n"
     "    final text = value?.trim() ?? '';\n"
     "    if (text.isEmpty || text.length >= min) return null;\n"
     "    return tr.validMinLength(min);\n"
     "  }\n\n"
     "  static String? maxLength(String? value, int max) {")

write('lib/features/activities/presentation/controllers/activity_link_controller.dart', """import 'package:get/get.dart';

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
  ActivityLinkController({required ActivitiesRepository repository}) : _repository = repository;

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
      return ActionResult.failure(BadRequestException(tr.activityFromFollowUpLocked));
    }
    if (needsConfirmation(activity, target) && !confirmRelink) {
      return ActionResult.failure(BadRequestException(tr.relinkTitle));
    }
    isLinking.value = true;
    try {
      return await ActionResult.guard(
        () => _repository.linkToProspect(activity.id, target.id, confirmRelink: confirmRelink),
      );
    } finally {
      isLinking.value = false;
    }
  }
}
""")

write('lib/features/activities/presentation/dialogs/link_activity_flow.dart', """import 'package:get/get.dart';

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
  final result = await linker.link(activity, target, confirmRelink: needsConfirmation);
  if (!result.isSuccess) {
    AppFeedback.error(result.error!);
    return null;
  }
  AppFeedback.success(tr.activityLinkedTo(target.companyName));
  return result.value;
}
""")

write('lib/features/activities/presentation/dialogs/activity_details_dialog.dart', """import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../../data/models/activity.dart';
import '../widgets/activity_widgets.dart';
import 'link_activity_flow.dart';

/// Read-only view of an activity with the link actions. Resolves with the
/// updated activity when it was linked / re-linked from here.
Future<Activity?> showActivityDetailsDialog(Activity activity) =>
    Get.dialog<Activity>(_ActivityDetailsDialog(activity));

class _ActivityDetailsDialog extends StatefulWidget {
  const _ActivityDetailsDialog(this.initial);

  final Activity initial;

  @override
  State<_ActivityDetailsDialog> createState() => _ActivityDetailsDialogState();
}

class _ActivityDetailsDialogState extends State<_ActivityDetailsDialog> {
  late Activity _activity = widget.initial;
  bool _changed = false;

  Future<void> _link() async {
    final updated = await linkActivityToProspect(_activity);
    if (updated != null && mounted) {
      setState(() {
        _activity = updated;
        _changed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _activity;
    final prospect = a.prospect;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ActivityTypeAvatar(a.type),
                  const SizedBox(width: 12),
                  Expanded(child: Text(tr.activityDetails, style: context.text.titleLarge)),
                  IconButton(
                    tooltip: tr.actionClose,
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(result: _changed ? _activity : null),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (a.title != null && a.title!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SelectableText(a.title!, style: context.text.titleMedium),
                        ),
                      InfoRow(label: tr.fieldType, child: Text(a.type.label)),
                      InfoRow(label: tr.activityOccurredAt, child: Text(Formatters.dateTime(a.occurredAt))),
                      InfoRow(
                        label: tr.originLabel,
                        child: Text(a.isFromFollowUp ? tr.originFollowUp : tr.originDirect),
                      ),
                      InfoRow(
                        label: tr.linkedProspectLabel,
                        child: prospect == null
                            ? ActivityLinkPill(linked: false)
                            : Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Get.back(result: _changed ? _activity : null);
                                      AppNavigation.openProspect(prospect.id);
                                    },
                                    child: Text(
                                      prospect.companyName.isEmpty
                                          ? tr.prospectNumber(prospect.id)
                                          : prospect.displayName,
                                      style: TextStyle(
                                        color: context.colors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  StageChip(stage: prospect.stage, dense: true),
                                ],
                              ),
                      ),
                      if (a.linkedAt != null)
                        InfoRow(label: tr.linkedOnLabel, child: Text(Formatters.dateTime(a.linkedAt))),
                      InfoRow(label: tr.createdOnLabel, child: Text(Formatters.dateTime(a.createdAt))),
                      if (a.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(tr.activityDiscussionLabel, style: context.text.labelLarge),
                        const SizedBox(height: 4),
                        SelectableText(a.description, style: context.text.bodyMedium),
                      ],
                      if (a.outcome != null && a.outcome!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(tr.fieldOutcome, style: context.text.labelLarge),
                        const SizedBox(height: 4),
                        SelectableText(a.outcome!, style: context.text.bodyMedium),
                      ],
                      if (a.isFromFollowUp) ...[
                        const SizedBox(height: 12),
                        Text(
                          tr.activityFromFollowUpLocked,
                          style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (prospect != null)
                    TextButton.icon(
                      onPressed: () {
                        Get.back(result: _changed ? _activity : null);
                        AppNavigation.openProspect(prospect.id);
                      },
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: Text(tr.openProspect),
                    ),
                  const SizedBox(width: 8),
                  if (!a.isFromFollowUp)
                    FilledButton.icon(
                      onPressed: _link,
                      icon: const Icon(Icons.link, size: 18),
                      label: Text(a.isLinked ? tr.changeLinkedProspect : tr.linkToProspect),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""")
print('ctrl1 ok')
