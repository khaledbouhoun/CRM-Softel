import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../utils/formatters.dart';

/// Motion tokens shared by every animation in the app.
///
/// All helpers in this file honour the operating-system "reduce motion" /
/// "show animations" setting: when it is off they render their final state
/// immediately and never start a ticker.
abstract final class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration entrance = Duration(milliseconds: 320);
  static const Duration page = Duration(milliseconds: 200);
  static const Duration detailPage = Duration(milliseconds: 220);
  static const Duration dialog = Duration(milliseconds: 200);
  static const Duration counter = Duration(milliseconds: 900);

  /// Delay added per item when a group of widgets enters one after another.
  static const Duration stagger = Duration(milliseconds: 45);

  /// Items beyond this index share the last delay so long lists never wait.
  static const int maxStaggerSteps = 8;

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// Whether animations are turned off for the widget tree at [context].
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Same setting, read from the platform. For code that has no [BuildContext]
  /// (route definitions, `Get.dialog`). Falls back to `false` before the
  /// Flutter binding exists (plain unit tests).
  static bool get platformReduced {
    try {
      return WidgetsBinding
          .instance
          .platformDispatcher
          .accessibilityFeatures
          .disableAnimations;
    } on Object {
      return false;
    }
  }

  /// Delay for the [index]-th item of a staggered group.
  static Duration staggerDelay(
    int index, {
    Duration step = stagger,
    Duration start = Duration.zero,
  }) => start + step * math.min(math.max(index, 0), maxStaggerSteps);
}

/// Fades its child in while sliding it a short distance.
///
/// [direction] is the direction the child *travels* while entering:
/// [AxisDirection.up] (default) rises from slightly below its final position,
/// [AxisDirection.left] moves towards the left, and so on. Horizontal
/// directions are mirrored in right-to-left locales unless [mirrorInRtl] is
/// false, so "left" always means "towards the start of the line" for Arabic.
///
/// The widget runs a single [AnimationController]; [delay] is part of its
/// timeline (no timers), so an item that is removed while waiting costs nothing.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.entrance,
    this.direction = AxisDirection.up,
    this.distance = 16,
    this.curve = AppMotion.enter,
    this.mirrorInRtl = true,
    this.enabled = true,
  });

  /// [FadeSlideIn] whose delay is derived from [index] (see
  /// [AppMotion.staggerDelay]).
  factory FadeSlideIn.staggered({
    Key? key,
    required int index,
    required Widget child,
    Duration step = AppMotion.stagger,
    Duration start = Duration.zero,
    Duration duration = AppMotion.entrance,
    AxisDirection direction = AxisDirection.up,
    double distance = 16,
    Curve curve = AppMotion.enter,
    bool enabled = true,
  }) => FadeSlideIn(
    key: key,
    delay: AppMotion.staggerDelay(index, step: step, start: start),
    duration: duration,
    direction: direction,
    distance: distance,
    curve: curve,
    enabled: enabled,
    child: child,
  );

  final Widget child;
  final Duration delay;
  final Duration duration;
  final AxisDirection direction;

  /// Slide distance in logical pixels.
  final double distance;
  final Curve curve;
  final bool mirrorInRtl;

  /// When false the child is shown immediately (e.g. rows far down a list).
  final bool enabled;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _progress;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    final begin = total.inMicroseconds == 0
        ? 0.0
        : widget.delay.inMicroseconds / total.inMicroseconds;
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(math.min(1.0, math.max(0.0, begin)), 1.0, curve: widget.curve),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.enabled || AppMotion.reduced(context)) {
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Start offset (at progress 0) for the current text direction.
  Offset _startOffset(TextDirection textDirection) {
    final d = widget.distance;
    final flip = widget.mirrorInRtl && textDirection == TextDirection.rtl
        ? -1.0
        : 1.0;
    return switch (widget.direction) {
      AxisDirection.up => Offset(0, d),
      AxisDirection.down => Offset(0, -d),
      AxisDirection.left => Offset(d * flip, 0),
      AxisDirection.right => Offset(-d * flip, 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final start = _startOffset(Directionality.of(context));
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        final t = math.min(1.0, math.max(0.0, _progress.value));
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: start * (1 - t), child: child),
        );
      },
    );
  }
}

