import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/whatsapp_button.dart';
import '../../../activities/presentation/widgets/activity_widgets.dart';
import '../../data/models/follow_up.dart';
import '../../../../app/l10n/l10n.dart';

import 'package:hugeicons/hugeicons.dart';
/// Planned type of a follow-up (call, appointment, message) with its icon.
class FollowUpTypeLabel extends StatelessWidget {
  const FollowUpTypeLabel(this.followUp, {super.key, this.compact = false});

  final FollowUp followUp;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final type = followUp.activityType;
    if (type == null) {
      return Tooltip(
        message: tr.followUpTypeMissing,
        child: Text('—', style: context.text.bodyMedium),
      );
    }
    final color = activityColor(type);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: activityIcon(type), size: compact ? 15 : 18, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            type.label,
            overflow: TextOverflow.ellipsis,
            style: (compact ? context.text.bodySmall : context.text.bodyMedium)
                ?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class FollowUpStatusPill extends StatelessWidget {
  const FollowUpStatusPill(this.followUp, {super.key});

  final FollowUp followUp;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    if (followUp.isOverdue()) {
      return StatusPill(
        label: tr.followUpViewOverdue,
        color: crm.danger,
        icon: HugeIcons.strokeRoundedAlert02,
      );
    }
    return switch (followUp.status) {
      FollowUpStatus.pending => StatusPill(
        label: tr.followUpStatusPending,
        color: crm.info,
        icon: HugeIcons.strokeRoundedTime02,
      ),
      FollowUpStatus.completed => StatusPill(
        label: tr.followUpStatusCompleted,
        color: crm.success,
        icon: HugeIcons.strokeRoundedTick02,
      ),
      FollowUpStatus.cancelled => StatusPill(
        label: tr.followUpStatusCancelled,
        color: context.colors.outline,
        icon: HugeIcons.strokeRoundedCancel02,
      ),
    };
  }
}

/// Compact follow-up row with quick actions (prospect page).
class FollowUpTile extends StatelessWidget {
  const FollowUpTile({
    super.key,
    required this.followUp,
    this.phone,
    this.onComplete,
    this.onEdit,
    this.onCancel,
    this.onTap,
  });

  final FollowUp followUp;
  final String? phone;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  /// Opens the follow-up (view / reschedule / complete).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final overdue = followUp.isOverdue();
    final crm = context.crm;
    final tile = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: overdue ? crm.dangerContainer.withValues(alpha: 0.6) : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: overdue
              ? crm.danger.withValues(alpha: 0.4)
              : context.colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          HugeIcon(icon: 
            followUp.isPending
                ? HugeIcons.strokeRoundedCalendar01
                : HugeIcons.strokeRoundedCalendarCheck01,
            color: overdue ? crm.danger : context.colors.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FollowUpTypeLabel(followUp, compact: true),
                    Text(
                      Formatters.dateTime(followUp.dueAt),
                      style: context.text.titleSmall?.copyWith(
                        color: overdue ? crm.danger : null,
                      ),
                    ),
                    FollowUpStatusPill(followUp),
                  ],
                ),
                if (followUp.description != null) ...[
                  const SizedBox(height: 2),
                  Text(followUp.description!, style: context.text.bodyMedium),
                ],
                if (followUp.closingNote != null)
                  Text(
                    followUp.status == FollowUpStatus.cancelled
                        ? tr.reasonLine(followUp.closingNote!)
                        : tr.outcomeLine(followUp.closingNote!),
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (followUp.isPending) ...[
            if (phone != null || followUp.prospect?.phone != null)
              WhatsAppIconButton(phone: phone ?? followUp.prospect?.phone),
            if (onComplete != null)
              IconButton(
                tooltip: tr.markAsDone,
                icon: HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01, color: crm.success),
                onPressed: onComplete,
              ),
            if (onEdit != null)
              IconButton(
                tooltip: tr.actionEdit,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedEdit02, size: 20),
                onPressed: onEdit,
              ),
            if (onCancel != null)
              IconButton(
                tooltip: tr.cancelFollowUp,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendarRemove02, size: 20),
                onPressed: onCancel,
              ),
          ],
        ],
      ),
    );
    if (onTap == null) return tile;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: tile,
    );
  }
}
