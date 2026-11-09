import 'package:dio/dio.dart';

import 'api_exceptions.dart';
import 'api_interceptors.dart';

/// Centralized HTTP client for the Laravel API.
///
/// * Every method returns the decoded JSON body (`Map`, `List` or `null`).
/// * Every failure is thrown as an [ApiException]; callers never see Dio
///   types.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required Duration timeout,
    HttpClientAdapter? httpClientAdapter,
    bool enableLogging = true,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: timeout,
           sendTimeout: timeout,
           receiveTimeout: timeout,
           responseType: ResponseType.json,
           // Let 4xx/5xx go through the error path so they become
           // ApiExceptions.
           validateStatus: (status) =>
               status != null && status >= 200 && status < 300,
         ),
       ) {
    if (httpClientAdapter != null) _dio.httpClientAdapter = httpClientAdapter;
    _dio.interceptors.addAll([
      JsonHeadersInterceptor(),
      JsonResponseGuardInterceptor(),
      if (enableLogging) DebugLogInterceptor(),
    ]);
  }

  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  /// Applies new connection settings without recreating dependents.
  void configure({String? baseUrl, Duration? timeout}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
    if (timeout != null) {
      _dio.options
        ..connectTimeout = timeout
        ..sendTimeout = timeout
        ..receiveTimeout = timeout;
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Duration? timeout,
  }) => _send(
    () => _dio.get<dynamic>(
      path,
      queryParameters: _clean(query),
      options: _options(timeout),
    ),
  );

  Future<dynamic> post(String path, {Object? data, Duration? timeout}) => _send(
    () => _dio.post<dynamic>(path, data: data, options: _options(timeout)),
  );

  Future<dynamic> put(String path, {Object? data}) =>
      _send(() => _dio.put<dynamic>(path, data: data));

  Future<dynamic> patch(String path, {Object? data}) =>
      _send(() => _dio.patch<dynamic>(path, data: data));

  Future<dynamic> delete(String path) =>
      _send(() => _dio.delete<dynamic>(path));

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is String && data.trim().isEmpty) return null;
      return data;
    } catch (error) {
      throw ApiException.from(error, baseUrl: baseUrl);
    }
  }

  Options? _options(Duration? timeout) => timeout == null
      ? null
      : Options(sendTimeout: timeout, receiveTimeout: timeout);

  /// Removes null / empty values so they are not sent as `param=`.
  static Map<String, dynamic>? _clean(Map<String, dynamic>? query) {
    if (query == null) return null;
    final cleaned = <String, dynamic>{};
    query.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      cleaned[key] = value is bool ? (value ? 1 : 0) : value;
    });
    return cleaned;
  }
}
