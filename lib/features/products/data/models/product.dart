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
    this.slug,
    this.imagePath,
    this.gallery = const [],
    this.fullDescription,
    this.features = const [],
    this.specifications,
    this.titleI18n,
    this.summaryI18n,
    this.descriptionI18n,
    this.sortOrder = 0,
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

  /// Public catalog data (website & client portal).
  final String? slug;

  /// Hero image / logo URL of the product.
  final String? imagePath;
  final List<String> gallery;
  final String? fullDescription;
  final List<String> features;
  final Map<String, dynamic>? specifications;

  /// Per-language public texts, keys `ar` / `fr` / `en`.
  final Map<String, String>? titleI18n;
  final Map<String, String>? summaryI18n;
  final Map<String, String>? descriptionI18n;
  final int sortOrder;

  bool get hasImage => imagePath != null && imagePath!.trim().isNotEmpty;

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
      slug: asStringOrNull(json['slug']),
      imagePath: asStringOrNull(json['image_path']),
      gallery: _stringList(json['gallery']),
      fullDescription: asStringOrNull(json['full_description']),
      features: _stringList(json['features']),
      specifications: _specifications(json['specifications']),
      titleI18n: _i18n(json['title_i18n']),
      summaryI18n: _i18n(json['summary_i18n']),
      descriptionI18n: _i18n(json['description_i18n']),
      sortOrder: asInt(json['sort_order']),
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
    'slug': slug,
    'image_path': imagePath,
    'gallery': gallery,
    'full_description': fullDescription,
    'features': features,
    'specifications': specifications ?? const <String, dynamic>{},
    'title_i18n': titleI18n,
    'summary_i18n': summaryI18n,
    'description_i18n': descriptionI18n,
    'sort_order': sortOrder,
  };

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product($id, $name)';
}

List<String> _stringList(Object? value) => value is List
    ? [
        for (final e in value)
          if (e != null && e.toString().trim().isNotEmpty) e.toString(),
      ]
    : const [];

Map<String, dynamic>? _specifications(Object? value) =>
    value is Map && value.isNotEmpty ? Map<String, dynamic>.from(value) : null;

/// `{ar: .., fr: .., en: ..}` -> map of non-empty strings (null when empty).
Map<String, String>? _i18n(Object? value) {
  if (value is! Map) return null;
  final out = <String, String>{
    for (final e in value.entries)
      if (e.value != null && e.value.toString().trim().isNotEmpty)
        e.key.toString(): e.value.toString(),
  };
  return out.isEmpty ? null : out;
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
    this.slug,
    this.imagePath,
    this.features,
    this.fullDescription,
    this.titleI18n,
    this.summaryI18n,
    this.descriptionI18n,
    this.sortOrder,
  });

  final String name;
  final String? description;
  final bool isActive;
  final int? packId;
  final String? demoUrl;
  final bool isActiveOnWeb;

  /// Catalog fields: `null` means "not managed here" and is left out of the
  /// request so the server keeps its current value.
  final String? slug;
  final String? imagePath;
  final List<String>? features;
  final String? fullDescription;
  final Map<String, String>? titleI18n;
  final Map<String, String>? summaryI18n;
  final Map<String, String>? descriptionI18n;
  final int? sortOrder;

  static String? _blankToNull(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static Map<String, String>? _cleanI18n(Map<String, String> m) {
    final out = <String, String>{
      for (final e in m.entries)
        if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
    };
    return out.isEmpty ? null : out;
  }

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
      if (slug != null) 'slug': _blankToNull(slug),
      if (imagePath != null) 'image_path': _blankToNull(imagePath),
      if (features != null)
        'features': [
          for (final f in features!)
            if (f.trim().isNotEmpty) f.trim(),
        ],
      if (fullDescription != null)
        'full_description': _blankToNull(fullDescription),
      if (titleI18n != null) 'title_i18n': _cleanI18n(titleI18n!),
      if (summaryI18n != null) 'summary_i18n': _cleanI18n(summaryI18n!),
      if (descriptionI18n != null)
        'description_i18n': _cleanI18n(descriptionI18n!),
      if (sortOrder != null) 'sort_order': sortOrder,
    };
  }
}
