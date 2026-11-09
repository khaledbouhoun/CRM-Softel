import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app/l10n/l10n.dart';

/// Adds the JSON headers expected by Laravel (`Accept: application/json`
/// makes Laravel return JSON errors instead of HTML redirects).
class JsonHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    options.headers.putIfAbsent('Content-Type', () => 'application/json');
    handler.next(options);
  }
}

/// Rejects 2xx responses whose body is not JSON (typically an Apache/IIS
/// welcome page when the configured URL points to the wrong place).
class JsonResponseGuardInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final data = response.data;
    final isEmpty = data == null || (data is String && data.trim().isEmpty);
    if (isEmpty || data is Map || data is List) {
      handler.next(response);
      return;
    }
    handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.unknown,
        error: FormatException(tr.errNotJson),
      ),
    );
  }
}

/// Logs requests in debug builds only. Never logs in release builds.
class DebugLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[API] → ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[API] ← ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[API] ✗ ${err.type.name} ${err.response?.statusCode ?? ''} '
        '${err.requestOptions.method} ${err.requestOptions.uri}',
      );
    }
    handler.next(err);
  }
}
