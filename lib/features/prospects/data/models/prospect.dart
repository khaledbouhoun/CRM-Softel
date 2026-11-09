import '../../../../core/utils/json_utils.dart';
import '../../../products/data/models/product.dart';
import '../../../settings/data/models/loss_reason.dart';
import '../../../settings/data/models/sales_stage.dart';
import 'prospect_ref.dart';

/// Overdue as the server defines it: a pending follow-up scheduled before
/// today (whole days, not hours).
bool isBeforeToday(DateTime? value, [DateTime? now]) {
  if (value == null) return false;
  final today = now ?? DateTime.now();
  return value.isBefore(DateTime(today.year, today.month, today.day));
}

class Prospect {
  const Prospect({
    required this.id,
    required this.companyName,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.businessActivity,
    this.source,
    this.sourceOther,
    this.previousSoftware,
    this.notes,
    this.stage,
    this.products = const [],
    this.lossReason,
    this.lossDetails,
    this.lastActivityAt,
    this.nextFollowUpAt,
    this.activitiesCount,
    this.pendingFollowUpsCount,
    this.createdAt,
    this.updatedAt,
  });

  final int id;

  /// API `name` (company or customer).
  final String companyName;

  /// API `contact_person`.
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;

  /// Stable code (e.g. `wholesale`) or free text. Null on older prospects.
  final String? businessActivity;

  /// Stable code (e.g. `facebook`); [sourceOther] holds the detail for `other`.
  final String? source;
  final String? sourceOther;

  /// Stable code (e.g. `sage`) or free text.
  final String? previousSoftware;
  final String? notes;
  final SalesStage? stage;
  final List<Product> products;

  /// Set only while the prospect is in a lost stage.
  final LossReason? lossReason;

  /// API `loss_note`.
  final String? lossDetails;
  final DateTime? lastActivityAt;

  /// Earliest pending follow-up (may be overdue).
  final DateTime? nextFollowUpAt;
  final int? activitiesCount;
  final int? pendingFollowUpsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Lost status is derived from the stage type, never from its name.
  bool get isLost => stage?.isLost ?? false;
  bool get isWon => stage?.isWon ?? false;

  bool isNextFollowUpOverdue([DateTime? now]) =>
      isBeforeToday(nextFollowUpAt, now);

  ProspectRef toRef() => ProspectRef(
    id: id,
    companyName: companyName,
    contactName: contactName,
    phone: phone,
    stage: stage,
  );

  factory Prospect.fromJson(JsonMap json) {
    final stageJson = asMapOrNull(json['sales_stage']);
    final reasonJson = asMapOrNull(json['loss_reason']);
    return Prospect(
      id: asInt(json['id']),
      companyName: asString(json['name']),
      contactName: asStringOrNull(json['contact_person']),
      phone: asStringOrNull(json['phone']),
      email: asStringOrNull(json['email']),
      address: asStringOrNull(json['address']),
      city: asStringOrNull(json['city']),
      businessActivity: asStringOrNull(json['business_activity']),
      source: asStringOrNull(json['source']),
      sourceOther: asStringOrNull(json['source_other']),
      previousSoftware: asStringOrNull(json['previous_software']),
      notes: asStringOrNull(json['notes']),
      stage: stageJson == null ? null : SalesStage.fromJson(stageJson),
      products: asList(json['products'], Product.fromJson),
      lossReason: reasonJson == null ? null : LossReason.fromJson(reasonJson),
      lossDetails: asStringOrNull(json['loss_note']),
      lastActivityAt: asDateTimeOrNull(json['last_activity_at']),
      nextFollowUpAt: asDateTimeOrNull(json['next_follow_up_at']),
      activitiesCount: asIntOrNull(json['activities_count']),
      pendingFollowUpsCount: asIntOrNull(json['pending_follow_ups_count']),
      createdAt: asDateTimeOrNull(json['created_at']),
      updatedAt: asDateTimeOrNull(json['updated_at']),
    );
  }

  /// Same shape as the API resource (used by tests and fixtures).
  JsonMap toJson() => {
    'id': id,
    'name': companyName,
    'contact_person': contactName,
    'phone': phone,
    'email': email,
    'address': address,
    'city': city,
    'business_activity': businessActivity,
    'source': source,
    'source_other': sourceOther,
    'previous_software': previousSoftware,
    'notes': notes,
    'sales_stage_id': stage?.id,
    'sales_stage': stage?.toJson(),
    'loss_reason_id': lossReason?.id,
    'loss_reason': lossReason?.toJson(),
    'loss_note': lossDetails,
    'products': products.map((p) => p.toJson()).toList(),
    'activities_count': activitiesCount,
    'pending_follow_ups_count': pendingFollowUpsCount,
    'last_activity_at': lastActivityAt == null
        ? null
        : toApiDateTime(lastActivityAt!),
    'next_follow_up_at': nextFollowUpAt == null
        ? null
        : toApiDateTime(nextFollowUpAt!),
    'created_at': createdAt == null ? null : toApiDateTime(createdAt!),
    'updated_at': updatedAt == null ? null : toApiDateTime(updatedAt!),
  };

  @override
  bool operator ==(Object other) => other is Prospect && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
