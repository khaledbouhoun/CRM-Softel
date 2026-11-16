import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/app/l10n/l10n.dart';
import 'package:softel_crm/core/utils/formatters.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_catalogs.dart';
import 'package:softel_crm/features/activities/data/models/activity_type.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  tearDown(() => L10n.current = AppLocales.french);

  group('ARB files', () {
    final fr = _arb('fr');
    final en = _arb('en');
    final ar = _arb('ar');

    test('the three languages define exactly the same keys', () {
      expect(_keys(en), _keys(fr));
      expect(_keys(ar), _keys(fr));
      expect(_keys(fr), isNotEmpty);
    });

    test(
      'no translation is empty and every placeholder is used in each language',
      () {
        for (final key in _keys(fr)) {
          final meta = fr['@$key'] as Map<String, dynamic>?;
          final names =
              ((meta?['placeholders'] as Map<String, dynamic>?) ?? const {})
                  .keys;
          for (final (lang, arb) in [('en', en), ('ar', ar)]) {
            final value = arb[key] as String;
            expect(value.trim(), isNotEmpty, reason: '$lang/$key is empty');
            for (final name in names) {
              expect(
                value.contains('{$name'),
                isTrue,
                reason: '$lang/$key is missing {$name}',
              );
            }
          }
        }
      },
    );

    test(
      'Arabic strings really are Arabic and English ones are not French copies',
      () {
        final arabic = RegExp(r'[؀-ۿ]');
        for (final key in _keys(fr)) {
          final value = ar[key] as String;
          // Brand / product names (Sage, Excel, PC Compta...) and codes may stay Latin.
          if (RegExp(r'^[A-Za-z0-9 #:/._-]+$').hasMatch(value)) continue;
          expect(
            arabic.hasMatch(value),
            isTrue,
            reason: 'ar/$key has no Arabic text: $value',
          );
        }
        // Short words are often identical in French and English (Type, Date, ...),
        // but a real sentence must have been translated.
        for (final key in _keys(fr)) {
          final text = (fr[key] as String)
              .replaceAll(RegExp(r'\{[^}]*\}'), ' ')
              .replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), ' ');
          final words = text
              .trim()
              .split(RegExp(r'\s+'))
              .where((w) => w.isNotEmpty)
              .length;
          if (words >= 4) {
            expect(
              en[key],
              isNot(fr[key]),
              reason: 'en/$key still holds the French sentence',
            );
          }
        }
      },
    );
  });

  group('translations at runtime', () {
    test('the activity types use the requested labels in each language', () {
      L10n.current = AppLocales.french;
      expect(ActivityType.call.label, 'Appel');
      expect(ActivityType.meeting.label, 'Rendez-vous');
      expect(ActivityType.message.label, 'Message');
      L10n.current = AppLocales.arabic;
      expect(ActivityType.call.label, 'مكالمة هاتفية');
      expect(ActivityType.meeting.label, 'موعد / اجتماع');
      expect(ActivityType.message.label, 'رسالة');
      L10n.current = AppLocales.english;
      expect(ActivityType.call.label, 'Phone call');
      expect(ActivityType.meeting.label, 'Appointment');
      expect(ActivityType.message.label, 'Message');
      // Legacy "meeting" rows read as appointments everywhere.
      expect(ActivityType.meeting.label, 'Appointment');
      expect(ActivityType.fromApi('appointment'), ActivityType.meeting);
    });

    test('plural messages follow each language\'s rules', () {
      L10n.current = AppLocales.english;
      expect(tr.countProspects(1), '1 prospect');
      expect(tr.countProspects(5), '5 prospects');
      L10n.current = AppLocales.french;
      expect(tr.countProspects(0), 'Aucun prospect');
      L10n.current = AppLocales.arabic;
      expect(tr.countProspects(2), 'عميلان محتملان');
      expect(tr.countProspects(7), '7 عملاء محتملين');
    });

    test('dates and numbers follow the language', () {
      final date = DateTime(2026, 11, 8, 14, 30);
      L10n.current = AppLocales.french;
      expect(Formatters.date(date), '08/11/2026');
      expect(Formatters.longDate(date), contains('novembre'));
      L10n.current = AppLocales.english;
      expect(Formatters.longDate(date), contains('November'));
      L10n.current = AppLocales.arabic;
      expect(Formatters.longDate(date), contains('نوفمبر'));
      // Arabic keeps Latin digits (Algerian convention).
      expect(Formatters.date(date), '08/11/2026');
    });
  });

  group('stable codes', () {
    test(
      'predefined values are stored as codes, never as translated labels',
      () {
        for (final lang in [
          AppLocales.french,
          AppLocales.english,
          AppLocales.arabic,
        ]) {
          L10n.current = lang;
          final label = ProspectCatalogs.sources
              .firstWhere((o) => o.code == 'friend_referral')
              .label;
          expect(
            ProspectCatalogs.codeFor(ProspectCatalogs.sources, label),
            'friend_referral',
            reason: '$lang',
          );
        }
      },
    );

    test(
      'a label typed in another language still resolves to the same code',
      () {
        L10n.current = AppLocales.english;
        expect(
          ProspectCatalogs.codeFor(
            ProspectCatalogs.businessActivities,
            'Wholesale trade',
          ),
          'wholesale',
        );
        L10n.current = AppLocales.arabic;
        expect(
          ProspectCatalogs.labelOf(
            ProspectCatalogs.businessActivities,
            'wholesale',
          ),
          'تجارة الجملة',
        );
        L10n.current = AppLocales.french;
        expect(
          ProspectCatalogs.labelOf(
            ProspectCatalogs.businessActivities,
            'wholesale',
          ),
          'Commerce de gros',
        );
      },
    );

    test('free text and unknown codes are kept unchanged', () {
      expect(
        ProspectCatalogs.codeFor(
          ProspectCatalogs.previousSoftware,
          'Logiciel maison',
        ),
        'Logiciel maison',
      );
      expect(
        ProspectCatalogs.labelOf(ProspectCatalogs.sources, 'tiktok'),
        'tiktok',
      );
      expect(ProspectCatalogs.codeFor(ProspectCatalogs.sources, '  '), isNull);
      expect(
        ProspectCatalogs.labelOf(ProspectCatalogs.sources, null),
        tr.notSpecified,
      );
    });

    test('source detail is shown only for "other"', () {
      L10n.current = AppLocales.english;
      expect(
        ProspectCatalogs.sourceDisplay('other', 'Trade fair'),
        'Other — Trade fair',
      );
      expect(ProspectCatalogs.sourceDisplay('facebook', 'ignored'), 'Facebook');
      expect(ProspectCatalogs.sourceDisplay(null, null), isNull);
    });
  });
}
