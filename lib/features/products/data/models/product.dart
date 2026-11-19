import '../../../../core/utils/json_utils.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.prospectsCount,
    this.packId,
    this.packName,
    this.demoUrl,
  });

  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final int? prospectsCount;

  /// Pack (suite of tiers, e.g. GestCom Basic / Ultra) the product belongs
  /// to. A customer may pick only one product per pack.
  final int? packId;
  final String? packName;

  /// Fixed demo link configured on the product. Demos are generated from it;
  /// products without one cannot be offered as a demo.
  final String? demoUrl;

  bool get hasDemo => demoUrl != null && demoUrl!.trim().isNotEmpty;

  factory Product.fromJson(JsonMap json) {
    final pack = asMapOrNull(json['pack']);
    return Product(
      id: asInt(json['id']),
      name: asString(json['name']),
      description: asStringOrNull(json['description']),
      isActive: asBool(json['is_active'], fallback: true),
      prospectsCount: asIntOrNull(json['prospects_count']),
      packId: asIntOrNull(json['pack_id']) ?? asIntOrNull(pack?['id']),
      packName: asStringOrNull(pack?['name']),
      demoUrl: asStringOrNull(json['demo_url']),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'is_active': isActive,
    if (prospectsCount != null) 'prospects_count': prospectsCount,
    'pack_id': ?packId,
    'demo_url': ?demoUrl,
  };

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product($id, $name)';
}

/// Body of POST/PUT `/products`.
class ProductPayload {
  const ProductPayload({
    required this.name,
    this.description,
    this.isActive = true,
  });

  final String name;
  final String? description;
  final bool isActive;

  JsonMap toJson() {
    final desc = description?.trim();
    return {
      'name': name.trim(),
      'description': (desc == null || desc.isEmpty) ? null : desc,
      'is_active': isActive,
    };
  }
}
