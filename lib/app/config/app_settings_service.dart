import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../l10n/l10n.dart';
import 'app_config.dart';
import 'key_value_store.dart';

/// Local, per-computer preferences: API server address, timeout and theme.
///
/// These are the only values stored locally; all business data lives on the
/// server.
class AppSettingsService extends GetxService {
  AppSettingsService(this._store);

  static const _kApiBaseUrl = 'api_base_url';
  static const _kTimeout = 'api_timeout_seconds';
  static const _kThemeMode = 'theme_mode';
  static const _kConfigured = 'api_configured';
  static const _kLanguage = 'language_code';

  final KeyValueStore _store;

  late final RxString apiBaseUrl = RxString(
    _store.read<String>(_kApiBaseUrl) ?? AppConfig.defaultApiBaseUrl,
  );

  late final RxInt timeoutSeconds = RxInt(
    _store.read<int>(_kTimeout) ?? AppConfig.defaultTimeoutSeconds,
  );

  late final Rx<ThemeMode> themeMode = Rx<ThemeMode>(
    _parseThemeMode(_store.read<String>(_kThemeMode)),
  );

  /// UI language. Arabic until the user picks another one.
  late final Rx<Locale> locale = Rx<Locale>(
    L10n.current = AppLocales.fromCode(_store.read<String>(_kLanguage)),
  );

  /// False until the user saved a server address at least once.
  bool get isConfigured => _store.read<bool>(_kConfigured) ?? false;

  Duration get timeout => Duration(seconds: timeoutSeconds.value);

  Future<void> saveApiSettings({
    required String baseUrl,
    required int timeoutSeconds,
  }) async {
    final normalized = normalizeBaseUrl(baseUrl);
    await _store.write(_kApiBaseUrl, normalized);
    await _store.write(_kTimeout, timeoutSeconds);
    await _store.write(_kConfigured, true);
    apiBaseUrl.value = normalized;
    this.timeoutSeconds.value = timeoutSeconds;
  }

  /// Persists the language and switches the running app without a restart.
  Future<void> saveLocale(Locale newLocale) async {
    await _store.write(_kLanguage, newLocale.languageCode);
    L10n.current = newLocale;
    locale.value = newLocale;
    // Rebuilds every widget, so text read through `tr` updates immediately.
    Get.updateLocale(newLocale);
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _store.write(_kThemeMode, mode.name);
    themeMode.value = mode;
  }

  /// Trims spaces and trailing slashes, and adds `http://` when missing.
  static String normalizeBaseUrl(String input) {
    var url = input.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.isNotEmpty && !url.contains('://')) url = 'http://$url';
    return url;
  }

  static ThemeMode _parseThemeMode(String? value) => ThemeMode.values
      .firstWhere((m) => m.name == value, orElse: () => ThemeMode.light);
}