/// Number that counts from 0 up to [targetValue] when first shown and
/// re-targets smoothly (from the value currently on screen) when
/// [targetValue] changes, e.g. after a refresh.
///
/// Digits are rendered tabular so the text does not jitter while counting, and
/// screen readers get the final value instead of the intermediate ones.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.targetValue,
    this.duration = AppMotion.counter,
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 0,
    this.style,
    this.textAlign,
    this.curve = AppMotion.enter,
    this.formatter,
  });

  final num targetValue;
  final Duration duration;
  final String prefix;
  final String suffix;

  /// Decimals kept while counting (0 = whole numbers).
  final int fractionDigits;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Curve curve;

  /// Overrides the default locale-aware number formatting.
  final String Function(num value)? formatter;

  String _format(num value) {
    if (formatter != null) return formatter!(value);
    final rounded = fractionDigits <= 0
        ? value.round()
        : double.parse(value.toStringAsFixed(fractionDigits));
    return Formatters.number(rounded);
  }

  String _text(num value) => '$prefix${_format(value)}$suffix';

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    final effective = base.copyWith(
      fontFeatures: [
        ...?base.fontFeatures,
        const FontFeature.tabularFigures(),
      ],
    );
    final finalText = _text(targetValue);
    if (AppMotion.reduced(context) || duration == Duration.zero) {
      return Text(finalText, style: effective, textAlign: textAlign);
    }
    return Semantics(
      label: finalText,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: targetValue.toDouble()),
        duration: duration,
        curve: curve,
        builder: (context, value, _) =>
            Text(_text(value), style: effective, textAlign: textAlign),
      ),
    );
  }
}

/// Hover feedback for clickable cards: the card rises a couple of pixels and
/// gains a soft shadow (`MouseRegion` + `AnimatedContainer`). Does nothing on
/// touch, when [enabled] is false, or when animations are reduced.
class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.child,
    this.enabled = true,
    this.lift = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.lg)),
    this.duration = AppMotion.fast,
  });

  final Widget child;
  final bool enabled;
  final double lift;
  final BorderRadius borderRadius;
  final Duration duration;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hover = false;

  void _set(bool value) {
    if (_hover != value) setState(() => _hover = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduced(context)) return widget.child;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shadow = Colors.black.withValues(alpha: dark ? 0.40 : 0.10);
    return MouseRegion(
      onEnter: (_) => _set(true),
      onExit: (_) => _set(false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: AppMotion.enter,
        transform: Matrix4.translationValues(0, _hover ? -widget.lift : 0, 0),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: _hover
              ? [BoxShadow(color: shadow, blurRadius: 16, offset: const Offset(0, 6))]
              : const [],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Scales dialog content from 94% to 100% in step with the dialog route's own
/// fade, and back down when it closes. Used by [showAppDialog].
class AppDialogEntrance extends StatefulWidget {
  const AppDialogEntrance({super.key, required this.child});

  final Widget child;

  @override
  State<AppDialogEntrance> createState() => _AppDialogEntranceState();
}

class _AppDialogEntranceState extends State<AppDialogEntrance> {
  Animation<double>? _source;
  CurvedAnimation? _curved;
  Animation<double>? _scale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (animation == _source) return;
    _curved?.dispose();
    _source = animation;
    _curved = animation == null
        ? null
        : CurvedAnimation(
            parent: animation,
            curve: AppMotion.enter,
            reverseCurve: AppMotion.exit,
          );
    _scale = _curved == null
        ? null
        : Tween<double>(begin: 0.94, end: 1).animate(_curved!);
  }

  @override
  void dispose() {
    _curved?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _scale;
    if (scale == null || AppMotion.reduced(context)) return widget.child;
    return ScaleTransition(scale: scale, child: widget.child);
  }
}

/// Drop-in replacement for `Get.dialog` that opens with a scale + fade
/// (200 ms, ease-out-cubic) and closes with the reverse.
Future<T?> showAppDialog<T>(
  Widget dialog, {
  bool barrierDismissible = true,
  Color? barrierColor,
}) => Get.dialog<T>(
  AppDialogEntrance(child: dialog),
  barrierDismissible: barrierDismissible,
  barrierColor: barrierColor,
  transitionDuration: AppMotion.platformReduced
      ? Duration.zero
      : AppMotion.dialog,
  transitionCurve: AppMotion.enter,
);
