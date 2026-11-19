import '../../../../core/models/named_ref.dart';
import '../../../../core/utils/json_utils.dart';

/// Who may see a release in the customer portal.
abstract final class ReleaseAudience {
  static const all = 'all';
  static const owned = 'owned';
  static const specific = 'specific';
  static const values = [all, owned, specific];
}

/// Installer binary attached to a release (`.exe`, `.zip`, `.rar`).
class ReleaseInstaller {
  const ReleaseInstaller({required this.name, this.size});

  final String name;
  final int? size;

  static ReleaseInstaller? fromJsonOrNull(Object? value) {
    final json = asMapOrNull(value);
    if (json == null) return null;
    return ReleaseInstaller(
      name: asString(json['name']),
      size: asIntOrNull(json['size']),
    );
  }
}

/// A published (or draft) version of a product.
class ProductRelease {
  const ProductRelease({
    required this.id,
    required this.versionNumber,
    required this.audience,
    this.product,
    this.changelog,
    this.downloadUrl,
    this.installer,
    this.releaseDate,
    this.customerIds = const [],
    this.isPublished = false,
    this.createdBy,
    this.createdAt,
  });

  final int id;
  final NamedRef? product;
  final String versionNumber;
  final String? changelog;

  /// External download link (alternative to the installer file).
  final String? downloadUrl;
  final ReleaseInstaller? installer;
  final DateTime? releaseDate;
  final String audience;
  final List<int> customerIds;
  final bool isPublished;
  final String? createdBy;
  final DateTime? createdAt;

  bool get hasInstaller => installer != null;
  bool get hasExternalLink => downloadUrl != null && downloadUrl!.isNotEmpty;

  factory ProductRelease.fromJson(JsonMap json) {
    final ids = json['customer_ids'];
    return ProductRelease(
      id: asInt(json['id']),
      product: NamedRef.fromJsonOrNull(json['product']),
      versionNumber: asString(json['version_number']),
      changelog: asStringOrNull(json['changelog']),
      downloadUrl: asStringOrNull(json['download_url']),
      installer: ReleaseInstaller.fromJsonOrNull(json['installer']),
      releaseDate: asDateTimeOrNull(json['release_date']),
      audience: asString(json['audience'], fallback: ReleaseAudience.all),
      customerIds: ids is List ? [for (final v in ids) asInt(v)] : const [],
      isPublished: asBool(json['is_published']),
      createdBy: asStringOrNull(json['created_by']),
      createdAt: asDateTimeOrNull(json['created_at']),
    );
  }
}

/// Body of `POST /product-releases` and `PUT /product-releases/{id}`.
class ReleasePayload {
  const ReleasePayload({
    required this.productId,
    required this.versionNumber,
    required this.releaseDate,
    required this.audience,
    this.changelog,
    this.downloadUrl,
    this.customerIds = const [],
    this.isPublished = false,
  });

  final int productId;
  final String versionNumber;
  final DateTime releaseDate;
  final String audience;
  final String? changelog;
  final String? downloadUrl;
  final List<int> customerIds;
  final bool isPublished;

  String? get _changelog {
    final t = changelog?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  String? get _url {
    final t = downloadUrl?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  /// JSON body (update, or create without an installer).
  JsonMap toJson() => {
    'product_id': productId,
    'version_number': versionNumber.trim(),
    'release_date': toApiDate(releaseDate),
    'audience': audience,
    'changelog': _changelog,
    'download_url': _url,
    if (audience == ReleaseAudience.specific) 'customer_ids': customerIds,
    'is_published': isPublished,
  };

  /// Flat text fields of the multipart form (create with an installer).
  /// Arrays use Laravel's `name[]` convention; empty values are omitted.
  List<MapEntry<String, String>> toFormFields() => [
    MapEntry('product_id', '$productId'),
    MapEntry('version_number', versionNumber.trim()),
    MapEntry('release_date', toApiDate(releaseDate)),
    MapEntry('audience', audience),
    if (_changelog != null) MapEntry('changelog', _changelog!),
    if (_url != null) MapEntry('download_url', _url!),
    if (audience == ReleaseAudience.specific)
      for (final id in customerIds) MapEntry('customer_ids[]', '$id'),
    MapEntry('is_published', isPublished ? '1' : '0'),
  ];
}
