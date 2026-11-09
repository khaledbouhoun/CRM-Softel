import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../utils/debouncer.dart';
import '../utils/formatters.dart';
import '../../app/l10n/l10n.dart';

/// Search box that reports changes after the user stops typing.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.initialValue = '',
    this.hint,
    this.width = 300,
  });

  final ValueChanged<String> onChanged;
  final String initialValue;
  final String? hint;
  final double width;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _controller = TextEditingController(text: widget.initialValue);
  final _debouncer = Debouncer();

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    child: TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hint ?? tr.searchHint,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: tr.actionClear,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _controller.clear();
                    _debouncer.dispose();
                    widget.onChanged('');
                  },
                ),
        ),
      ),
      onChanged: (value) => _debouncer.run(() => widget.onChanged(value)),
      onSubmitted: (value) {
        _debouncer.dispose();
        widget.onChanged(value);
      },
    ),
  );
}

/// Compact dropdown used in filter bars. `null` means "all".
class FilterDropdown<T> extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.width = 200,
    this.allLabel,
    this.leading,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final double width;
  final String? allLabel;
  final Widget Function(T item)? leading;

  @override
  Widget build(BuildContext context) {
    // Avoid an assertion if the selected value disappeared from the list.
    final current = items.contains(value) ? value : null;
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T?>(
        initialValue: current,
        key: ValueKey('$label-${current.hashCode}-${items.length}'),
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          DropdownMenuItem<T?>(
            value: null,
            child: Text(allLabel ?? tr.filterAll),
          ),
          for (final item in items)
            DropdownMenuItem<T?>(
              value: item,
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!(item),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      itemLabel(item),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Button that opens a date-range picker; shows the selected range.
class DateRangeFilterButton extends StatelessWidget {
  const DateRangeFilterButton({
    super.key,
    required this.label,
    required this.from,
    required this.to,
    required this.onChanged,
  });

  final String label;
  final DateTime? from;
  final DateTime? to;
  final void Function(DateTime? from, DateTime? to) onChanged;

  @override
  Widget build(BuildContext context) {
    final hasValue = from != null || to != null;
    final text = hasValue
        ? '${Formatters.date(from)} → ${Formatters.date(to)}'
        : label;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.date_range, size: 18),
          label: Text(text),
          style: hasValue
              ? OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.primary),
                )
              : null,
          onPressed: () async {
            final now = DateTime.now();
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(now.year + 5),
              initialDateRange: from != null && to != null
                  ? DateTimeRange(start: from!, end: to!)
                  : null,
              helpText: label,
            );
            if (range != null) onChanged(range.start, range.end);
          },
        ),
        if (hasValue)
          IconButton(
            tooltip: tr.clearPeriod,
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => onChanged(null, null),
          ),
      ],
    );
  }
}
