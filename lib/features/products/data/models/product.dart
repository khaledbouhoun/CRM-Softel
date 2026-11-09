import '../../../../core/utils/json_utils.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.prospectsCount,
  });

  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final int? prospectsCount;

  factory Product.fromJson(JsonMap json) => Product(
    id: asInt(json['id']),
    name: asString(json['name']),
    description: asStringOrNull(json['description']),
    isActive: asBool(json['is_active'], fallback: true),
    prospectsCount: asIntOrNull(json['prospects_count']),
  );

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'is_active': isActive,
    if (prospectsCount != null) 'prospects_count': prospectsCount,
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
