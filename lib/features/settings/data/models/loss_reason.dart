import '../../../../core/utils/json_utils.dart';

/// A reason why a prospect was lost. The list is provided by the backend.
class LossReason {
  const LossReason({
    required this.id,
    required this.label,
    required this.requiresDetails,
    required this.position,
    required this.isActive,
  });

  final int id;

  /// API `name`.
  final String label;

  /// API `requires_note`: a free-text note is mandatory with this reason.
  final bool requiresDetails;

  /// API `sort_order`.
  final int position;
  final bool isActive;

  factory LossReason.fromJson(JsonMap json) => LossReason(
    id: asInt(json['id']),
    label: asString(json['name']),
    requiresDetails: asBool(json['requires_note']),
    position: asInt(json['sort_order']),
    isActive: asBool(json['is_active'], fallback: true),
  );

  /// Same shape as the API resource (used by tests and fixtures).
  JsonMap toJson() => {
    'id': id,
    'name': label,
    'requires_note': requiresDetails,
    'sort_order': position,
    'is_active': isActive,
  };

  LossReason copyWith({bool? isActive, int? position}) => LossReason(
    id: id,
    label: label,
    requiresDetails: requiresDetails,
    position: position ?? this.position,
    isActive: isActive ?? this.isActive,
  );

  @override
  bool operator ==(Object other) => other is LossReason && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Body of POST/PUT `/loss-reasons`.
class LossReasonPayload {
  const LossReasonPayload({
    required this.label,
    required this.requiresDetails,
    required this.isActive,
  });

  final String label;
  final bool requiresDetails;
  final bool isActive;

  JsonMap toJson() => {
    'name': label.trim(),
    'requires_note': requiresDetails,
    'is_active': isActive,
  };
}
