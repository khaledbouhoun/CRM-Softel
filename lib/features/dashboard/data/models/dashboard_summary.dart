import '../../../../core/utils/json_utils.dart';
import '../../../activities/data/models/activity.dart';
import '../../../settings/data/models/sales_stage.dart';

class LossReasonCount {
  const LossReasonCount({
    required this.id,
    required this.label,
    required this.count,
  });

  final int id;
  final String label;
  final int count;

  factory LossReasonCount.fromJson(JsonMap json) => LossReasonCount(
    id: asInt(json['loss_reason_id']),
    label: asString(json['name']),
    count: asInt(json['count']),
  );
}

/// Payload of GET `/dashboard`. All figures are computed by the server.
class DashboardSummary {
  const DashboardSummary({
    required this.totalProspects,
    required this.openProspects,
    required this.wonProspects,
    required this.lostProspects,
    required this.followUpsToday,
    required this.followUpsOverdue,
    required this.followUpsUpcoming,
    required this.stages,
    required this.recentActivities,
    this.lostByReason,
    this.upcomingWindowDays,
  });

  final int totalProspects;
  final int openProspects;
  final int wonProspects;
  final int lostProspects;
  final int followUpsToday;
  final int followUpsOverdue;

  /// Pending follow-ups in the next [upcomingWindowDays] days after today.
  final int followUpsUpcoming;
  final int? upcomingWindowDays;

  /// Stages with their `prospects_count`, ordered by position.
  final List<SalesStage> stages;
  final List<Activity> recentActivities;

  /// Current lost prospects per loss reason.
  final List<LossReasonCount>? lostByReason;

  /// Won / (won + lost); null when nothing is closed yet.
  double? get winRate {
    final closed = wonProspects + lostProspects;
    return closed == 0 ? null : wonProspects / closed;
  }

  /// One `prospects_by_stage` row, read as a stage with its count.
  static SalesStage _stageFromRow(JsonMap row) => SalesStage.fromJson({
    ...row,
    'id': row['sales_stage_id'],
    'prospects_count': row['count'],
  });

  factory DashboardSummary.fromJson(JsonMap json) {
    final prospects = asMapOrNull(json['prospects']) ?? const {};
    final followUps = asMapOrNull(json['follow_ups']) ?? const {};
    final stages = asList(json['prospects_by_stage'], _stageFromRow)
      ..sort((a, b) => a.position.compareTo(b.position));
    return DashboardSummary(
      totalProspects: asInt(prospects['total']),
      openProspects: asInt(prospects['open']),
      wonProspects: asInt(prospects['won']),
      lostProspects: asInt(prospects['lost']),
      followUpsToday: asInt(followUps['today']),
      followUpsOverdue: asInt(followUps['overdue']),
      followUpsUpcoming: asInt(followUps['upcoming']),
      upcomingWindowDays: asIntOrNull(followUps['upcoming_window_days']),
      stages: stages,
      recentActivities: asList(json['recent_activities'], Activity.fromJson),
      lostByReason: json['lost_by_reason'] is List
          ? asList(json['lost_by_reason'], LossReasonCount.fromJson)
          : null,
    );
  }
}
