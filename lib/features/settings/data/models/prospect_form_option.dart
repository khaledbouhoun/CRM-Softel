import '../../../../core/utils/json_utils.dart';

/// A configurable option for prospect form dropdowns (source, previous software,
/// business activity, profession). Managed through CRM settings.
class ProspectFormOption {
  const ProspectFormOption({
    required this.id,
    required this.type,
    required this.name,
    required this.requiresDetails,
    required this.sortOrder,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  static const typeSource = 'source';
  static const typePreviousSoftware = 'previous_software';
  static const typeBusinessActivity = 'business_activity';
  static const typeProfession = 'profession';

  static const allTypes = [
    typeSource,
    typePreviousSoftware,
    typeBusinessActivity,
    typeProfession,
  ];

  final int id;

  /// One of [allTypes].
  final String type;

  /// Option display name / label.
  final String name;

  /// When true, choosing this option in the prospect form requires extra details.
  final bool requiresDetails;

  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProspectFormOption.fromJson(JsonMap json) => ProspectFormOption(
    id: asInt(json['id']),
    type: asString(json['type']),
    name: asString(json['name']),
    requiresDetails: asBool(json['requires_details']),
    sortOrder: asInt(json['sort_order']),
    isActive: asBool(json['is_active'], fallback: true),
    createdAt: asDateTimeOrNull(json['created_at']),
    updatedAt: asDateTimeOrNull(json['updated_at']),
  );

  JsonMap toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'requires_details': requiresDetails,
    'sort_order': sortOrder,
    'is_active': isActive,
    if (createdAt != null) 'created_at': toApiDateTime(createdAt!),
    if (updatedAt != null) 'updated_at': toApiDateTime(updatedAt!),
  };

  ProspectFormOption copyWith({
    String? type,
    String? name,
    bool? requiresDetails,
    int? sortOrder,
    bool? isActive,
  }) => ProspectFormOption(
    id: id,
    type: type ?? this.type,
    name: name ?? this.name,
    requiresDetails: requiresDetails ?? this.requiresDetails,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is ProspectFormOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Body of POST/PUT `/prospect-form-options`.
class ProspectFormOptionPayload {
  const ProspectFormOptionPayload({
    required this.type,
    required this.name,
    this.requiresDetails = false,
    this.isActive = true,
    this.sortOrder,
  });

  final String type;
  final String name;
  final bool requiresDetails;
  final bool isActive;
  final int? sortOrder;

  JsonMap toJson() => {
    'type': type,
    'name': name.trim(),
    'requires_details': requiresDetails,
    'is_active': isActive,
    if (sortOrder != null) 'sort_order': sortOrder,
  };
}
