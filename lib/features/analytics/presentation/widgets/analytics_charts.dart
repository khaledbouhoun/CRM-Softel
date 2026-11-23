import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

/// Colors for categorical series, derived from the active theme.
List<Color> analyticsPalette(BuildContext context) => [
  BrandColors.primary,
  context.crm.success,
  context.crm.warning,
  context.colors.tertiary,
  context.crm.danger,
  context.crm.info,
  context.colors.secondary,
  context.colors.outline,
];

/// One bar of [AnalyticsBarChart].
class BarDatum {
  const BarDatum({required this.label, required this.value, this.caption});

  final String label;
  final num value;

  /// Extra tooltip line (e.g. the conversion rate).
  final String? caption;
}

/// Vertical rounded bars with soft gradients, tooltips and load animation.
class AnalyticsBarChart extends StatelessWidget {
  const AnalyticsBarChart({
    super.key,
    required this.data,
    this.height = 240,
    this.color,
  });

  final List<BarDatum> data;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = color ?? BrandColors.primary;
    final maxValue = data.fold<num>(0, (m, d) => math.max(m, d.value));
    final maxY = maxValue <= 0 ? 4.0 : (maxValue * 1.2).ceilToDouble();
    final labelStyle = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );

    return SizedBox(
      height: height,
      child: BarChart(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: math.max(1, (maxY / 4).ceilToDouble()),
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.colors.outlineVariant.withValues(alpha: 0.6),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: math.max(1, (maxY / 4).ceilToDouble()),
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
                reservedSize: 44,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: SizedBox(
                      width: 78,
                      child: Text(
                        data[i].label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.colors.surfaceContainerHighest,
              tooltipBorderRadius: BorderRadius.circular(AppRadius.md),
              getTooltipItem: (group, _, rod, _) {
                final d = data[group.x];
                return BarTooltipItem(
                  '${d.label}\n',
                  context.text.labelMedium!.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: Formatters.number(d.value) +
                          (d.caption == null ? '' : '  ·  ${d.caption}'),
                      style: context.text.labelMedium!.copyWith(
                        color: base,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value.toDouble(),
                    width: 26,
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [base.withValues(alpha: 0.55), base],
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: context.colors.surfaceContainerHigh.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// One slice of [AnalyticsDonut].
class SliceDatum {
  const SliceDatum({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final num value;
  final Color color;
}

/// Donut chart: touching or hovering a slice enlarges it and shows its label
/// and share in the middle. Pass [centerLabel] / [centerValue] for a static
/// gauge-style center instead.
class AnalyticsDonut extends StatefulWidget {
  const AnalyticsDonut({
    super.key,
    required this.slices,
    this.size = 210,
    this.centerValue,
    this.centerLabel,
  });

  final List<SliceDatum> slices;
  final double size;
  final String? centerValue;
  final String? centerLabel;

  @override
  State<AnalyticsDonut> createState() => _AnalyticsDonutState();
}

class _AnalyticsDonutState extends State<AnalyticsDonut> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final slices = widget.slices.where((s) => s.value > 0).toList();
    final total = slices.fold<num>(0, (s, e) => s + e.value);
    final hovered = _touched >= 0 && _touched < slices.length
        ? slices[_touched]
        : null;
    final ringWidth = widget.size * 0.17;

    final centerValue = hovered != null
        ? Formatters.number(hovered.value)
        : widget.centerValue ?? Formatters.number(total);
    final centerLabel = hovered != null
        ? '${hovered.label} · ${(hovered.value / total * 100).toStringAsFixed(1)}%'
        : widget.centerLabel;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            PieChartData(
              sectionsSpace: slices.length > 1 ? 3 : 0,
              centerSpaceRadius: widget.size / 2 - ringWidth - 6,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final index =
                      response?.touchedSection?.touchedSectionIndex ?? -1;
                  final active = event.isInterestedForInteractions;
                  final next = active ? index : -1;
                  if (next != _touched) setState(() => _touched = next);
                },
              ),
              sections: slices.isEmpty
                  ? [
                      PieChartSectionData(
                        value: 1,
                        color: context.colors.surfaceContainerHigh,
                        radius: ringWidth,
                        showTitle: false,
                      ),
                    ]
                  : [
                      for (var i = 0; i < slices.length; i++)
                        PieChartSectionData(
                          value: slices[i].value.toDouble(),
                          color: slices[i].color,
                          radius: i == _touched ? ringWidth + 7 : ringWidth,
                          showTitle: false,
                        ),
                    ],
            ),
          ),
          IgnorePointer(
            child: Padding(
              padding: EdgeInsets.all(ringWidth + 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      centerValue,
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (centerLabel != null)
                    Text(
                      centerLabel,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Color-coded legend for [AnalyticsDonut].
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.slices, this.showShare = true});

  final List<SliceDatum> slices;
  final bool showShare;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<num>(0, (s, e) => s + e.value);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.label,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  showShare && total > 0
                      ? '${Formatters.number(s.value)}  ·  ${(s.value / total * 100).toStringAsFixed(0)}%'
                      : Formatters.number(s.value),
                  style: context.text.labelLarge,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Labelled progress bar (geographic concentration, shares).
class ShareBarRow extends StatelessWidget {
  const ShareBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    this.color,
  });

  final String label;
  final num value;
  final num max;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium,
              ),
            ),
            Text(Formatters.number(value), style: context.text.labelLarge),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: max <= 0 ? 0 : (value / max).clamp(0, 1).toDouble()),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              color: color ?? BrandColors.primary,
              backgroundColor: context.colors.surfaceContainerHigh,
            ),
          ),
        ),
      ],
    ),
  );
}
