import '../../../../core/utils/json_utils.dart';
import '../../../settings/data/models/loss_reason.dart';
import '../../../settings/data/models/sales_stage.dart';

/// One recorded stage change of a prospect.
class StageHistoryEntry {
  const StageHistoryEntry({
    required this.id,
    required this.toStage,
    required this.changedAt,
    this.fromStage,
    this.lossReason,
    this.lossDetails,
  });

  final int id;

  /// Null for the initial stage assignment.
  final SalesStage? fromStage;
  final SalesStage? toStage;
  final LossReason? lossReason;

  /// API `loss_note`.
  final String? lossDetails;
  final DateTime? changedAt;

  factory StageHistoryEntry.fromJson(JsonMap json) {
    final from = asMapOrNull(json['from_stage']);
    final to = asMapOrNull(json['to_stage']);
    final reason = asMapOrNull(json['loss_reason']);
    return StageHistoryEntry(
      id: asInt(json['id']),
      fromStage: from == null ? null : SalesStage.fromJson(from),
      toStage: to == null ? null : SalesStage.fromJson(to),
      lossReason: reason == null ? null : LossReason.fromJson(reason),
      lossDetails: asStringOrNull(json['loss_note']),
      changedAt: asDateTimeOrNull(json['changed_at'] ?? json['created_at']),
    );
  }
}
