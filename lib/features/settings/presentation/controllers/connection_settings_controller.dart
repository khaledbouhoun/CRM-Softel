import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/config/app_settings_service.dart';
import '../../../../app/services/connection_service.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/validators.dart';
import '../../../../app/l10n/l10n.dart';

enum ConnectionTestStatus { idle, testing, success, failure }

enum ConnectionSaveResult { notSaved, savedOnline, savedOffline }

/// API server address / timeout configuration (stored locally per computer).
class ConnectionSettingsController extends GetxController {
  ConnectionSettingsController({
    required AppSettingsService settings,
    required NetworkInfo networkInfo,
    this.connection,
    this.lookups,
  }) : _settings = settings,
       _networkInfo = networkInfo;

  final AppSettingsService _settings;
  final NetworkInfo _networkInfo;
  final ConnectionService? connection;
  final LookupService? lookups;

  final formKey = GlobalKey<FormState>();
  late final baseUrl = TextEditingController(text: _settings.apiBaseUrl.value);
  late final timeoutSeconds = _settings.timeoutSeconds.value.obs;

  final testStatus = ConnectionTestStatus.idle.obs;
  final testMessage = RxnString();
  final isSaving = false.obs;

  bool get isFirstLaunch => !_settings.isConfigured;
  String get savedUrl => _settings.apiBaseUrl.value;

  String? validateUrl(String? v) => Validators.apiBaseUrl(v);

  void onUrlChanged() {
    testStatus.value = ConnectionTestStatus.idle;
    testMessage.value = null;
  }

  void setTimeout(int seconds) => timeoutSeconds.value = seconds.clamp(
    AppConfig.minTimeoutSeconds,
    AppConfig.maxTimeoutSeconds,
  );

  /// Tests the address currently typed (not necessarily saved).
  Future<bool> testConnection() async {
    if (testStatus.value == ConnectionTestStatus.testing) return false;
    final error = validateUrl(baseUrl.text);
    if (error != null) {
      testStatus.value = ConnectionTestStatus.failure;
      testMessage.value = error;
      return false;
    }
    testStatus.value = ConnectionTestStatus.testing;
    testMessage.value = null;
    final url = AppSettingsService.normalizeBaseUrl(baseUrl.text);
    final ApiException? failure = await _networkInfo.check(url);
    if (failure == null) {
      testStatus.value = ConnectionTestStatus.success;
      testMessage.value = tr.connectionSuccess(url);
      return true;
    }
    testStatus.value = ConnectionTestStatus.failure;
    testMessage.value = failure.message;
    return false;
  }

  /// Saves locally. The address is saved even if the server is currently
  /// unreachable (it may be switched off), but the result says so.
  Future<ConnectionSaveResult> save() async {
    if (isSaving.value) return ConnectionSaveResult.notSaved;
    final valid =
        (formKey.currentState?.validate() ?? true) &&
        validateUrl(baseUrl.text) == null;
    if (!valid) return ConnectionSaveResult.notSaved;
    isSaving.value = true;
    try {
      await _settings.saveApiSettings(
        baseUrl: baseUrl.text,
        timeoutSeconds: timeoutSeconds.value,
      );
      baseUrl.text = _settings.apiBaseUrl.value;
      final online = await connection?.checkNow() ?? true;
      if (!online) return ConnectionSaveResult.savedOffline;
      await lookups?.refreshQuietly();
      return ConnectionSaveResult.savedOnline;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    baseUrl.dispose();
    super.onClose();
  }
}
