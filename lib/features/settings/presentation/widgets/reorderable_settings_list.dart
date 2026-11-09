import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/l10n/l10n.dart';

/// Reorderable list used by settings screens: drag handle + up/down buttons
/// (keyboard/mouse friendly alternative to dragging).
class ReorderableSettingsList<T> extends StatelessWidget {
  const ReorderableSettingsList({
    super.key,
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
    required this.onMove,
    this.enabled = true,
  });

  final List<T> items;
  final Object Function(T item) keyOf;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Moves an item from index [from] to final index [to].
  final void Function(int from, int to) onMove;
  final bool enabled;

  @override
  Widget build(BuildContext context) => ReorderableListView.builder(
    buildDefaultDragHandles: false,
    padding: const EdgeInsets.symmetric(vertical: 4),
    itemCount: items.length,
    // `newIndex` is already adjusted for the removed item.
    onReorderItem: (oldIndex, newIndex) {
      if (enabled) onMove(oldIndex, newIndex);
    },
    itemBuilder: (context, index) {
      final item = items[index];
      return Container(
        key: ValueKey(keyOf(item)),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLowest,
          border: Border(
            bottom: BorderSide(
              color: context.colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              enabled: enabled,
              child: MouseRegion(
                cursor: enabled ? SystemMouseCursors.grab : MouseCursor.defer,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.drag_indicator,
                    color: context.colors.outline,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 34,
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),
            ),
            Expanded(child: itemBuilder(context, item)),
            IconButton(
              tooltip: tr.actionMoveUp,
              icon: const Icon(Icons.arrow_upward, size: 18),
              onPressed: enabled && index > 0
                  ? () => onMove(index, index - 1)
                  : null,
            ),
            IconButton(
              tooltip: tr.actionMoveDown,
              icon: const Icon(Icons.arrow_downward, size: 18),
              onPressed: enabled && index < items.length - 1
                  ? () => onMove(index, index + 1)
                  : null,
            ),
          ],
        ),
      );
    },
  );
}
