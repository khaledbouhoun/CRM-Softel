import 'package:flutter/material.dart';
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
                  Expanded(
                    child: Text(
                      tr.activityDetails,
                      style: context.text.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: tr.actionClose,
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        Get.back(result: _changed ? _activity : null),
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
                          child: SelectableText(
                            a.title!,
                            style: context.text.titleMedium,
                          ),
                        ),
                      InfoRow(label: tr.fieldType, value: a.type.label),
                      InfoRow(
                        label: tr.activityOccurredAt,
                        value: Formatters.dateTime(a.occurredAt),
                      ),
                      InfoRow(
                        label: tr.originLabel,
                        value: a.isFromFollowUp
                            ? tr.originFollowUp
                            : tr.originDirect,
                      ),
                      InfoRow(
                        label: tr.linkedProspectLabel,
                        child: prospect == null
                            ? const ActivityLinkPill(linked: false)
                            : Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Get.back(
                                        result: _changed ? _activity : null,
                                      );
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
                                  if (prospect.stage != null)
                                    StageChip(
                                      stage: prospect.stage,
                                      dense: true,
                                    ),
                                ],
                              ),
                      ),
                      if (a.linkedAt != null)
                        InfoRow(
                          label: tr.linkedOnLabel,
                          value: Formatters.dateTime(a.linkedAt),
                        ),
                      InfoRow(
                        label: tr.createdOnLabel,
                        value: Formatters.dateTime(a.createdAt),
                      ),
                      if (a.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          tr.activityDiscussionLabel,
                          style: context.text.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          a.description,
                          style: context.text.bodyMedium,
                        ),
                      ],
                      if (a.outcome != null &&
                          a.outcome!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(tr.fieldOutcome, style: context.text.labelLarge),
                        const SizedBox(height: 4),
                        SelectableText(
                          a.outcome!,
                          style: context.text.bodyMedium,
                        ),
                      ],
                      if (a.isFromFollowUp) ...[
                        const SizedBox(height: 12),
                        Text(
                          tr.activityFromFollowUpLocked,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
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
                      label: Text(
                        a.isLinked
                            ? tr.changeLinkedProspect
                            : tr.linkToProspect,
                      ),
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
