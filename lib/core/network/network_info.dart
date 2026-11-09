import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';

/// Checks whether the Laravel API answers at a given base URL.
class NetworkInfo {
  NetworkInfo({HttpClientAdapter? httpClientAdapter})
    : _adapter = httpClientAdapter;

  final HttpClientAdapter? _adapter;

  /// Returns `null` when the server answered with JSON, otherwise the error.
  ///
  /// A dedicated client is used so an address can be tested before it is
  /// saved, and so the short timeout never affects normal requests.
  Future<ApiException?> check(
    String baseUrl, {
    Duration timeout = AppConfig.connectionCheckTimeout,
  }) async {
    final client = ApiClient(
      baseUrl: baseUrl,
      timeout: timeout,
      httpClientAdapter: _adapter,
      enableLogging: false,
    );
    try {
      await client.get(ApiEndpoints.connectionCheck);
      return null;
    } on ApiException catch (e) {
      return e;
    }
  }
}
