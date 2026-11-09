import 'package:flutter/material.dart';

import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/activity.dart';
import '../../data/models/activity_type.dart';
import '../../../../app/l10n/l10n.dart';

IconData activityIcon(ActivityType type) => switch (type) {
  ActivityType.call => Icons.call_outlined,
  ActivityType.meeting || ActivityType.appointment => Icons.groups_outlined,
  ActivityType.message => Icons.chat_bubble_outline,
  ActivityType.note => Icons.sticky_note_2_outlined,
  ActivityType.other => Icons.more_horiz,
};

Color activityColor(ActivityType type) => switch (type) {
  ActivityType.call => const Color(0xFF2563EB),
  ActivityType.meeting || ActivityType.appointment => const Color(0xFF7C3AED),
  ActivityType.message => const Color(0xFF0891B2),
  ActivityType.note => const Color(0xFFCA8A04),
  ActivityType.other => const Color(0xFF64748B),
};

/// Linked / unlinked badge of an activity.
class ActivityLinkPill extends StatelessWidget {
  const ActivityLinkPill({super.key, required this.linked});

  final bool linked;

  @override
  Widget build(BuildContext context) => linked
      ? StatusPill(
          label: tr.linkStatusLinked,
          color: context.crm.success,
          icon: Icons.link,
        )
      : StatusPill(
          label: tr.linkStatusUnlinked,
          color: context.crm.warning,
          icon: Icons.link_off,
        );
}

class ActivityTypeAvatar extends StatelessWidget {
  const ActivityTypeAvatar(this.type, {super.key, this.size = 34});

  final ActivityType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = activityColor(type);
    return Tooltip(
      message: type.label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(activityIcon(type), size: size * 0.52, color: color),
      ),
    );
  }
}

/// One entry of an activity timeline.
class ActivityTimelineTile extends StatelessWidget {
  const ActivityTimelineTile({
    super.key,
    required this.activity,
    this.showProspect = false,
    this.isLast = false,
  });

  final Activity activity;
  final bool showProspect;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    final prospect = activity.prospect;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              ActivityTypeAvatar(activity.type),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: context.colors.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        activity.type.label,
                        style: context.text.titleSmall?.copyWith(
                          color: activityColor(activity.type),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        Formatters.dateTime(activity.occurredAt),
                        style: context.text.bodySmall?.copyWith(color: muted),
                      ),
                      if (showProspect && prospect == null)
                        const ActivityLinkPill(linked: false),
                      if (showProspect && prospect != null)
                        InkWell(
                          onTap: () => AppNavigation.openProspect(prospect.id),
                          child: Text(
                            prospect.companyName.isEmpty
                                ? tr.prospectNumber(prospect.id)
                                : prospect.companyName,
                            style: context.text.bodySmall?.copyWith(
                              color: context.colors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (activity.title != null &&
                      activity.title!.trim().isNotEmpty)
                    SelectableText(
                      activity.title!,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (activity.description.trim().isNotEmpty)
                    SelectableText(
                      activity.description,
                      style: context.text.bodyMedium,
                    ),
                  if (activity.outcome != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHigh.withValues(
                          alpha: 0.6,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.flag_outlined, size: 15, color: muted),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              tr.outcomeLine(activity.outcome ?? ''),
                              style: context.text.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
