import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/core/widgets/animated_entrance.dart';
import 'package:softel_crm/core/widgets/shimmer.dart';

Widget _host(Widget child, {bool disableAnimations = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('FadeSlideIn starts transparent and ends visible', (t) async {
    await t.pumpWidget(
      _host(const FadeSlideIn(delay: Duration(milliseconds: 100), child: Text('x'))),
    );
    expect(t.widget<Opacity>(find.byType(Opacity)).opacity, 0);
    await t.pumpAndSettle();
    expect(t.widget<Opacity>(find.byType(Opacity)).opacity, 1);
  });

  testWidgets('FadeSlideIn is immediate with reduced motion', (t) async {
    await t.pumpWidget(
      _host(const FadeSlideIn(delay: Duration(seconds: 1), child: Text('x')),
          disableAnimations: true),
    );
    expect(t.widget<Opacity>(find.byType(Opacity)).opacity, 1);
  });

  testWidgets('AnimatedCount counts up to the target', (t) async {
    await t.pumpWidget(_host(const AnimatedCount(targetValue: 100)));
    await t.pump(const Duration(milliseconds: 1));
    expect(find.text('100'), findsNothing);
    await t.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('AnimatedCount shows the final value with reduced motion',
      (t) async {
    await t.pumpWidget(_host(
      const AnimatedCount(targetValue: 42, suffix: '%'),
      disableAnimations: true,
    ));
    expect(find.text('42%'), findsOneWidget);
  });

  testWidgets('Shimmer skeleton animates without settling', (t) async {
    await t.pumpWidget(_host(const SkeletonBox(width: 50)));
    await t.pumpWidget(_host(const Shimmer(child: SkeletonBox(width: 50))));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(SkeletonBox), findsOneWidget);
  });
}
