import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../data/models/product.dart';
import '../../../../app/l10n/l10n.dart';

/// Multi-select of products shown as filter chips.
///
/// Only active products can be newly selected; an inactive product already
/// associated stays visible (and can be removed).
class ProductSelector extends StatelessWidget {
  const ProductSelector({
    super.key,
    required this.products,
    required this.selectedIds,
    required this.onToggle,
    this.errorText,
    this.enabled = true,
  });

  final List<Product> products;
  final Set<int> selectedIds;
  final void Function(int productId, bool selected) onToggle;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final visible = products
        .where((p) => p.isActive || selectedIds.contains(p.id))
        .toList();
    return InputDecorator(
      decoration: InputDecoration(
        labelText: tr.interestedProducts,
        errorText: errorText,
        helperText: tr.selectedCount(selectedIds.length),
      ),
      child: visible.isEmpty
          ? Text(tr.noActiveProducts, style: context.text.bodySmall)
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final product in visible)
                  FilterChip(
                    label: Text(
                      product.isActive
                          ? product.name
                          : tr.productInactiveSuffix(product.name),
                    ),
                    selected: selectedIds.contains(product.id),
                    onSelected: !enabled
                        ? null
                        : (selected) {
                            if (selected && !product.isActive) return;
                            onToggle(product.id, selected);
                          },
                  ),
              ],
            ),
    );
  }
}

/// Read-only list of product chips.
class ProductChips extends StatelessWidget {
  const ProductChips({super.key, required this.products, this.max});

  final List<Product> products;
  final int? max;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Text('—', style: context.text.bodyMedium);
    }
    final shown = max == null ? products : products.take(max!).toList();
    final rest = products.length - shown.length;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final p in shown)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(p.name, style: context.text.labelSmall),
          ),
        if (rest > 0)
          Tooltip(
            message: products.skip(shown.length).map((p) => p.name).join(', '),
            child: Text('+$rest', style: context.text.labelSmall),
          ),
      ],
    );
  }
}
