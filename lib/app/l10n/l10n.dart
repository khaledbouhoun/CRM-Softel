import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

/// Languages offered by the app. The code is what gets persisted; labels are
/// always shown in their own language so users can find theirs.
class AppLocales {
  const AppLocales._();

  static const arabic = Locale('ar');
  static const french = Locale('fr');
  static const english = Locale('en');

  static const supported = [arabic, french, english];

  /// Used until the user picks a language.
  static const fallback = arabic;

  static String nativeName(Locale locale) => switch (locale.languageCode) {
    'ar' => 'العربية',
    'fr' => 'Français',
    _ => 'English',
  };

  static Locale fromCode(String? code) => supported.firstWhere(
    (l) => l.languageCode == code,
    orElse: () => fallback,
  );

  /// `intl` locale used for dates and numbers. Arabic uses the Algerian
  /// variant (Latin digits, as in the business timezone's region).
  static String intlName(Locale locale) => switch (locale.languageCode) {
    'ar' => 'ar_DZ',
    'fr' => 'fr_FR',
    _ => 'en_US',
  };

  static const intlNames = ['ar_DZ', 'fr_FR', 'en_US'];
}

/// Current UI language. Set by `AppSettingsService`; read through [tr].
class L10n {
  const L10n._();

  static Locale _current = AppLocales.fallback;

  static Locale get current => _current;

  static set current(Locale locale) {
    _current = locale;
    Intl.defaultLocale = AppLocales.intlName(locale);
  }

  static bool get isRtl => _current.languageCode == 'ar';
}

/// Translations in the current language. A getter (not a field) so every
/// call site follows language changes; `Get.updateLocale` rebuilds the tree.
AppLocalizations get tr => lookupAppLocalizations(L10n.current);
