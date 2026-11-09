import 'package:flutter/material.dart';

import '../../app/config/app_config.dart';
import '../../app/theme/app_theme.dart';
import '../network/api_response.dart';
import '../utils/formatters.dart';
import '../../app/l10n/l10n.dart';

/// "1–25 sur 92 · 25 par page · ‹ 1 / 4 ›"
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.onPageChanged,
    this.onPerPageChanged,
    this.enabled = true,
  });

  final Paginated<Object?> page;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPerPageChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final muted = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    final perPage = AppConfig.pageSizes.contains(page.perPage)
        ? page.perPage
        : AppConfig.defaultPageSize;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Text(
            page.total == 0
                ? tr.noResults
                : tr.rangeOfTotal(
                    page.from,
                    page.to,
                    Formatters.number(page.total),
                  ),
            style: muted,
          ),
          const Spacer(),
          if (onPerPageChanged != null) ...[
            Text(tr.perPage, style: muted),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: perPage,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                for (final size in AppConfig.pageSizes)
                  DropdownMenuItem(value: size, child: Text('$size')),
              ],
              onChanged: enabled
                  ? (v) => v == null ? null : onPerPageChanged!(v)
                  : null,
            ),
            const SizedBox(width: 20),
          ],
          IconButton(
            tooltip: tr.pageFirst,
            icon: const Icon(Icons.first_page),
            onPressed: enabled && page.hasPrevious
                ? () => onPageChanged(1)
                : null,
          ),
          IconButton(
            tooltip: tr.pagePrevious,
            icon: const Icon(Icons.chevron_left),
            onPressed: enabled && page.hasPrevious
                ? () => onPageChanged(page.currentPage - 1)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              tr.pageOf(
                page.currentPage,
                page.lastPage < 1 ? 1 : page.lastPage,
              ),
              style: context.text.bodyMedium,
            ),
          ),
          IconButton(
            tooltip: tr.pageNext,
            icon: const Icon(Icons.chevron_right),
            onPressed: enabled && page.hasNext
                ? () => onPageChanged(page.currentPage + 1)
                : null,
          ),
          IconButton(
            tooltip: tr.pageLast,
            icon: const Icon(Icons.last_page),
            onPressed: enabled && page.hasNext
                ? () => onPageChanged(page.lastPage)
                : null,
          ),
        ],
      ),
    );
  }
}
