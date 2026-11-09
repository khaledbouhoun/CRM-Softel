import 'dart:async';

import 'package:get/get.dart';

import '../../core/network/api_exceptions.dart';
import '../../core/network/network_info.dart';
import '../config/app_config.dart';
import '../config/app_settings_service.dart';

enum ConnectionStatus { unknown, checking, online, offline }

/// Periodically checks that the central server answers, for the status
/// indicator in the top bar.
class ConnectionService extends GetxService {
  ConnectionService(this._networkInfo, this._settings, {this.autoCheck = true});

  final NetworkInfo _networkInfo;
  final AppSettingsService _settings;
  final bool autoCheck;

  final status = ConnectionStatus.unknown.obs;
  final lastError = Rxn<ApiException>();
  final lastCheckedAt = Rxn<DateTime>();

  Timer? _timer;
  bool _inFlight = false;

  /// Called when the server becomes reachable again after being offline.
  final _onReconnectListeners = <void Function()>[];

  void addReconnectListener(void Function() listener) =>
      _onReconnectListeners.add(listener);

  @override
  void onInit() {
    super.onInit();
    if (autoCheck) {
      checkNow();
      _timer = Timer.periodic(
        AppConfig.connectionCheckInterval,
        (_) => checkNow(),
      );
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<bool> checkNow() async {
    if (_inFlight) return status.value == ConnectionStatus.online;
    _inFlight = true;
    final previous = status.value;
    if (previous != ConnectionStatus.online) {
      status.value = ConnectionStatus.checking;
    }
    try {
      final error = await _networkInfo.check(_settings.apiBaseUrl.value);
      lastCheckedAt.value = DateTime.now();
      lastError.value = error;
      status.value = error == null
          ? ConnectionStatus.online
          : ConnectionStatus.offline;
      if (error == null &&
          (previous == ConnectionStatus.offline ||
              previous == ConnectionStatus.unknown ||
              previous == ConnectionStatus.checking)) {
        for (final listener in _onReconnectListeners) {
          listener();
        }
      }
      return error == null;
    } finally {
      _inFlight = false;
    }
  }
}
