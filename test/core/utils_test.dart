import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/app/config/app_settings_service.dart';
import 'package:softel_crm/app/config/key_value_store.dart';
import 'package:softel_crm/core/utils/json_utils.dart';
import 'package:softel_crm/core/utils/validators.dart';

void main() {
  group('json_utils', () {
    test('asBool accepts Laravel/MySQL encodings', () {
      expect(asBool(true), isTrue);
      expect(asBool(1), isTrue);
      expect(asBool('1'), isTrue);
      expect(asBool('true'), isTrue);
      expect(asBool(0), isFalse);
      expect(asBool('0'), isFalse);
      expect(asBool(null, fallback: true), isTrue);
    });

    test('asInt parses numeric strings', () {
      expect(asInt('12'), 12);
      expect(asInt(3.0), 3);
      expect(asIntOrNull('x'), isNull);
    });

    test('toApiDateTime always includes the UTC offset', () {
      final value = toApiDateTime(DateTime(2026, 11, 1, 14, 30));
      expect(value, matches(RegExp(r'^2026-11-01T14:30:00[+-]\d{2}:\d{2}$')));
      // Round trip keeps the same instant.
      expect(DateTime.parse(value).toLocal(), DateTime(2026, 11, 1, 14, 30));
    });

    test('toApiDate and hex colors', () {
      expect(toApiDate(DateTime(2026, 3, 7)), '2026-03-07');
      expect(parseHexColor('#3B82F6'), 0xFF3B82F6);
      expect(parseHexColor('nope'), isNull);
      expect(toHexColor(0xFF3B82F6), '#3B82F6');
    });
  });

  group('Validators', () {
    test('required', () {
      expect(Validators.required('  '), isNotNull);
      expect(Validators.required('a'), isNull);
    });

    test('email is optional but must be valid', () {
      expect(Validators.email(''), isNull);
      expect(Validators.email('contact@exemple.dz'), isNull);
      expect(Validators.email('contact@'), isNotNull);
      expect(Validators.email('pas un email'), isNotNull);
    });

    test('phone accepts common formats only', () {
      expect(Validators.phone(''), isNull);
      expect(Validators.phone('0550 12 34 56'), isNull);
      expect(Validators.phone('+213 (0) 21-12-34-56'), isNull);
      expect(Validators.phone('12'), isNotNull);
      expect(Validators.phone('05AB'), isNotNull);
    });

    test('hex color', () {
      expect(Validators.hexColor('#A1B2C3'), isNull);
      expect(Validators.hexColor('A1B2C3'), isNotNull);
    });

    test('API base URL', () {
      expect(Validators.apiBaseUrl('http://192.168.1.100:8000/api/v1'), isNull);
      expect(Validators.apiBaseUrl('192.168.1.100:8000/api/v1'), isNull);
      expect(Validators.apiBaseUrl(''), isNotNull);
      expect(Validators.apiBaseUrl('ftp://server'), isNotNull);
    });
  });

  group('AppSettingsService', () {
    test('normalizes and persists the API address', () async {
      final store = InMemoryStore();
      final settings = AppSettingsService(store);
      expect(settings.isConfigured, isFalse);

      await settings.saveApiSettings(
        baseUrl: ' 192.168.1.20:8000/api/v1/ ',
        timeoutSeconds: 20,
      );

      expect(settings.apiBaseUrl.value, 'http://192.168.1.20:8000/api/v1');
      expect(settings.timeout, const Duration(seconds: 20));
      expect(settings.isConfigured, isTrue);
      // A new instance reads the persisted values.
      expect(
        AppSettingsService(store).apiBaseUrl.value,
        'http://192.168.1.20:8000/api/v1',
      );
    });
  });
}
