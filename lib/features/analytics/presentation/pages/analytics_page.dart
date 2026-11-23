import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/huge_data.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/models/analytics_models.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/analytics_charts.dart';

class AnalyticsPage extends GetView<AnalyticsController> {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.analytics,
    child: DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => PageHeader(
              title: tr.navAnalytics,
              subtitle: controller.lastUpdatedAt.value == null
                  ? tr.analyticsSubtitle
                  : tr.dashUpdatedAt(Formatters.time(controller.lastUpdatedAt.value)),
              actions: [
                _RangeSwitcher(controller),
                OutlinedButton.icon(
                  onPressed: controller.state.isLoading ? null : controller.load,
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, size: 18),
                  label: Text(tr.actionRefresh),
                ),
              ],
            ),
          ),
          Obx(() => RefreshingBar(visible: controller.state.isLoading && controller.data.value != null)),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: tr.analyticsTabSales),
                  Tab(text: tr.analyticsTabRevenue),
                  Tab(text: tr.analyticsTabSupport),
                  Tab(text: tr.analyticsTabTeam),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final data = controller.data.value;
              return LoadStateView(
                state: controller.state,
                isEmpty: data == null,
                onRetry: controller.load,
                skeleton: SkeletonKind.cards,
                builder: (_) => TabBarView(
                  children: [
                    _SalesTab(data!.sales),
                    _RevenueTab(data.revenue),
                    _SupportTab(data.support),
                    _TeamTab(data.team),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    ),
  );
}

class _RangeSwitcher extends StatelessWidget {
  const _RangeSwitcher(this.c);

  final AnalyticsController c;

  String _label(String range) => switch (range) {
    AnalyticsRange.quarter => tr.analyticsRangeQuarter,
    AnalyticsRange.year => tr.analyticsRangeYear,
    AnalyticsRange.all => tr.analyticsRangeAll,
    _ => tr.analyticsRangeMonth,
  };

  @override
  Widget build(BuildContext context) => Obx(
    () => SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [for (final r in AnalyticsRange.values) ButtonSegment(value: r, label: Text(_label(r)))],
      selected: {c.range.value},
      onSelectionChanged: (s) => c.setRange(s.first),
    ),
  );
}

// ---------------------------------------------------------------- layout

const _tabPadding = EdgeInsetsDirectional.fromSTEB(28, 8, 28, 28);

