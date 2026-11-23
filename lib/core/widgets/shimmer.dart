import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/l10n/l10n.dart';
import '../../app/theme/app_theme.dart';
import 'animated_entrance.dart';

/// Sweeps a soft highlight across [child] (loading skeletons).
///
/// The child only needs to paint opaque shapes (see [SkeletonBox]); the
/// gradient replaces their colour. With reduced motion the shapes stay in
/// their flat base colour and no ticker runs. The sweep follows the reading
/// direction, so it travels right-to-left in Arabic.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final Duration period;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return widget.child;
    final base = skeletonBaseColor(context);
    final highlight = skeletonHighlightColor(context);
    final direction = Directionality.of(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final percent =
              -1 + 2 * Curves.easeInOut.transform(_controller.value);
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              transform: _SlideGradient(percent),
            ).createShader(bounds, textDirection: direction),
            child: child,
          );
        },
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.percent);

  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final sign = textDirection == TextDirection.rtl ? -1.0 : 1.0;
    return Matrix4.translationValues(bounds.width * percent * sign, 0, 0);
  }
}

Color skeletonBaseColor(BuildContext context) =>
    context.colors.surfaceContainerHigh;

Color skeletonHighlightColor(BuildContext context) => Color.lerp(
  context.colors.surfaceContainerHigh,
  context.colors.onSurface,
  0.08,
)!;

/// Rounded placeholder block.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 6,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: skeletonBaseColor(context),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Table-like placeholder: avatar, two text lines and a trailing badge.
class SkeletonRows extends StatelessWidget {
  const SkeletonRows({super.key, this.count = 8, this.rowHeight = 52});

  final int count;
  final double rowHeight;

  static const _lineFactors = [0.55, 0.4, 0.7, 0.48, 0.62, 0.36, 0.58, 0.44];

  @override
  Widget build(BuildContext context) {
    final outline = context.colors.outlineVariant.withValues(alpha: 0.5);
    return Semantics(
      label: tr.loading,
      container: true,
      child: ExcludeSemantics(
        child: Shimmer(
          // Scroll view (never scrollable) so a short window clips the rows
          // instead of overflowing.
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
            children: [
              for (var i = 0; i < count; i++)
                Container(
                  height: rowHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: outline)),
                  ),
                  child: Row(
                    children: [
                      const SkeletonBox(width: 32, height: 32, radius: 16),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FractionallySizedBox(
                              widthFactor: _lineFactors[i % _lineFactors.length],
                              child: const SkeletonBox(height: 12),
                            ),
                            const SizedBox(height: 7),
                            FractionallySizedBox(
                              widthFactor:
                                  _lineFactors[(i + 3) % _lineFactors.length] *
                                  0.6,
                              child: const SkeletonBox(height: 9),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      const SkeletonBox(width: 72, height: 20, radius: 10),
                    ],
                  ),
                ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashboard-like placeholder: a row of KPI cards followed by two panels.
class SkeletonCards extends StatelessWidget {
  const SkeletonCards({super.key});

  Widget _card(BuildContext context, double height) => Container(
    height: height,
    decoration: BoxDecoration(
      color: skeletonBaseColor(context),
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  );

  @override
  Widget build(BuildContext context) => Semantics(
    label: tr.loading,
    container: true,
    child: ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final perRow = constraints.maxWidth > 900 ? 4 : 2;
          final width = (constraints.maxWidth - 56 - (perRow - 1) * 14) / perRow;
          final panels = constraints.maxWidth < 900;
          return Shimmer(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _card(context, 88),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (var i = 0; i < perRow; i++)
                        SizedBox(width: math.max(width, 0), child: _card(context, 112)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (panels) ...[
                    _card(context, 240),
                    const SizedBox(height: 16),
                    _card(context, 240),
                  ] else
                    Row(
                      children: [
                        Expanded(child: _card(context, 260)),
                        const SizedBox(width: 16),
                        Expanded(child: _card(context, 260)),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
