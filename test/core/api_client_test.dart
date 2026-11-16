import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/core/network/api_exceptions.dart';
import 'package:softel_crm/core/network/api_response.dart';

import '../helpers/fixtures.dart';
import '../helpers/mock_http_adapter.dart';

void main() {
  late MockHttpAdapter adapter;

  setUp(() => adapter = MockHttpAdapter());

  group('ApiClient requests', () {
    test(
      'joins base URL and path, sends JSON headers and cleans query',
      () async {
        adapter.reply('GET', '/prospects', paginated([]));
        final api = buildTestClient(adapter);

        await api.get(
          '/prospects',
          query: {
            'search': '  ',
            'stage_id': null,
            'product_id': 3,
            'include_inactive': true,
          },
        );

        final request = adapter.lastTo('GET', '/prospects');
        expect(request.query, {'product_id': '3', 'include_inactive': '1'});
        expect(request.headers['Accept'], 'application/json');
      },
    );

    test('returns null for 204 No Content', () async {
      adapter.reply('DELETE', '/sales-stages/3', null, status: 204);
      expect(await buildTestClient(adapter).delete('/sales-stages/3'), isNull);
    });

    test('configure() switches the server address at runtime', () async {
      adapter.reply('GET', '/dashboard', wrap({}));
      final api = buildTestClient(adapter)
        ..configure(baseUrl: 'http://10.0.0.5:9000/api/v1');
      await api.get('/dashboard');
      expect(api.baseUrl, 'http://10.0.0.5:9000/api/v1');
      expect(adapter.requests.single.path, '/dashboard');
    });
  });

  group('API error handling', () {
    Future<ApiException> errorOf(Future<dynamic> Function() call) async {
      try {
        await call();
      } on ApiException catch (e) {
        return e;
      }
      fail('Expected an ApiException');
    }

    test(
      'unreachable server → NetworkException mentioning the address',
      () async {
        adapter.fail('GET', '/prospects', DioExceptionType.connectionError);
        final e = await errorOf(
          () => buildTestClient(adapter).get('/prospects'),
        );
        expect(e, isA<NetworkException>());
        expect(e.message, contains(testBaseUrl));
      },
    );

    test('timeout → TimeoutApiException', () async {
      adapter.fail('GET', '/prospects', DioExceptionType.receiveTimeout);
      final e = await errorOf(() => buildTestClient(adapter).get('/prospects'));
      expect(e, isA<TimeoutApiException>());
    });

    test(
      '422 → ValidationException with field errors (dot notation)',
      () async {
        adapter.reply('POST', '/prospects', {
          'message': 'Les données sont invalides.',
          'errors': {
            'company_name': ['Le nom est obligatoire.'],
            'product_ids.0': ['Produit inactif.'],
          },
        }, status: 422);
        final e = await errorOf(
          () => buildTestClient(adapter).post('/prospects', data: {}),
        );
        expect(e, isA<ValidationException>());
        final v = e as ValidationException;
        expect(v.message, 'Les données sont invalides.');
        expect(v.errorFor('company_name'), 'Le nom est obligatoire.');
        expect(v.errorFor('product_ids'), 'Produit inactif.');
        expect(v.allMessages, hasLength(2));
      },
    );

    test(
      '404, 405, 409 and 500 map to dedicated exceptions with server message',
      () async {
        adapter
          ..reply('GET', '/prospects/1', {
            'message': 'Prospect introuvable.',
          }, status: 404)
          ..reply('POST', '/loss-reasons', {}, status: 405)
          ..reply('DELETE', '/sales-stages/1', {
            'message': 'Étape utilisée.',
          }, status: 409)
          ..reply('GET', '/dashboard', {
            'message': 'Server Error',
          }, status: 500);
        final api = buildTestClient(adapter);

        final notFound = await errorOf(() => api.get('/prospects/1'));
        expect(notFound, isA<NotFoundException>());
        expect(notFound.message, 'Prospect introuvable.');
        expect(
          await errorOf(() => api.post('/loss-reasons')),
          isA<NotSupportedException>(),
        );
        final conflict = await errorOf(() => api.delete('/sales-stages/1'));
        expect(conflict, isA<ConflictException>());
        expect(conflict.message, 'Étape utilisée.');
        final server = await errorOf(() => api.get('/dashboard'));
        expect(server, isA<ServerException>());
        expect(server.statusCode, 500);
      },
    );

    test('HTML page instead of JSON → UnexpectedResponseException', () async {
      adapter.on(
        'GET',
        '/sales-stages',
        (_) => const MockResponse(
          200,
          '<html><body>It works!</body></html>',
          contentType: 'text/html',
        ),
      );
      final e = await errorOf(
        () => buildTestClient(adapter).get('/sales-stages'),
      );
      expect(e, isA<UnexpectedResponseException>());
      expect(e.message, contains('/api/v1'));
    });

    test('malformed payload while parsing → UnexpectedResponseException', () {
      expect(
        () => ApiResponse.list('not a list', (j) => j),
        throwsA(isA<UnexpectedResponseException>()),
      );
      expect(
        ApiException.from(const FormatException('x')),
        isA<UnexpectedResponseException>(),
      );
    });
  });

  group('ApiResponse envelopes', () {
    test('object() unwraps data and accepts bare objects', () {
      expect(ApiResponse.object(wrap({'id': 1})), {'id': 1});
      expect(ApiResponse.object({'id': 2}), {'id': 2});
    });

    test(
      'paginated() reads Laravel meta, top-level paginator and bare lists',
      () {
        final fromMeta = Paginated.fromJson(
          paginated(
            [
              {'id': 1},
              {'id': 2},
            ],
            page: 2,
            lastPage: 3,
            perPage: 2,
            total: 6,
          ),
          (j) => j['id'],
        );
        expect(fromMeta.items, [1, 2]);
        expect(fromMeta.currentPage, 2);
        expect(fromMeta.hasNext, isTrue);
        expect(fromMeta.hasPrevious, isTrue);
        expect(fromMeta.from, 3);
        expect(fromMeta.to, 4);

        final topLevel = Paginated.fromJson({
          'data': [
            {'id': 1},
          ],
          'current_page': 1,
          'last_page': 1,
          'per_page': 10,
          'total': 1,
        }, (j) => j['id']);
        expect(topLevel.total, 1);
        expect(topLevel.perPage, 10);

        final bare = Paginated.fromJson([
          {'id': 1},
        ], (j) => j['id']);
        expect(bare.total, 1);
        expect(bare.hasNext, isFalse);
      },
    );
  });
}
