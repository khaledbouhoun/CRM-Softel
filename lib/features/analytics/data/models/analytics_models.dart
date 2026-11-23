import '../../../../core/utils/json_utils.dart';

double? _asDoubleOrNull(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

double _asDouble(Object? value) => _asDoubleOrNull(value) ?? 0;

List<T> _list<T>(Object? value, T Function(JsonMap) fromJson) => value is List
    ? [for (final e in value) if (e is Map) fromJson(Map<String, dynamic>.from(e))]
    : <T>[];

/// A labelled count. A null [label] means "no value recorded" (translated by the UI).
class CountItem {
  const CountItem({required this.label, required this.count, this.percentage});

  final String? label;
  final int count;
  final double? percentage;

  factory CountItem.fromJson(JsonMap json, String labelKey) => CountItem(
    label: asStringOrNull(json[labelKey]),
    count: asInt(json['count']),
    percentage: _asDoubleOrNull(json['percentage']),
  );
}

class FunnelStep {
  const FunnelStep({
    required this.stage,
    required this.count,
    required this.rate,
  });

  final String stage;
  final int count;
  final double rate;

  factory FunnelStep.fromJson(JsonMap json) => FunnelStep(
    stage: asString(json['stage']),
    count: asInt(json['count']),
    rate: _asDouble(json['rate']),
  );
}

class SalesAnalytics {
  const SalesAnalytics({
    this.funnel = const [],
    this.lossReasons = const [],
    this.sources = const [],
    this.byCity = const [],
    this.avgSalesCycleDays,
  });

  final List<FunnelStep> funnel;
  final List<CountItem> lossReasons;
  final List<CountItem> sources;
  final List<CountItem> byCity;
  final double? avgSalesCycleDays;

  factory SalesAnalytics.fromJson(JsonMap json) => SalesAnalytics(
    funnel: _list(json['funnel'], FunnelStep.fromJson),
    lossReasons: _list(json['loss_reasons'], (j) => CountItem.fromJson(j, 'reason')),
    sources: _list(json['sources'], (j) => CountItem.fromJson(j, 'source')),
    byCity: _list(json['by_city'], (j) => CountItem.fromJson(j, 'city')),
    avgSalesCycleDays: _asDoubleOrNull(json['avg_sales_cycle_days']),
  );
}

class RevenueAnalytics {
  const RevenueAnalytics({
    this.totalCustomers = 0,
    this.activeMaintenance = 0,
    this.expiredMaintenance = 0,
    this.retentionRate,
    this.expiringNext60Days = 0,
    this.products = const [],
    this.avgPcsPerCustomer,
  });

  final int totalCustomers;
  final int activeMaintenance;
  final int expiredMaintenance;
  final double? retentionRate;
  final int expiringNext60Days;
  final List<CountItem> products;
  final double? avgPcsPerCustomer;

  factory RevenueAnalytics.fromJson(JsonMap json) => RevenueAnalytics(
    totalCustomers: asInt(json['total_customers']),
    activeMaintenance: asInt(json['active_maintenance_count']),
    expiredMaintenance: asInt(json['expired_maintenance_count']),
    retentionRate: _asDoubleOrNull(json['retention_rate']),
    expiringNext60Days: asInt(json['expiring_next_60_days']),
    products: _list(json['products_distribution'], (j) => CountItem.fromJson(j, 'name')),
    avgPcsPerCustomer: _asDoubleOrNull(json['avg_pcs_per_customer']),
  );
}

class DemoConversionItem {
  const DemoConversionItem({
    required this.status,
    required this.count,
    required this.rate,
  });

  /// `converted` | `not_converted`.
  final String status;
  final int count;
  final double rate;

  bool get isConverted => status == 'converted';

  factory DemoConversionItem.fromJson(JsonMap json) => DemoConversionItem(
    status: asString(json['status']),
    count: asInt(json['count']),
    rate: _asDouble(json['rate']),
  );
}

class SupportAnalytics {
  const SupportAnalytics({
    this.totalTickets = 0,
    this.resolvedTickets = 0,
    this.resolutionRate,
    this.avgResolutionHours,
    this.byType = const [],
    this.demoConversion = const [],
  });

  final int totalTickets;
  final int resolvedTickets;
  final double? resolutionRate;
  final double? avgResolutionHours;
  final List<CountItem> byType;
  final List<DemoConversionItem> demoConversion;

  int get demoTotal => demoConversion.fold(0, (s, d) => s + d.count);

  /// Percentage of trials that became customers (0 when there are no trials).
  double get demoConversionRate => demoConversion
      .where((d) => d.isConverted)
      .fold(0.0, (s, d) => s + d.rate);

  factory SupportAnalytics.fromJson(JsonMap json) => SupportAnalytics(
    totalTickets: asInt(json['total_tickets']),
    resolvedTickets: asInt(json['resolved_tickets']),
    resolutionRate: _asDoubleOrNull(json['resolution_rate']),
    avgResolutionHours: _asDoubleOrNull(json['avg_resolution_hours']),
    byType: _list(json['by_type'], (j) => CountItem.fromJson(j, 'type')),
    demoConversion: _list(json['demo_conversion'], DemoConversionItem.fromJson),
  );
}

class TeamMember {
  const TeamMember({
    required this.employee,
    required this.activities,
    required this.interventions,
    required this.dealsWon,
  });

  final String employee;
  final int activities;
  final int interventions;
  final int dealsWon;

  factory TeamMember.fromJson(JsonMap json) => TeamMember(
    employee: asString(json['employee']),
    activities: asInt(json['activities']),
    interventions: asInt(json['interventions']),
    dealsWon: asInt(json['deals_won']),
  );
}

class TeamAnalytics {
  const TeamAnalytics({this.leaderboard = const []});

  final List<TeamMember> leaderboard;

  factory TeamAnalytics.fromJson(JsonMap json) => TeamAnalytics(
    leaderboard: _list(json['leaderboard'], TeamMember.fromJson),
  );
}

class AnalyticsData {
  const AnalyticsData({
    this.range = 'month',
    this.sales = const SalesAnalytics(),
    this.revenue = const RevenueAnalytics(),
    this.support = const SupportAnalytics(),
    this.team = const TeamAnalytics(),
    this.generatedAt,
  });

  final String range;
  final SalesAnalytics sales;
  final RevenueAnalytics revenue;
  final SupportAnalytics support;
  final TeamAnalytics team;
  final DateTime? generatedAt;

  factory AnalyticsData.fromJson(JsonMap json) => AnalyticsData(
    range: asString(json['range'], fallback: 'month'),
    sales: SalesAnalytics.fromJson(asMapOrNull(json['sales']) ?? const {}),
    revenue: RevenueAnalytics.fromJson(
      asMapOrNull(json['revenue_maintenance']) ?? const {},
    ),
    support: SupportAnalytics.fromJson(asMapOrNull(json['support']) ?? const {}),
    team: TeamAnalytics.fromJson(asMapOrNull(json['team']) ?? const {}),
    generatedAt: asDateTimeOrNull(json['generated_at']),
  );
}