/// Lays [children] out in a responsive grid of cards (2 columns when wide).
class _Grid extends StatelessWidget {
  const _Grid(this.children) : minWidth = 520;

  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final perRow = c.maxWidth >= minWidth * 2 + 16 ? 2 : 1;
      final width = (c.maxWidth - (perRow - 1) * 16) / perRow;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (var i = 0; i < children.length; i++)
            SizedBox(
              width: width,
              child: FadeSlideIn.staggered(
                index: i,
                step: const Duration(milliseconds: 70),
                start: const Duration(milliseconds: 180),
                child: children[i],
              ),
            ),
        ],
      );
    },
  );
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.unit,
    this.numeric,
    this.decimals = 0,
    this.numericSuffix = '',
  });

  final String label;

  /// Text shown when [numeric] is null (e.g. "—").
  final String value;

  /// When set, the figure counts up to this number instead of showing [value].
  final num? numeric;
  final int decimals;
  final String numericSuffix;
  final String? unit;
  final HugeData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: HugeIcon(icon: icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                if (numeric != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: AnimatedCount(
                          targetValue: numeric!,
                          fractionDigits: decimals,
                          suffix: numericSuffix,
                          style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (unit != null)
                        Text(
                          ' $unit',
                          style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                    ],
                  )
                else
                  Text.rich(
                    TextSpan(
                      text: value,
                      style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      children: [
                        if (unit != null)
                          TextSpan(
                            text: ' $unit',
                            style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _KpiRow extends StatelessWidget {
  const _KpiRow(this.items);

  final List<_Kpi> items;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final perRow = c.maxWidth > 900 ? items.length.clamp(1, 4) : 2;
      final width = (c.maxWidth - (perRow - 1) * 14) / perRow;
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (var i = 0; i < items.length; i++)
            SizedBox(
              width: width,
              child: FadeSlideIn.staggered(index: i, step: const Duration(milliseconds: 60), child: items[i]),
            ),
        ],
      );
    },
  );
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Center(
      child: Text(tr.analyticsNoData, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
    ),
  );
}

String _num1(double? v) => v == null ? '—' : Formatters.number(double.parse(v.toStringAsFixed(1)));

String _pct(double? v) => v == null ? '—' : '${_num1(v)}%';

/// Donut + legend inside a card body; shows an empty hint when nothing to draw.
class _DonutWithLegend extends StatelessWidget {
  const _DonutWithLegend({required this.slices, this.centerValue, this.centerLabel});

  final List<SliceDatum> slices;
  final String? centerValue;
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    if (slices.every((s) => s.value <= 0)) return const _NoData();
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 16,
      children: [
        AnalyticsDonut(slices: slices, centerValue: centerValue, centerLabel: centerLabel),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 180, maxWidth: 300),
          child: ChartLegend(slices: slices),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- tabs

class _SalesTab extends StatelessWidget {
  const _SalesTab(this.s);

  final SalesAnalytics s;

  @override
  Widget build(BuildContext context) {
    final palette = analyticsPalette(context);
    String label(CountItem i, String fallback) => i.label ?? fallback;

    final maxCity = s.byCity.fold<int>(0, (m, c) => c.count > m ? c.count : m);

    return ListView(
      padding: _tabPadding,
      children: [
        _KpiRow([
          _Kpi(
            label: tr.analyticsAvgCycle,
            value: _num1(s.avgSalesCycleDays),
            numeric: s.avgSalesCycleDays,
            decimals: 1,
            unit: s.avgSalesCycleDays == null ? null : tr.analyticsUnitDays,
            icon: HugeIcons.strokeRoundedTime02,
            color: BrandColors.primary,
          ),
          _Kpi(
            label: tr.analyticsFunnelWon,
            value: Formatters.number(s.funnel.isEmpty ? 0 : s.funnel.last.count),
            numeric: s.funnel.isEmpty ? 0 : s.funnel.last.count,
            icon: HugeIcons.strokeRoundedUserAdd01,
            color: context.crm.success,
          ),
          _Kpi(
            label: tr.analyticsLossReasons,
            value: Formatters.number(s.lossReasons.fold<int>(0, (sum, r) => sum + r.count)),
            numeric: s.lossReasons.fold<int>(0, (sum, r) => sum + r.count),
            icon: HugeIcons.strokeRoundedUserGroup,
            color: context.crm.danger,
          ),
        ]),
        const SizedBox(height: 16),
        _Grid([
          SectionCard(
            title: tr.analyticsFunnel,
            icon: HugeIcons.strokeRoundedUserAdd01,
            child: s.funnel.isEmpty
                ? const _NoData()
                : AnalyticsBarChart(
                    data: [for (final f in s.funnel) BarDatum(label: f.stage, value: f.count, caption: _pct(f.rate))],
                  ),
          ),
          SectionCard(
            title: tr.analyticsLossReasons,
            icon: HugeIcons.strokeRoundedUserGroup,
            child: _DonutWithLegend(
              slices: [
                for (var i = 0; i < s.lossReasons.length; i++)
                  SliceDatum(
                    label: label(s.lossReasons[i], tr.analyticsNoReason),
                    value: s.lossReasons[i].count,
                    color: palette[(i + 4) % palette.length],
                  ),
              ],
            ),
          ),
          SectionCard(
            title: tr.analyticsSources,
            icon: HugeIcons.strokeRoundedNote01,
            child: s.sources.isEmpty
                ? const _NoData()
                : AnalyticsBarChart(
                    color: context.crm.info,
                    data: [for (final i in s.sources) BarDatum(label: label(i, tr.analyticsUnknown), value: i.count)],
                  ),
          ),
          SectionCard(
            title: tr.analyticsTopCities,
            icon: HugeIcons.strokeRoundedBuilding02,
            child: s.byCity.isEmpty
                ? const _NoData()
                : Column(
                    children: [
                      for (var i = 0; i < s.byCity.length; i++)
                        ShareBarRow(
                          label: label(s.byCity[i], tr.analyticsUnknown),
                          value: s.byCity[i].count,
                          max: maxCity,
                          color: palette[i % palette.length],
                        ),
                    ],
                  ),
          ),
        ]),
      ],
    );
  }
}

class _RevenueTab extends StatelessWidget {
  const _RevenueTab(this.r);

  final RevenueAnalytics r;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final hasPlans = r.activeMaintenance + r.expiredMaintenance > 0;
    return ListView(
      padding: _tabPadding,
      children: [
        _KpiRow([
          _Kpi(
            label: tr.analyticsTotalCustomers,
            value: Formatters.number(r.totalCustomers),
            numeric: r.totalCustomers,
            icon: HugeIcons.strokeRoundedBuilding02,
            color: BrandColors.primary,
          ),
          _Kpi(
            label: tr.analyticsActiveMaintenance,
            value: Formatters.number(r.activeMaintenance),
            numeric: r.activeMaintenance,
            icon: HugeIcons.strokeRoundedCreditCard,
            color: crm.success,
          ),
          _Kpi(
            label: tr.analyticsExpiredMaintenance,
            value: Formatters.number(r.expiredMaintenance),
            numeric: r.expiredMaintenance,
            icon: HugeIcons.strokeRoundedCreditCard,
            color: crm.danger,
          ),
          _Kpi(
            label: tr.analyticsAvgPcs,
            value: _num1(r.avgPcsPerCustomer),
            numeric: r.avgPcsPerCustomer,
            decimals: 1,
            icon: HugeIcons.strokeRoundedPackage,
            color: context.colors.tertiary,
          ),
        ]),
        const SizedBox(height: 16),
        _ExpiringCard(count: r.expiringNext60Days),
        const SizedBox(height: 16),
        _Grid([
          SectionCard(
            title: tr.analyticsRetention,
            icon: HugeIcons.strokeRoundedCreditCard,
            child: !hasPlans
                ? const _NoData()
                : _DonutWithLegend(
                    centerValue: _pct(r.retentionRate),
                    centerLabel: tr.analyticsRetentionShort,
                    slices: [
                      SliceDatum(label: tr.analyticsActiveMaintenance, value: r.activeMaintenance, color: crm.success),
                      SliceDatum(label: tr.analyticsExpiredMaintenance, value: r.expiredMaintenance, color: crm.danger),
                    ],
                  ),
          ),
          SectionCard(
            title: tr.analyticsProductPopularity,
            icon: HugeIcons.strokeRoundedPackage,
            child: r.products.isEmpty
                ? const _NoData()
                : AnalyticsBarChart(
                    data: [for (final p in r.products) BarDatum(label: p.label ?? tr.analyticsUnknown, value: p.count)],
                  ),
          ),
        ]),
      ],
    );
  }
}

class _ExpiringCard extends StatelessWidget {
  const _ExpiringCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final alert = count > 0;
    final color = alert ? crm.warning : crm.success;
    return Card(
      color: alert ? crm.warningContainer : crm.successContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, size: 30, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr.analyticsExpiringTitle, style: context.text.titleMedium?.copyWith(color: color)),
                  Text(
                    alert ? tr.analyticsExpiringCount(count) : tr.analyticsExpiringNone,
                    style: context.text.bodyMedium?.copyWith(color: context.colors.onSurface),
                  ),
                ],
              ),
            ),
            if (alert)
              FilledButton(onPressed: () => Get.offAllNamed(Routes.billing), child: Text(tr.analyticsExpiringAction)),
          ],
        ),
      ),
    );
  }
}

