import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/core/utils/whatsapp_launcher.dart';

void main() {
  group('WhatsAppLauncher.sanitize', () {
    test('handles null and empty', () {
      expect(WhatsAppLauncher.sanitize(null), isNull);
      expect(WhatsAppLauncher.sanitize(''), isNull);
      expect(WhatsAppLauncher.sanitize('   '), isNull);
    });

    test('converts domestic 10-digit Algerian numbers starting with 0', () {
      expect(WhatsAppLauncher.sanitize('0550123456'), equals('213550123456'));
      expect(WhatsAppLauncher.sanitize('0661123456'), equals('213661123456'));
      expect(WhatsAppLauncher.sanitize('0770123456'), equals('213770123456'));
    });

    test('converts domestic 9-digit Algerian landlines starting with 0', () {
      expect(WhatsAppLauncher.sanitize('021123456'), equals('21321123456'));
    });

    test('handles phone numbers with formatting spaces, dashes, dots, and parens', () {
      expect(WhatsAppLauncher.sanitize('0550 12 34 56'), equals('213550123456'));
      expect(WhatsAppLauncher.sanitize('0550-12-34-56'), equals('213550123456'));
      expect(WhatsAppLauncher.sanitize('(0550) 12.34.56'), equals('213550123456'));
    });

    test('handles international numbers starting with +', () {
      expect(WhatsAppLauncher.sanitize('+213550123456'), equals('213550123456'));
      expect(WhatsAppLauncher.sanitize('+33612345678'), equals('33612345678'));
    });

    test('handles numbers starting with 00', () {
      expect(WhatsAppLauncher.sanitize('00213550123456'), equals('213550123456'));
      expect(WhatsAppLauncher.sanitize('0033612345678'), equals('33612345678'));
    });

    test('handles international numbers already starting with 213 without +', () {
      expect(WhatsAppLauncher.sanitize('213550123456'), equals('213550123456'));
    });

    test('rejects numbers that are too short to be valid', () {
      expect(WhatsAppLauncher.sanitize('123'), isNull);
    });
  });

  group('WhatsAppLauncher.getUri', () {
    test('builds wa.me URL correctly', () {
      final uri = WhatsAppLauncher.getUri('0550 12 34 56');
      expect(uri, isNotNull);
      expect(uri.toString(), equals('https://wa.me/213550123456'));
    });

    test('includes pre-filled text if provided', () {
      final uri = WhatsAppLauncher.getUri('+213550123456', text: 'Bonjour');
      expect(uri, isNotNull);
      expect(uri.toString(), equals('https://wa.me/213550123456?text=Bonjour'));
    });
  });
}
