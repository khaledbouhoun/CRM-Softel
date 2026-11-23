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

/// Customers (converted prospects) and their maintenance plans.
class CustomerStats {
  const CustomerStats({
    this.total = 0,
    this.activeMaintenance = 0,
    this.expiringSoon = 0,
    this.expired = 0,
  });

  final int total;
  final int activeMaintenance;
  final int expiringSoon;
  final int expired;

  factory CustomerStats.fromJson(JsonMap json) => CustomerStats(
    total: asInt(json['total']),
    activeMaintenance: asInt(json['active_maintenance']),
    expiringSoon: asInt(json['expiring_soon']),
    expired: asInt(json['expired']),
  );
}

/// Open support tickets (interventions) and pending customer-portal requests.
class SupportStats {
  const SupportStats({
    this.openTickets = 0,
    this.urgentTickets = 0,
    this.pendingRequests = 0,
  });

  final int openTickets;
  final int urgentTickets;
  final int pendingRequests;

  factory SupportStats.fromJson(JsonMap json) => SupportStats(
    openTickets: asInt(json['open_tickets']),
    urgentTickets: asInt(json['urgent_tickets']),
    pendingRequests: asInt(json['pending_requests']),
  );
}

class OperationsStats {
  const OperationsStats({this.appointmentsToday = 0, this.activeTrials = 0});

  final int appointmentsToday;
  final int activeTrials;

  factory OperationsStats.fromJson(JsonMap json) => OperationsStats(
    appointmentsToday: asInt(json['appointments_today']),
    activeTrials: asInt(json['active_trials']),
  );
}

/// Prospects created and deals closed since the 1st of the month.
class MonthStats {
  const MonthStats({this.won = 0, this.lost = 0, this.newProspects = 0});

  final int won;
  final int lost;
  final int newProspects;

  /// Won / (won + lost) this month; null when nothing closed yet.
  double? get conversion => won + lost == 0 ? null : won / (won + lost);

  factory MonthStats.fromJson(JsonMap json) => MonthStats(
    won: asInt(json['won']),
    lost: asInt(json['lost']),
    newProspects: asInt(json['new_prospects']),
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
    this.customers = const CustomerStats(),
    this.support = const SupportStats(),
    this.operations = const OperationsStats(),
    this.thisMonth = const MonthStats(),
  });

  final int totalProspects;
  final int openProspects;
  final int wonProspects;
  final int lostProspects;
  final int followUpsToday;
  final int followUpsOverdue;

  final CustomerStats customers;
  final SupportStats support;
  final OperationsStats operations;
  final MonthStats thisMonth;

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
      customers: CustomerStats.fromJson(
        asMapOrNull(json['customers']) ?? const {},
      ),
      support: SupportStats.fromJson(asMapOrNull(json['support']) ?? const {}),
      operations: OperationsStats.fromJson(
        asMapOrNull(json['operations']) ?? const {},
      ),
      thisMonth: MonthStats.fromJson(
        asMapOrNull(json['this_month']) ?? const {},
      ),
    );
  }
}
