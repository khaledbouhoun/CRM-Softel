import 'dart:ui' show Color;

import '../../../../core/utils/json_utils.dart';
import '../../../../app/l10n/l10n.dart';

/// Backend-defined nature of a stage. Business rules (loss reason required,
/// won/lost statistics) depend on this type, never on the stage name.
enum StageType {
  open('open'),
  won('won'),
  lost('lost');

  const StageType(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    open => tr.stageTypeOpen,
    won => tr.stageTypeWon,
    lost => tr.stageTypeLost,
  };

  static StageType fromApi(Object? value) {
    final text = value?.toString().trim().toLowerCase();
    return StageType.values.firstWhere(
      (t) => t.apiValue == text,
      orElse: () => StageType.open,
    );
  }

  bool get isTerminal => this != StageType.open;
}

class SalesStage {
  const SalesStage({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.type,
    required this.position,
    required this.isActive,
    this.prospectsCount,
    this.isUsed = false,
  });

  static const defaultColorHex = '#64748B';

  final int id;
  final String name;
  final String colorHex;

  /// API `stage_type`.
  final StageType type;

  /// API `sort_order`.
  final int position;
  final bool isActive;

  /// Number of prospects currently in this stage, when provided.
  final int? prospectsCount;

  /// True when prospects reference this stage (cannot be deleted, type
  /// locked). The API does not report history-only references; it refuses
  /// such deletions itself (409) with an explanatory message.
  final bool isUsed;

  bool get isLost => type == StageType.lost;
  bool get isWon => type == StageType.won;
  bool get isOpen => type == StageType.open;

  Color get color => Color(parseHexColor(colorHex) ?? 0xFF64748B);

  factory SalesStage.fromJson(JsonMap json) => SalesStage(
    id: asInt(json['id']),
    name: asString(json['name']),
    colorHex: asStringOrNull(json['color']) ?? defaultColorHex,
    type: StageType.fromApi(json['stage_type']),
    position: asInt(json['sort_order']),
    isActive: asBool(json['is_active'], fallback: true),
    prospectsCount: asIntOrNull(json['prospects_count']),
    // Without a count (stage embedded in another resource), assume used so
    // deletion stays blocked.
    isUsed: (asIntOrNull(json['prospects_count']) ?? 1) > 0,
  );

  /// Same shape as the API resource (used by tests and fixtures).
  JsonMap toJson() => {
    'id': id,
    'name': name,
    'color': colorHex,
    'stage_type': type.apiValue,
    'sort_order': position,
    'is_active': isActive,
    if (prospectsCount != null) 'prospects_count': prospectsCount,
  };

  SalesStage copyWith({
    String? name,
    String? colorHex,
    StageType? type,
    int? position,
    bool? isActive,
    int? prospectsCount,
  }) => SalesStage(
    id: id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    type: type ?? this.type,
    position: position ?? this.position,
    isActive: isActive ?? this.isActive,
    prospectsCount: prospectsCount ?? this.prospectsCount,
    isUsed: isUsed,
  );

  @override
  bool operator ==(Object other) => other is SalesStage && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SalesStage($id, $name, ${type.apiValue})';
}

/// Body of POST/PUT `/sales-stages`.
class SalesStagePayload {
  const SalesStagePayload({
    required this.name,
    required this.colorHex,
    required this.type,
    required this.isActive,
  });

  final String name;
  final String colorHex;
  final StageType type;
  final bool isActive;

  JsonMap toJson() => {
    'name': name.trim(),
    'color': colorHex.toUpperCase(),
    'stage_type': type.apiValue,
    'is_active': isActive,
  };
}