class _SupportTab extends StatelessWidget {
  const _SupportTab(this.s);

  final SupportAnalytics s;

  String _status(DemoConversionItem d) => d.isConverted ? tr.analyticsDemoConverted : tr.analyticsDemoNotConverted;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final palette = analyticsPalette(context);
    return ListView(
      padding: _tabPadding,
      children: [
        _KpiRow([
          _Kpi(
            label: tr.analyticsTotalTickets,
            value: Formatters.number(s.totalTickets),
            numeric: s.totalTickets,
            icon: HugeIcons.strokeRoundedHeadset,
            color: BrandColors.primary,
          ),
          _Kpi(
            label: tr.analyticsResolvedTickets,
            value: Formatters.number(s.resolvedTickets),
            numeric: s.resolvedTickets,
            icon: HugeIcons.strokeRoundedHeadset,
            color: crm.success,
          ),
          _Kpi(
            label: tr.analyticsResolutionRate,
            value: _pct(s.resolutionRate),
            numeric: s.resolutionRate,
            decimals: 1,
            numericSuffix: '%',
            icon: HugeIcons.strokeRoundedHeadset,
            color: crm.info,
          ),
          _Kpi(
            label: tr.analyticsResolutionSpeed,
            value: _num1(s.avgResolutionHours),
            numeric: s.avgResolutionHours,
            decimals: 1,
            unit: s.avgResolutionHours == null ? null : tr.analyticsUnitHours,
            icon: HugeIcons.strokeRoundedTime02,
            color: crm.warning,
          ),
        ]),
        const SizedBox(height: 16),
        _Grid([
          SectionCard(
            title: tr.analyticsTicketsByCategory,
            icon: HugeIcons.strokeRoundedHeadset,
            child: _DonutWithLegend(
              slices: [
                for (var i = 0; i < s.byType.length; i++)
                  SliceDatum(
                    label: s.byType[i].label ?? tr.analyticsUnknown,
                    value: s.byType[i].count,
                    color: palette[i % palette.length],
                  ),
              ],
            ),
          ),
          SectionCard(
            title: tr.analyticsDemoConversion,
            icon: HugeIcons.strokeRoundedUserAdd01,
            child: s.demoTotal == 0
                ? const _NoData()
                : _DonutWithLegend(
                    centerValue: _pct(s.demoConversionRate),
                    centerLabel: tr.analyticsDemoConverted,
                    slices: [
                      for (final d in s.demoConversion)
                        SliceDatum(label: _status(d), value: d.count, color: d.isConverted ? crm.success : crm.warning),
                    ],
                  ),
          ),
        ]),
      ],
    );
  }
}

