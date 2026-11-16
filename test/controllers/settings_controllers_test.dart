import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/app/config/app_settings_service.dart';
import 'package:softel_crm/app/config/key_value_store.dart';
import 'package:softel_crm/core/network/api_exceptions.dart';
import 'package:softel_crm/core/network/network_info.dart';
import 'package:softel_crm/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:softel_crm/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:softel_crm/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:softel_crm/features/pipeline/presentation/controllers/pipeline_controller.dart';
import 'package:softel_crm/features/products/presentation/controllers/products_controllers.dart';
import 'package:softel_crm/features/prospects/data/models/prospect.dart';
import 'package:softel_crm/features/settings/data/models/sales_stage.dart';
import 'package:softel_crm/features/settings/presentation/controllers/connection_settings_controller.dart';
import 'package:softel_crm/features/settings/presentation/controllers/loss_reasons_settings_controllers.dart';
import 'package:softel_crm/features/settings/presentation/controllers/stages_settings_controllers.dart';

import '../helpers/fixtures.dart';
import '../helpers/mock_http_adapter.dart';
import '../helpers/test_env.dart';

void main() {
  late TestEnv env;

  setUp(() {
    Get.testMode = true;
    env = TestEnv()..stubReferenceData();
  });

  tearDown(Get.reset);

  group('StagesSettingsController', () {
    Future<StagesSettingsController> build() async {
      final c = Get.put(StagesSettingsController(repository: env.stages));
      await settle();
      return c;
    }

    test('reorder applies the server order on success', () async {
      env.adapter.on('POST', '/sales-stages/reorder', (r) {
        final ids = (r.json['ids'] as List).cast<int>();
        final byId = {
          for (final s in [
            openStage,
            demoStage,
            wonStage,
            lostStage,
            inactiveStage,
          ])
            s['id']: s,
        };
        return MockResponse(
          200,
          wrap([
            for (var i = 0; i < ids.length; i++)
              {...byId[ids[i]]!, 'sort_order': i + 1},
          ]),
        );
      });
      final c = await build();
      expect(c.stages.map((s) => s.id), [1, 2, 5, 6, 9]);
      final result = await c.move(0, 2);
      expect(result.isSuccess, isTrue);
      expect(env.adapter.lastTo('POST', '/sales-stages/reorder').json, {
        'ids': [2, 5, 1, 6, 9],
      });
      expect(c.stages.map((s) => s.id), [2, 5, 1, 6, 9]);
    });

    test('reorder reverts when the server refuses', () async {
      env.adapter.fail(
        'POST',
        '/sales-stages/reorder',
        DioExceptionType.connectionError,
      );
      final c = await build();
      final result = await c.move(0, 4);
      expect(result.isSuccess, isFalse);
      expect(c.stages.map((s) => s.id), [1, 2, 5, 6, 9]);
      expect(c.isSavingOrder.value, isFalse);
    });

    test('a used stage cannot be deleted (no request sent)', () async {
      final c = await build();
      final used = c.stages.first;
      expect(used.isUsed, isTrue);
      final result = await c.delete(used);
      expect(result.error, isA<ConflictException>());
      expect(env.adapter.requestsTo('DELETE', '/sales-stages/1'), isEmpty);
    });

    test('an unused stage can be deleted; deactivation uses PATCH', () async {
      env.adapter
        ..reply('DELETE', '/sales-stages/7', null, status: 204)
        ..reply('PATCH', '/sales-stages/1', wrap(stageJson(isActive: false)));
      final c = await build();
      final unused = SalesStage.fromJson(stageJson(id: 7, prospectsCount: 0));
      expect((await c.delete(unused)).isSuccess, isTrue);
      expect((await c.setActive(c.stages.first, false)).isSuccess, isTrue);
      expect(env.adapter.lastTo('PATCH', '/sales-stages/1').json, {
        'is_active': false,
      });
    });

    test('type of a used stage is locked in the form', () async {
      env.adapter.reply('PUT', '/sales-stages/1', wrap(openStage));
      final form = Get.put(
        StageFormController(
          repository: env.stages,
          initial: SalesStage.fromJson(openStage),
        ),
      );
      expect(form.isTypeLocked, isTrue);
      form.type.value = StageType.lost; // ignored for used stages
      await form.submit();
      expect(
        env.adapter.lastTo('PUT', '/sales-stages/1').json['stage_type'],
        'open',
      );
    });
  });

  group('LossReasonsSettingsController', () {
    test('becomes read-only when management endpoints are missing', () async {
      env.adapter.reply('PATCH', '/loss-reasons/1', {
        'message': 'Method not allowed',
      }, status: 405);
      final c = Get.put(
        LossReasonsSettingsController(repository: env.lossReasons),
      );
      await settle();
      expect(c.reasons.map((r) => r.id), [1, 2]);
      final result = await c.setActive(c.reasons.first, false);
      expect(result.isSuccess, isFalse);
      expect(c.isReadOnly.value, isTrue);
    });

    test('form posts name and requires_note', () async {
      env.adapter.reply(
        'POST',
        '/loss-reasons',
        wrap(reasonJson(id: 3, label: 'Projet reporté')),
        status: 201,
      );
      final form = Get.put(
        LossReasonFormController(repository: env.lossReasons),
      );
      form.label.text = 'Projet reporté';
      form.requiresDetails.value = true;
      expect(await form.submit(), isNotNull);
      expect(env.adapter.lastTo('POST', '/loss-reasons').json, {
        'name': 'Projet reporté',
        'requires_note': true,
        'is_active': true,
      });
    });
  });

  group('ProductsController', () {
    test(
      'lists all products, filters locally and toggles activation',
      () async {
        env.adapter.reply(
          'PATCH',
          '/products/2',
          wrap(productJson(id: 2, name: 'Paie', isActive: false)),
        );
        final c = Get.put(ProductsController(repository: env.products));
        await settle();
        // No is_active filter: the API then returns inactive products too.
        expect(
          env.adapter.lastTo('GET', '/products').query.containsKey('is_active'),
          isFalse,
        );
        c.search.value = 'pai';
        expect(c.visibleProducts.map((p) => p.name), ['Paie']);
        final result = await c.setActive(c.products.last, false);
        expect(result.isSuccess, isTrue);
        expect(env.adapter.lastTo('PATCH', '/products/2').json, {
          'is_active': false,
        });
      },
    );

    test('product name is required', () async {
      final form = Get.put(ProductFormController(repository: env.products));
      form.name.text = '';
      expect(await form.submit(), isNull);
      expect(env.adapter.requestsTo('POST', '/products'), isEmpty);
    });
  });

  group('PipelineController', () {
    test('builds one column per active stage (or inactive with prospects) and loads each', () async {
      env.adapter.on('GET', '/prospects', (r) {
        final stageId = int.parse(r.query['sales_stage_id']!);
        return MockResponse(
          200,
          paginated([
            prospectJson(
              id: stageId * 10,
              stage: stageJson(id: stageId),
            ),
          ], total: 1),
        );
      });
      final c = Get.put(
        PipelineController(
          prospectsRepository: env.prospects,
          stagesRepository: env.stages,
        ),
      );
      await settle();
      // inactiveStage has prospects_count 3 → still shown.
      expect(c.columns.map((col) => col.stage.id), [1, 2, 5, 6, 9]);
      expect(c.columnFor(2)!.items.single.id, 20);
      expect(c.totalProspects, 5);
      expect(
        c.canDrop(c.columnFor(1)!.items.single, c.columnFor(1)!.stage),
        isFalse,
      );
      expect(
        c.canDrop(c.columnFor(1)!.items.single, c.columnFor(9)!.stage),
        isFalse,
      );
      expect(
        c.canDrop(c.columnFor(1)!.items.single, c.columnFor(6)!.stage),
        isTrue,
      );

      final before = env.adapter.requestsTo('GET', '/prospects').length;
      await c.onMoved(
        fromStageId: 1,
        updated: Prospect.fromJson(prospectJson(stage: lostStage)),
      );
      // Only the two affected columns are reloaded after the API confirmed.
      expect(env.adapter.requestsTo('GET', '/prospects').length - before, 2);
    });
  });

  group('DashboardController', () {
    test('loads the summary from the API and reports failures', () async {
      env.adapter.reply(
        'GET',
        '/dashboard',
        wrap({
          'prospects': {'total': 3, 'open': 1, 'won': 1, 'lost': 1},
          'prospects_by_stage': [
            {
              'sales_stage_id': 1,
              'name': 'Nouveau',
              'color': '#3B82F6',
              'stage_type': 'open',
              'sort_order': 1,
              'is_active': true,
              'count': 1,
            },
          ],
          'lost_by_reason': [],
          'this_month': {
            'month': '2026-11',
            'won': 0,
            'lost': 0,
            'new_prospects': 3,
          },
          'follow_ups': {
            'today': 0,
            'overdue': 1,
            'upcoming': 0,
            'upcoming_window_days': 7,
          },
          'recent_activities': [],
          'generated_at': '2026-11-01T10:00:00+01:00',
        }),
      );
      final repo = DashboardRepositoryImpl(DashboardRemoteDataSource(env.api));
      final c = Get.put(DashboardController(repository: repo));
      await settle();
      expect(c.summary.value!.totalProspects, 3);
      expect(c.summary.value!.stages.single.prospectsCount, 1);
      expect(c.lastUpdatedAt.value, isNotNull);

      env.adapter.fail('GET', '/dashboard', DioExceptionType.connectionError);
      await c.load();
      expect(c.state.hasError, isTrue);
      // Previous figures stay visible (flagged as possibly outdated).
      expect(c.summary.value, isNotNull);
    });
  });

  group('ConnectionSettingsController', () {
    test('tests the typed address and saves it normalized', () async {
      final settings = AppSettingsService(InMemoryStore());
      final c = Get.put(
        ConnectionSettingsController(
          settings: settings,
          networkInfo: NetworkInfo(httpClientAdapter: env.adapter),
        ),
      );
      expect(c.isFirstLaunch, isTrue);
      env.adapter.reply(
        'GET',
        '/health',
        wrap({'status': 'ok', 'database': 'ok', 'api_version': 'v1'}),
      );

      c.baseUrl.text = '10.0.0.5:8000/api/v1/';
      expect(await c.testConnection(), isTrue);
      expect(c.testStatus.value, ConnectionTestStatus.success);

      expect(await c.save(), ConnectionSaveResult.savedOnline);
      expect(settings.apiBaseUrl.value, 'http://10.0.0.5:8000/api/v1');
      expect(settings.isConfigured, isTrue);
    });

    test('unreachable server shows the error message', () async {
      env.adapter.fail('GET', '/health', DioExceptionType.connectionError);
      final c = Get.put(
        ConnectionSettingsController(
          settings: AppSettingsService(InMemoryStore()),
          networkInfo: NetworkInfo(httpClientAdapter: env.adapter),
        ),
      );
      c.baseUrl.text = 'http://10.0.0.99:8000/api/v1';
      expect(await c.testConnection(), isFalse);
      expect(c.testStatus.value, ConnectionTestStatus.failure);
      expect(c.testMessage.value, contains('10.0.0.99'));
    });
  });
}
