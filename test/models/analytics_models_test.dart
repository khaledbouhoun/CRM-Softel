import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/features/analytics/data/models/analytics_models.dart';

void main() {
  test('parses the analytics payload tolerantly', () {
    final data = AnalyticsData.fromJson({
      'range': 'quarter',
      'sales': {
        'funnel': [
          {'stage': 'New', 'count': 10, 'rate': 100},
          {'stage': 'Won', 'count': '4', 'rate': 40.0},
        ],
        'loss_reasons': [
          {'reason': null, 'count': 2, 'percentage': 100},
        ],
        'sources': [
          {'source': 'facebook', 'count': 3},
        ],
        'by_city': [
          {'city': 'Alger', 'count': 5},
        ],
        'avg_sales_cycle_days': '14.5',
      },
      'revenue_maintenance': {
        'total_customers': 8,
        'active_maintenance_count': 6,
        'expired_maintenance_count': 2,
        'retention_rate': 75,
        'expiring_next_60_days': 3,
        'products_distribution': [
          {'name': 'GestCom', 'count': 4},
        ],
        'avg_pcs_per_customer': null,
      },
      'support': {
        'total_tickets': 10,
        'resolved_tickets': 9,
        'resolution_rate': 90.0,
        'avg_resolution_hours': 3.2,
        'by_type': [
          {'code': 'bug', 'type': 'Bug', 'count': 4},
        ],
        'demo_conversion': [
          {'status': 'converted', 'count': 1, 'rate': 25.0},
          {'status': 'not_converted', 'count': 3, 'rate': 75.0},
        ],
      },
      'team': {
        'leaderboard': [
          {'employee': 'Karim', 'activities': 5, 'interventions': 2, 'deals_won': 1},
        ],
      },
    });

    expect(data.range, 'quarter');
    expect(data.sales.funnel[1].count, 4);
    expect(data.sales.lossReasons.single.label, isNull);
    expect(data.sales.avgSalesCycleDays, 14.5);
    expect(data.revenue.retentionRate, 75.0);
    expect(data.revenue.avgPcsPerCustomer, isNull);
    expect(data.support.demoTotal, 4);
    expect(data.support.demoConversionRate, 25.0);
    expect(data.team.leaderboard.single.dealsWon, 1);
  });

  test('an empty payload yields empty sections', () {
    final data = AnalyticsData.fromJson({});
    expect(data.sales.funnel, isEmpty);
    expect(data.revenue.totalCustomers, 0);
    expect(data.support.demoConversionRate, 0);
    expect(data.team.leaderboard, isEmpty);
  });
}
