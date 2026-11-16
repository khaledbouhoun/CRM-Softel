import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/core/state/load_state.dart';
import 'package:softel_crm/features/prospects/data/models/prospect.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_filter.dart';
import 'package:softel_crm/features/prospects/presentation/controllers/prospect_details_controller.dart';
import 'package:softel_crm/features/prospects/presentation/controllers/prospect_form_controller.dart';
import 'package:softel_crm/features/prospects/presentation/controllers/prospect_products_controller.dart';
import 'package:softel_crm/features/prospects/presentation/controllers/prospects_list_controller.dart';

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

  group('ProspectsListController', () {
    Future<ProspectsListController> build([
      ProspectFilter filter = const ProspectFilter(),
    ]) async {
      final c = Get.put(
        ProspectsListController(
          repository: env.prospects,
          lookups: env.lookups,
          initialFilter: filter,
        ),
      );
      await settle();
      return c;
    }

    test('loads the first page and the filter lookups on init', () async {
      env.adapter.reply(
        'GET',
        '/prospects',
        paginated([prospectJson()], total: 1),
      );
      final c = await build();
      expect(c.state.status.value, LoadStatus.success);
      expect(c.page.value.items.single.id, 42);
      expect(env.lookups.isLoaded.value, isTrue);
      expect(c.hasLostStages, isTrue);
    });

    test('initial filter from route parameters is applied', () async {
      env.adapter.reply('GET', '/prospects', paginated([]));
      await build(const ProspectFilter(stageId: 6, search: 'sarl'));
      final q = env.adapter.lastTo('GET', '/prospects').query;
      expect(q['sales_stage_id'], '6');
      expect(q['search'], 'sarl');
    });

    test('filters reset to page 1 and are sent to the server', () async {
      env.adapter.reply(
        'GET',
        '/prospects',
        paginated([prospectJson()], page: 3, lastPage: 3, total: 51),
      );
      final c = await build(const ProspectFilter(page: 3));
      c.setStage(2);
      await settle();
      var q = env.adapter.lastTo('GET', '/prospects').query;
      expect(q['sales_stage_id'], '2');
      expect(q['page'], '1');

      c.setLossReason(1);
      c.setCreatedRange(DateTime(2026, 1, 1), DateTime(2026, 6, 30));
      await settle();
      q = env.adapter.lastTo('GET', '/prospects').query;
      expect(q['loss_reason_id'], '1');
      expect(q['created_from'], '2026-01-01');
      expect(q['created_to'], '2026-06-30');

      c.clearFilters();
      await settle();
      q = env.adapter.lastTo('GET', '/prospects').query;
      expect(q.containsKey('sales_stage_id'), isFalse);
      expect(q.containsKey('loss_reason_id'), isFalse);
    });

    test('sorting the same column toggles the direction', () async {
      env.adapter.reply('GET', '/prospects', paginated([]));
      final c = await build();
      c.sortBy(ProspectSort.companyName);
      expect(c.filter.value.ascending, isTrue);
      c.sortBy(ProspectSort.companyName);
      expect(c.filter.value.ascending, isFalse);
      await settle();
      expect(env.adapter.lastTo('GET', '/prospects').query['sort'], 'name');
    });

    test(
      'connection failure puts the list in a connection error state',
      () async {
        env.adapter.fail('GET', '/prospects', DioExceptionType.connectionError);
        final c = await build();
        expect(c.state.hasError, isTrue);
        expect(c.state.isConnectionError, isTrue);
        expect(c.page.value.isEmpty, isTrue);
      },
    );
  });

  group('ProspectFormController', () {
    Future<ProspectFormController> build({Prospect? initial}) async {
      final c = Get.put(
        ProspectFormController(
          repository: env.prospects,
          lookups: env.lookups,
          initial: initial,
        ),
      );
      await settle();
      return c;
    }

    test('defaults the initial stage to the first active open stage', () async {
      final c = await build();
      expect(c.selectedStage.value?.id, 1);
    });

    test('invalid fields block submission without any request', () async {
      final c = await build();
      c.companyName.text = '   ';
      c.email.text = 'pas-un-email';
      c.phone.text = '12';
      final saved = await c.submit();
      expect(saved, isNull);
      final errors = c.validateAll();
      expect(errors.keys, containsAll(['name', 'email', 'phone']));
      expect(c.errorMessage.value, isNotNull);
      expect(env.adapter.requestsTo('POST', '/prospects'), isEmpty);
    });

    test(
      'creation sends stage and selected products, returns the API result',
      () async {
        env.adapter.reply(
          'POST',
          '/prospects',
          wrap(prospectJson(id: 100, companyName: 'Nouvelle SARL')),
          status: 201,
        );
        final c = await build();
        c.companyName.text = 'Nouvelle SARL';
        c.email.text = 'info@nouvelle.dz';
        c
          ..toggleProduct(2, true)
          ..toggleProduct(1, true)
          ..toggleProduct(2, false)
          ..toggleProduct(2, true);
        final saved = await c.submit();
        expect(saved?.id, 100);
        final body = env.adapter.lastTo('POST', '/prospects').json;
        expect(body['name'], 'Nouvelle SARL');
        expect(body['sales_stage_id'], 1);
        expect(body['product_ids'], [1, 2]);
        expect(body['phone'], isNull);
      },
    );

    test(
      'editing keeps the stage out of the payload and updates products',
      () async {
        env.adapter.reply(
          'PUT',
          '/prospects/42',
          wrap(prospectJson(products: [])),
        );
        final c = await build(initial: Prospect.fromJson(prospectJson()));
        expect(c.isEdit, isTrue);
        expect(c.selectedProductIds, {1});
        c
          ..toggleProduct(1, false)
          ..toggleProduct(2, true);
        c.city.text = 'Oran';
        final saved = await c.submit();
        expect(saved, isNotNull);
        final body = env.adapter.lastTo('PUT', '/prospects/42').json;
        expect(body.containsKey('sales_stage_id'), isFalse);
        expect(body['product_ids'], [2]);
        expect(body['city'], 'Oran');
      },
    );

    test('server validation errors are mapped onto fields', () async {
      env.adapter.reply(
        'POST',
        '/prospects',
        validationError({
          'email': ['Cet e-mail existe déjà.'],
          'product_ids.0': ['Produit inactif.'],
        }),
        status: 422,
      );
      final c = await build();
      c.companyName.text = 'Doublon';
      c.email.text = 'doublon@x.dz';
      expect(await c.submit(), isNull);
      expect(c.validateEmail(c.email.text), 'Cet e-mail existe déjà.');
      expect(c.productsError, 'Produit inactif.');
      c.clearServerError('email');
      expect(c.validateEmail(c.email.text), isNull);
    });

    test(
      'network failure reports an error and does not claim success',
      () async {
        env.adapter.fail(
          'POST',
          '/prospects',
          DioExceptionType.connectionError,
        );
        final c = await build();
        c.companyName.text = 'X';
        expect(await c.submit(), isNull);
        expect(c.errorMessage.value, contains('Impossible de joindre'));
        expect(c.isSubmitting.value, isFalse);
      },
    );
  });

  group('ProspectProductsController', () {
    test('syncs the product association with a partial PUT', () async {
      env.adapter.reply(
        'PUT',
        '/prospects/42',
        wrap(prospectJson(products: [productJson(id: 2)])),
      );
      final c = Get.put(
        ProspectProductsController(
          repository: env.prospects,
          lookups: env.lookups,
          prospect: Prospect.fromJson(prospectJson()),
        ),
      );
      await settle();
      expect(c.hasChanges, isFalse);
      c
        ..toggle(1, false)
        ..toggle(2, true);
      expect(c.hasChanges, isTrue);
      final updated = await c.submit();
      expect(updated!.products.single.id, 2);
      expect(env.adapter.lastTo('PUT', '/prospects/42').json, {
        'product_ids': [2],
      });
    });
  });

  group('ProspectDetailsController', () {
    test(
      'loads prospect, activities, follow-ups and history independently',
      () async {
        env.adapter
          ..reply('GET', '/prospects/42', wrap(prospectJson()))
          ..reply(
            'GET',
            '/activities',
            paginated([activityJson(id: 2), activityJson(id: 1)]),
          )
          ..reply(
            'GET',
            '/prospects/42/follow-ups',
            paginated([
              followUpJson(id: 1, status: 'completed'),
              followUpJson(id: 2, dueAt: '2026-12-01T09:00:00Z'),
              followUpJson(id: 3, dueAt: '2026-11-10T09:00:00Z'),
            ]),
          )
          ..reply('GET', '/prospects/42/stage-history', {
            'message': 'boom',
          }, status: 500);

        final c = Get.put(
          ProspectDetailsController(
            prospectId: 42,
            prospectsRepository: env.prospects,
            activitiesRepository: env.activities,
            followUpsRepository: env.followUps,
          ),
        );
        await settle();

        expect(c.prospect.value?.companyName, 'SARL Exemple');
        expect(c.activities.map((a) => a.id), [2, 1]);
        expect(c.pendingFollowUps.map((f) => f.id), [3, 2]);
        expect(c.closedFollowUps.map((f) => f.id), [1]);
        // One failing section does not break the others.
        expect(c.historyState.hasError, isTrue);
        expect(c.prospectState.isSuccess, isTrue);
        expect(
          env.adapter.lastTo('GET', '/activities').query['prospect_id'],
          '42',
        );
        expect(
          env.adapter.requestsTo('GET', '/prospects/42/follow-ups'),
          hasLength(1),
        );
      },
    );
  });
}
