import 'dart:convert';
import 'dart:typed_data';

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
    String? Function()? employeeName,
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
      if (employeeName != null) EmployeeHeaderInterceptor(employeeName),
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

  /// Multipart upload (reply attachments, release installers). Uploads can
  /// be large, so callers pass a generous [timeout].
  Future<dynamic> postForm(
    String path, {
    required FormData data,
    Duration? timeout,
    void Function(int sent, int total)? onProgress,
  }) => _send(
    () => _dio.post<dynamic>(
      path,
      data: data,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      ),
      onSendProgress: onProgress,
    ),
  );

  /// Downloads a (small) file into memory: images and PDFs shown in a
  /// preview. Errors keep the API envelope (`message`, `error_code`).
  Future<Uint8List> getBytes(String path, {Duration? timeout}) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: timeout,
        ),
      );
      return Uint8List.fromList(response.data ?? const <int>[]);
    } catch (error) {
      throw ApiException.from(_decodeBytesError(error), baseUrl: baseUrl);
    }
  }

  /// Streams a (possibly large) file straight to [savePath] without holding
  /// it in memory: installers can weigh hundreds of megabytes.
  Future<void> downloadTo(
    String path,
    String savePath, {
    void Function(int received, int total)? onProgress,
    Duration? timeout,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        onReceiveProgress: onProgress,
        options: Options(receiveTimeout: timeout),
      );
    } catch (error) {
      throw ApiException.from(error, baseUrl: baseUrl);
    }
  }

  /// With `ResponseType.bytes` a JSON error body arrives as bytes; decode it
  /// so the usual envelope handling (422 field errors, error codes) works.
  static Object _decodeBytesError(Object error) {
    if (error is! DioException) return error;
    final response = error.response;
    final body = response?.data;
    if (response == null || body is! List<int>) return error;
    try {
      final decoded = jsonDecode(utf8.decode(body));
      return DioException(
        requestOptions: error.requestOptions,
        response: Response<dynamic>(
          requestOptions: response.requestOptions,
          statusCode: response.statusCode,
          headers: response.headers,
          data: decoded,
        ),
        type: error.type,
        error: error.error,
        message: error.message,
      );
    } catch (_) {
      return error;
    }
  }

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