class _TeamTab extends StatelessWidget {
  const _TeamTab(this.t);

  final TeamAnalytics t;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final members = t.leaderboard;
    final maxY = members.fold<int>(
      0,
      (m, e) => [m, e.activities, e.interventions, e.dealsWon].reduce((a, b) => a > b ? a : b),
    );
    return ListView(
      padding: _tabPadding,
      children: [
        SectionCard(
          title: tr.analyticsLeaderboard,
          icon: HugeIcons.strokeRoundedUserGroup,
          child: members.isEmpty
              ? const _NoData()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LeaderboardTable(members),
                    const SizedBox(height: 20),
                    _GroupedBars(members, maxY),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _Dot(BrandColors.primary, tr.analyticsColActivities),
                        _Dot(crm.warning, tr.analyticsColInterventions),
                        _Dot(crm.success, tr.analyticsColDeals),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 6),
      Text(label, style: context.text.bodySmall),
    ],
  );
}

class _LeaderboardTable extends StatelessWidget {
  const _LeaderboardTable(this.members);

  final List<TeamMember> members;

  @override
  Widget build(BuildContext context) {
    final head = context.text.labelLarge?.copyWith(color: context.colors.onSurfaceVariant);
    Widget cell(String text, {TextStyle? style, bool end = true}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Text(
        text,
        style: style,
        textAlign: end ? TextAlign.end : TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
    );
    return Table(
      columnWidths: const {0: FlexColumnWidth(2.2)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(horizontalInside: BorderSide(color: context.colors.outlineVariant)),
      children: [
        TableRow(
          children: [
            cell(tr.analyticsColEmployee, style: head, end: false),
            cell(tr.analyticsColActivities, style: head),
            cell(tr.analyticsColInterventions, style: head),
            cell(tr.analyticsColDeals, style: head),
          ],
        ),
        for (var i = 0; i < members.length; i++)
          TableRow(
            children: [
              cell(
                '${i + 1}.  ${members[i].employee}',
                style: context.text.bodyMedium?.copyWith(fontWeight: i == 0 ? FontWeight.w700 : null),
                end: false,
              ),
              cell(Formatters.number(members[i].activities)),
              cell(Formatters.number(members[i].interventions)),
              cell(Formatters.number(members[i].dealsWon)),
            ],
          ),
      ],
    );
  }
}

class _GroupedBars extends StatelessWidget {
  const _GroupedBars(this.members, this.maxValue);

  final List<TeamMember> members;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final maxY = maxValue <= 0 ? 4.0 : (maxValue * 1.2).ceilToDouble();
    final labelStyle = context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant);
    BarChartRodData rod(num v, Color color) =>
        BarChartRodData(toY: v.toDouble(), width: 14, color: color, borderRadius: BorderRadius.circular(5));
    return SizedBox(
      height: 260,
      child: BarChart(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: context.colors.outlineVariant.withValues(alpha: 0.6), strokeWidth: 1, dashArray: [4, 4]),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) => value == meta.max
                    ? const SizedBox.shrink()
                    : SideTitleWidget(
                        meta: meta,
                        child: Text(Formatters.number(value), style: labelStyle),
                      ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= members.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(members[i].employee, overflow: TextOverflow.ellipsis, style: labelStyle),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.colors.surfaceContainerHighest,
              tooltipBorderRadius: BorderRadius.circular(AppRadius.md),
              getTooltipItem: (group, _, rod, rodIndex) {
                final names = [tr.analyticsColActivities, tr.analyticsColInterventions, tr.analyticsColDeals];
                return BarTooltipItem(
                  '${members[group.x].employee}\n',
                  context.text.labelMedium!.copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: '${names[rodIndex]}: ${Formatters.number(rod.toY)}',
                      style: context.text.labelMedium!.copyWith(color: rod.color),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < members.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: [
                  rod(members[i].activities, BrandColors.primary),
                  rod(members[i].interventions, crm.warning),
                  rod(members[i].dealsWon, crm.success),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
