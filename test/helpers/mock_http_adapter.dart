import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:softel_crm/core/network/api_client.dart';

const testBaseUrl = 'http://test.local:8000/api/v1';

class RecordedRequest {
  RecordedRequest(this.method, this.path, this.query, this.body, this.headers);

  final String method;
  final String path;
  final Map<String, dynamic> query;
  final Object? body;
  final Map<String, dynamic> headers;

  Map<String, dynamic> get json => body as Map<String, dynamic>;

  @override
  String toString() => '$method $path $query $body';
}

class MockResponse {
  const MockResponse(
    this.status,
    this.body, {
    this.contentType = 'application/json',
  });

  final int status;
  final Object? body;
  final String contentType;
}

typedef MockHandler = FutureOr<MockResponse> Function(RecordedRequest request);

/// Dio adapter returning canned responses, keyed by "METHOD /path".
/// Unregistered routes answer 404 like Laravel.
class MockHttpAdapter implements HttpClientAdapter {
  final _routes = <String, MockHandler>{};
  final requests = <RecordedRequest>[];

  void on(String method, String path, MockHandler handler) =>
      _routes['${method.toUpperCase()} $path'] = handler;

  void reply(String method, String path, Object? body, {int status = 200}) =>
      on(method, path, (_) => MockResponse(status, body));

  /// Simulates a transport-level failure (server off, timeout...).
  void fail(String method, String path, DioExceptionType type) => on(
    method,
    path,
    (r) => throw DioException(
      requestOptions: RequestOptions(path: r.path),
      type: type,
      message: 'simulated ${type.name}',
    ),
  );

  List<RecordedRequest> requestsTo(String method, String path) => requests
      .where((r) => r.method == method.toUpperCase() && r.path == path)
      .toList();

  RecordedRequest lastTo(String method, String path) =>
      requestsTo(method, path).last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final uri = options.uri;
    // Strip the "/api/v1" prefix so routes are registered like endpoints.
    final basePath = Uri.parse(options.baseUrl).path;
    final path = uri.path.startsWith(basePath)
        ? uri.path.substring(basePath.length)
        : uri.path;
    final request = RecordedRequest(
      options.method.toUpperCase(),
      path,
      uri.queryParameters,
      options.data,
      options.headers,
    );
    requests.add(request);

    final handler = _routes['${request.method} $path'];
    final response = handler == null
        ? const MockResponse(404, {'message': 'Not found.'})
        : await handler(request);

    final text = response.body == null
        ? ''
        : (response.body is String
              ? response.body as String
              : jsonEncode(response.body));
    return ResponseBody.fromString(
      text,
      response.status,
      headers: {
        Headers.contentTypeHeader: [response.contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient buildTestClient(MockHttpAdapter adapter) => ApiClient(
  baseUrl: testBaseUrl,
  timeout: const Duration(seconds: 2),
  httpClientAdapter: adapter,
  enableLogging: false,
);

/// Lets pending futures (onInit loads, chained requests) complete.
Future<void> settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
