import '../../../../core/utils/json_utils.dart';
import '../../../settings/data/models/sales_stage.dart';

/// Compact prospect reference embedded in activities and follow-ups
/// (API `ProspectSummary`).
class ProspectRef {
  const ProspectRef({
    required this.id,
    required this.companyName,
    this.contactName,
    this.phone,
    this.stage,
    this.isDeleted = false,
  });

  final int id;
  final String companyName;
  final String? contactName;
  final String? phone;

  /// Current stage when the API embedded it (search results, activities).
  final SalesStage? stage;

  /// The prospect was deleted; its history entries remain.
  final bool isDeleted;

  static ProspectRef? fromJsonOrNull(Object? value) {
    final json = asMapOrNull(value);
    return json == null ? null : ProspectRef.fromJson(json);
  }

  factory ProspectRef.fromJson(JsonMap json) => ProspectRef(
    stage: asMapOrNull(json['sales_stage']) == null
        ? null
        : SalesStage.fromJson(asMapOrNull(json['sales_stage'])!),
    id: asInt(json['id']),
    companyName: asString(json['name']),
    contactName: asStringOrNull(json['contact_person']),
    phone: asStringOrNull(json['phone']),
    isDeleted: asBool(json['is_deleted']),
  );

  JsonMap toJson() => {
    'id': id,
    'name': companyName,
    'contact_person': contactName,
    'phone': phone,
    'sales_stage_id': stage?.id,
    'sales_stage': stage?.toJson(),
    'is_deleted': isDeleted,
  };

  /// "Company — Contact" when a contact is known.
  String get displayName => contactName == null || contactName!.isEmpty
      ? companyName
      : '$companyName — $contactName';

  @override
  bool operator ==(Object other) => other is ProspectRef && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
