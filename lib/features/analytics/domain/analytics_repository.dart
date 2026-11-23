import '../data/models/analytics_models.dart';

/// [range] is one of `month`, `quarter`, `year`, `all`.
abstract interface class AnalyticsRepository {
  Future<AnalyticsData> getAnalytics({String range = 'month'});
}
