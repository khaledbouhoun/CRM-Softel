import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../utils/formatters.dart';
import 'animated_entrance.dart';

class ChartDatum {
  const ChartDatum({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final num value;
  final Color color;
}

/// Horizontal bars with labels and values; no dependency needed.
class HorizontalBarChart extends StatelessWidget {
  const HorizontalBarChart({
    super.key,
    required this.data,
    this.labelWidth = 150,
    this.onTap,
  });

  final List<ChartDatum> data;
  final double labelWidth;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<num>(0, (m, d) => math.max(m, d.value));
    final total = data.fold<num>(0, (s, d) => s + d.value);
    return Column(
      children: [
        for (var i = 0; i < data.length; i++)
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onTap == null ? null : () => onTap!(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: labelWidth,
                    child: Text(
                      data[i].label,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium,
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final ratio = maxValue == 0
                            ? 0.0
                            : data[i].value / maxValue;
                        return Stack(
                          children: [
                            Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // Grows from 0 on first show, retargets on refresh.
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0,
                                end: math.max(
                                  c.maxWidth * ratio,
                                  data[i].value > 0 ? 4 : 0,
                                ),
                              ),
                              duration: AppMotion.reduced(context)
                                  ? Duration.zero
                                  : Duration(milliseconds: 500 + 40 * math.min(i, 8)),
                              curve: AppMotion.enter,
                              builder: (context, width, _) => Container(
                                height: 18,
                                width: width,
                                decoration: BoxDecoration(
                                  color: data[i].color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 84,
                    child: Text(
                      '${Formatters.number(data[i].value)}  '
                      '(${Formatters.percent(data[i].value, total)})',
                      textAlign: TextAlign.end,
                      style: context.text.bodySmall?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Donut chart with a centered label and a legend.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.data,
    this.centerValue,
    this.centerLabel,
    this.size = 150,
    this.onTap,
  });

  /// Called with the index of the tapped legend row.
  final void Function(int index)? onTap;

  final List<ChartDatum> data;
  final String? centerValue;
  final String? centerLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<num>(0, (s, d) => s + d.value);
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          // Rings sweep clockwise from 0 to full on first show.
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: AppMotion.reduced(context) ? 1 : 0,
              end: 1,
            ),
            duration: const Duration(milliseconds: 800),
            curve: AppMotion.enter,
            builder: (context, progress, child) => CustomPaint(
              painter: _DonutPainter(
                data,
                track: context.colors.surfaceContainerHigh,
                progress: progress,
              ),
              child: child,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (centerValue != null)
                    Text(centerValue!, style: context.text.headlineSmall),
                  if (centerLabel != null)
                    Text(
                      centerLabel!,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < data.length; i++)
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onTap == null ? null : () => onTap!(i),
                child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Builder(builder: (context) { final d = data[i]; return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: d.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(d.label, style: context.text.bodyMedium),
                    const SizedBox(width: 8),
                    Text(
                      '${Formatters.number(d.value)} · ${Formatters.percent(d.value, total)}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ); }),
              ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.data, {required this.track, this.progress = 1});

  final List<ChartDatum> data;
  final Color track;

  /// 0..1 share of the full ring that is drawn.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.14;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);

    final total = data.fold<num>(0, (s, d) => s + d.value);
    if (total == 0) return;
    var start = -math.pi / 2;
    const gap = 0.02;
    for (final d in data) {
      if (d.value <= 0) continue;
      final sweep = (d.value / total) * math.pi * 2 * progress;
      canvas.drawArc(
        rect,
        start,
        math.max(sweep - gap, 0.001),
        false,
        paint..color = d.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.data != data || old.track != track || old.progress != progress;
}
