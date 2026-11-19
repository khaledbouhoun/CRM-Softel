import '../data/models/product.dart';

/// "One product per pack": the tiers of a suite (Basic, Ultra...) share a
/// `pack_id` and a customer may hold only one of them. The server enforces
/// it (`422` on `product_ids`); the UI applies the same rule while the
/// employee ticks products, so the conflict never has to be reported.
abstract final class PackRules {
  /// Selected products that must be unchecked when [productId] is checked:
  /// the other selected members of the same pack.
  static List<Product> siblingsToClear({
    required Iterable<Product> catalog,
    required Iterable<int> selected,
    required int productId,
  }) {
    final byId = {for (final p in catalog) p.id: p};
    final packId = byId[productId]?.packId;
    if (packId == null) return const [];
    return [
      for (final id in selected)
        if (id != productId && byId[id]?.packId == packId) byId[id]!,
    ];
  }

  /// Returns [selected] after checking/unchecking [productId], applying the
  /// pack rule. [replaced] receives the products that were dropped.
  static Set<int> toggle({
    required Iterable<Product> catalog,
    required Set<int> selected,
    required int productId,
    required bool checked,
    void Function(List<Product> replaced)? onReplaced,
  }) {
    final next = {...selected};
    if (!checked) {
      next.remove(productId);
      return next;
    }
    final replaced = siblingsToClear(
      catalog: catalog,
      selected: selected,
      productId: productId,
    );
    for (final p in replaced) {
      next.remove(p.id);
    }
    next.add(productId);
    if (replaced.isNotEmpty) onReplaced?.call(replaced);
    return next;
  }

  /// Name of the first pack that has more than one selected product, or null
  /// when the selection is valid.
  static String? firstConflict({
    required Iterable<Product> catalog,
    required Iterable<int> selected,
  }) {
    final byId = {for (final p in catalog) p.id: p};
    final seen = <int>{};
    for (final id in selected) {
      final pack = byId[id]?.packId;
      if (pack == null) continue;
      if (!seen.add(pack)) return byId[id]?.packName ?? '#$pack';
    }
    return null;
  }
}
