import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../data/models/sales_stage.dart';
import '../../../../app/l10n/l10n.dart';

IconData stageTypeIcon(StageType type) => switch (type) {
  StageType.open => Icons.radio_button_unchecked,
  StageType.won => Icons.emoji_events_outlined,
  StageType.lost => Icons.do_not_disturb_on_outlined,
};

/// Colored chip showing a stage; won/lost stages get an icon.
class StageChip extends StatelessWidget {
  const StageChip({super.key, required this.stage, this.dense = false});

  final SalesStage? stage;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final s = stage;
    if (s == null) {
      return Text('—', style: context.text.bodyMedium);
    }
    final color = s.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 9,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (s.type == StageType.open)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          else
            Icon(stageTypeIcon(s.type), size: 13, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              s.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: dense ? 12 : 12.5,
                fontWeight: FontWeight.w600,
                color: Color.lerp(color, context.colors.onSurface, 0.35),
              ),
            ),
          ),
          if (!s.isActive) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: tr.stageDeactivated,
              child: Icon(
                Icons.visibility_off_outlined,
                size: 12,
                color: context.colors.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small colored dot for dropdown items.
class StageDot extends StatelessWidget {
  const StageDot(this.stage, {super.key});

  final SalesStage stage;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: stage.color, shape: BoxShape.circle),
  );
}

class StageTypeBadge extends StatelessWidget {
  const StageTypeBadge(this.type, {super.key});

  final StageType type;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final color = switch (type) {
      StageType.open => crm.info,
      StageType.won => crm.success,
      StageType.lost => crm.danger,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stageTypeIcon(type), size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
