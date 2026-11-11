import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:softel_crm/core/widgets/whatsapp_button.dart';

void main() {
  Widget buildApp(Widget child) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );

  group('WhatsAppButton', () {
    testWidgets('renders phone number and icon when valid', (tester) async {
      await tester.pumpWidget(
        buildApp(const WhatsAppButton(phone: '0550123456')),
      );

      expect(find.byType(WhatsAppButton), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.byType(FaIcon), findsOneWidget);
    });

    testWidgets('renders in disabled appearance when phone is null', (tester) async {
      await tester.pumpWidget(
        buildApp(const WhatsAppButton(phone: null)),
      );

      expect(find.byType(WhatsAppButton), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
    });
  });

  group('WhatsAppIconButton', () {
    testWidgets('renders icon and responds when phone is valid', (tester) async {
      await tester.pumpWidget(
        buildApp(const WhatsAppIconButton(phone: '0550123456')),
      );

      expect(find.byType(WhatsAppIconButton), findsOneWidget);
      expect(find.byType(FaIcon), findsOneWidget);
    });

    testWidgets('renders disabled icon when phone is null', (tester) async {
      await tester.pumpWidget(
        buildApp(const WhatsAppIconButton(phone: null)),
      );

      expect(find.byType(WhatsAppIconButton), findsOneWidget);
      expect(find.byType(FaIcon), findsOneWidget);
    });
  });
}
