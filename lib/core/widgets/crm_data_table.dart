import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Column definition for [CrmDataTable].
class CrmColumn<T> {
  const CrmColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.width,
    this.sortKey,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final String label;
  final Widget Function(T item) cell;

  /// Used when [width] is null.
  final int flex;
  final double? width;

  /// Non-null when the column is sortable (server-side).
  final Object? sortKey;
  final AlignmentGeometry alignment;
}

/// Desktop data table with sortable headers, hover highlight and row click.
/// Sorting and paging are driven by the caller (server-side).
class CrmDataTable<T> extends StatelessWidget {
  const CrmDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.sortKey,
    this.ascending = true,
    this.onSort,
    this.rowHeight = 52,
    this.highlight,
  });

  final List<CrmColumn<T>> columns;
  final List<T> rows;
  final ValueChanged<T>? onRowTap;
  final Object? sortKey;
  final bool ascending;
  final ValueChanged<Object>? onSort;
  final double rowHeight;

  /// Optional background tint per row (e.g. overdue).
  final Color? Function(T item)? highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Column(
      children: [
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
            border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
          ),
          child: Row(children: [for (final c in columns) _header(context, c)]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: rows.length,
            itemExtent: rowHeight,
            itemBuilder: (context, index) => _DataRow<T>(
              item: rows[index],
              columns: columns,
              onTap: onRowTap,
              tint: highlight?.call(rows[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _wrap(CrmColumn<T> column, Widget child) => column.width != null
      ? SizedBox(width: column.width, child: child)
      : Expanded(flex: column.flex, child: child);

  Widget _header(BuildContext context, CrmColumn<T> column) {
    final isSorted = column.sortKey != null && column.sortKey == sortKey;
    final style = context.text.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: isSorted
          ? context.colors.primary
          : context.colors.onSurfaceVariant,
      letterSpacing: 0.2,
    );
    Widget label = Text(
      column.label.toUpperCase(),
      style: style,
      overflow: TextOverflow.ellipsis,
    );
    if (column.sortKey != null && onSort != null) {
      label = InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => onSort!(column.sortKey!),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: label),
              const SizedBox(width: 4),
              Icon(
                isSorted
                    ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 14,
                color: style?.color,
              ),
            ],
          ),
        ),
      );
    }
    return _wrap(
      column,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(alignment: column.alignment, child: label),
      ),
    );
  }
}

class _DataRow<T> extends StatefulWidget {
  const _DataRow({
    required this.item,
    required this.columns,
    this.onTap,
    this.tint,
  });

  final T item;
  final List<CrmColumn<T>> columns;
  final ValueChanged<T>? onTap;
  final Color? tint;

  @override
  State<_DataRow<T>> createState() => _DataRowState<T>();
}

class _DataRowState<T> extends State<_DataRow<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final bg = _hover
        ? scheme.primary.withValues(alpha: 0.05)
        : (widget.tint ?? Colors.transparent);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap == null ? null : () => widget.onTap!(widget.item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              bottom: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              for (final c in widget.columns)
                c.width != null
                    ? SizedBox(width: c.width, child: _cell(c))
                    : Expanded(flex: c.flex, child: _cell(c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(CrmColumn<T> c) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Align(alignment: c.alignment, child: c.cell(widget.item)),
  );
}

/// Single-line text cell with optional secondary line.
class CellText extends StatelessWidget {
  const CellText(
    this.primary, {
    super.key,
    this.secondary,
    this.bold = false,
    this.color,
  });

  final String primary;
  final String? secondary;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      primary.isEmpty ? '—' : primary,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.text.bodyMedium?.copyWith(
        fontWeight: bold ? FontWeight.w600 : null,
        color: color,
      ),
    );
    if (secondary == null || secondary!.isEmpty) return text;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text,
        Text(
          secondary!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
