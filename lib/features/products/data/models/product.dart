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
    this.isActiveOnWeb = false,
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

  /// Whether the product is published and active on the website & portal.
  final bool isActiveOnWeb;

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
      isActiveOnWeb: asBool(json['is_active_on_web'], fallback: false),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'is_active': isActive,
    if (prospectsCount != null) 'prospects_count': prospectsCount,
    'pack_id': packId,
    'demo_url': demoUrl,
    'is_active_on_web': isActiveOnWeb,
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
    this.packId,
    this.demoUrl,
    this.isActiveOnWeb = false,
  });

  final String name;
  final String? description;
  final bool isActive;
  final int? packId;
  final String? demoUrl;
  final bool isActiveOnWeb;

  JsonMap toJson() {
    final desc = description?.trim();
    final url = demoUrl?.trim();
    return {
      'name': name.trim(),
      'description': (desc == null || desc.isEmpty) ? null : desc,
      'is_active': isActive,
      'pack_id': packId,
      'demo_url': (url == null || url.isEmpty) ? null : url,
      'is_active_on_web': isActiveOnWeb,
    };
  }
}
