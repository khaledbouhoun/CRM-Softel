import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/core/network/api_exceptions.dart';
import 'package:softel_crm/features/activities/data/models/activity_type.dart';
import 'package:softel_crm/features/activities/data/models/activity.dart';
import 'package:softel_crm/features/follow_ups/data/models/follow_up.dart';
import 'package:softel_crm/features/products/data/models/product.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_filter.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_requests.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_env.dart';

void main() {
  late TestEnv env;

  setUp(() => env = TestEnv());

  group('ProspectsRepository', () {
    test(
      'getProspects sends filters as query parameters and parses the page',
      () async {
        env.adapter.reply(
          'GET',
          '/prospects',
          paginated([prospectJson()], total: 1),
        );
        final page = await env.prospects.getProspects(
          const ProspectFilter(
            search: 'exemple',
            stageId: 2,
            productId: 1,
            page: 1,
          ),
        );
        expect(page.items.single.companyName, 'SARL Exemple');
        expect(page.total, 1);
        final query = env.adapter.lastTo('GET', '/prospects').query;
        expect(query['search'], 'exemple');
        expect(query['sales_stage_id'], '2');
        expect(query['product_id'], '1');
        expect(query['sort'], 'created_at');
        expect(query['direction'], 'desc');
        expect(query.containsKey('loss_reason_id'), isFalse);
      },
    );

    test(
      'createProspect posts the payload including product associations',
      () async {
        env.adapter.reply(
          'POST',
          '/prospects',
          wrap(prospectJson(id: 77)),
          status: 201,
        );
        final created = await env.prospects.createProspect(
          const ProspectPayload(
            companyName: 'Nouveau',
            contactName: 'Brahim',
            salesStageId: 1,
            productIds: [1, 2],
          ),
        );
        expect(created.id, 77);
        final body = env.adapter.lastTo('POST', '/prospects').json;
        expect(body['name'], 'Nouveau');
        expect(body['contact_person'], 'Brahim');
        expect(body['sales_stage_id'], 1);
        expect(body['product_ids'], [1, 2]);
      },
    );

    test(
      'a rejected field is reported even when the form has no input for it',
      () async {
        env.adapter.reply(
          'POST',
          '/prospects',
          validationError({
            'name': ['The name field is required.'],
          }),
          status: 422,
        );
        try {
          await env.prospects.createProspect(
            const ProspectPayload(companyName: 'X'),
          );
          fail('expected a ValidationException');
        } on ValidationException catch (e) {
          expect(e.message, 'Certaines données sont invalides.');
          expect(e.errorFor('name'), 'The name field is required.');
          expect(e.messagesOutside({'name'}), isEmpty);
          expect(
            e.describeFor({'email'}),
            'Certaines données sont invalides.\nThe name field is required.',
          );
        }
      },
    );

    test('updateProspect uses PUT without the stage', () async {
      env.adapter.reply('PUT', '/prospects/42', wrap(prospectJson()));
      await env.prospects.updateProspect(
        42,
        const ProspectPayload(
          companyName: 'X',
          salesStageId: 9,
          productIds: [3],
        ),
      );
      final body = env.adapter.lastTo('PUT', '/prospects/42').json;
      expect(body.containsKey('sales_stage_id'), isFalse);
      expect(body['product_ids'], [3]);
    });

    test(
      'updateProducts sends only product_ids, de-duplicated and sorted',
      () async {
        env.adapter.reply(
          'PUT',
          '/prospects/42',
          wrap(
            prospectJson(products: [productJson(id: 1), productJson(id: 3)]),
          ),
        );
        final updated = await env.prospects.updateProducts(42, [3, 1, 3]);
        expect(env.adapter.lastTo('PUT', '/prospects/42').json, {
          'product_ids': [1, 3],
        });
        expect(updated.products.map((p) => p.id), [1, 3]);
      },
    );

    test(
      'changeStage posts to change-stage and returns the updated prospect',
      () async {
        env.adapter.reply(
          'POST',
          '/prospects/42/change-stage',
          stageChanged(
            prospectJson(
              stage: lostStage,
              lossReason: competitor,
              lossDetails: 'X',
            ),
          ),
        );
        final updated = await env.prospects.changeStage(
          42,
          const StageTransitionRequest(
            stageId: 6,
            lossReasonId: 2,
            lossDetails: 'X',
          ),
        );
        expect(updated.isLost, isTrue);
        expect(updated.lossDetails, 'X');
        expect(env.adapter.lastTo('POST', '/prospects/42/change-stage').json, {
          'sales_stage_id': 6,
          'loss_reason_id': 2,
          'loss_note': 'X',
        });
      },
    );

    test('stage history is returned newest first', () async {
      env.adapter.reply(
        'GET',
        '/prospects/42/stage-history',
        paginated([
          {
            'id': 1,
            'from_stage': null,
            'to_stage': openStage,
            'changed_at': '2026-09-01T09:00:00+01:00',
          },
          {
            'id': 2,
            'from_stage': openStage,
            'to_stage': demoStage,
            'changed_at': '2026-10-01T09:00:00+01:00',
          },
        ]),
      );
      final history = await env.prospects.getStageHistory(42);
      expect(history.map((h) => h.id), [2, 1]);
      expect(
        env.adapter
            .lastTo('GET', '/prospects/42/stage-history')
            .query['per_page'],
        '100',
      );
    });

    test('server errors propagate as ApiException', () async {
      env.adapter.reply('GET', '/prospects/1', {
        'success': false,
        'message': 'Prospect not found.',
        'error_code': 'NOT_FOUND',
        'errors': null,
      }, status: 404);
      expect(
        () => env.prospects.getProspect(1),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('Activities & follow-ups repositories', () {
    test('activities filter by prospect, type and dates', () async {
      env.adapter.reply('GET', '/activities', paginated([activityJson()]));
      await env.activities.getActivities(
        ActivityFilter(
          prospectId: 42,
          type: ActivityType.meeting,
          dateFrom: DateTime(2026, 10, 1),
          dateTo: DateTime(2026, 10, 31),
        ),
      );
      final q = env.adapter.lastTo('GET', '/activities').query;
      expect(q['prospect_id'], '42');
      expect(q['type'], 'meeting');
      expect(q['date_from'], '2026-10-01');
      expect(q['date_to'], '2026-10-31');
    });

    test('an activity is created under its prospect', () async {
      env.adapter.reply(
        'POST',
        '/activities',
        wrap(activityJson(id: 12)),
        status: 201,
      );
      final created = await env.activities.createActivity(
        ActivityPayload(
          prospectId: 42,
          type: ActivityType.other,
          occurredAt: DateTime(2026, 10, 30),
          description: 'Note',
        ),
      );
      expect(created.id, 12);
      final sent = env.adapter.lastTo('POST', '/activities').json;
      expect(sent['type'], 'other');
      expect(sent['prospect_id'], 42);
    });

    test(
      'follow-ups are requested by scope; a prospect uses its own route',
      () async {
        env.adapter
          ..reply('GET', '/follow-ups', paginated([followUpJson()]))
          ..reply(
            'GET',
            '/prospects/42/follow-ups',
            paginated([followUpJson()]),
          );
        final page = await env.followUps.getFollowUps(
          view: FollowUpView.overdue,
          perPage: 10,
        );
        expect(page.items.single.id, 4);
        final q = env.adapter.lastTo('GET', '/follow-ups').query;
        expect(q['scope'], 'overdue');
        expect(q['per_page'], '10');

        await env.followUps.getFollowUps(prospectId: 42);
        expect(
          env.adapter.requestsTo('GET', '/prospects/42/follow-ups'),
          hasLength(1),
        );
      },
    );

    test('completion records the activity in ONE request; cancel posts the closing note', () async {
      env.adapter
        ..reply(
          'POST',
          '/follow-ups/4/complete',
          wrap(followUpJson(status: 'completed', activityId: 30)),
        )
        ..reply(
          'POST',
          '/follow-ups/4/cancel',
          wrap(followUpJson(status: 'cancelled')),
        );

      final done = await env.followUps.completeFollowUp(
        4,
        CompleteFollowUpRequest(
          recordActivity: true,
          description: 'Rappelé',
          occurredAt: DateTime(2026, 11, 5, 9),
        ),
      );
      expect(done.followUp.status, FollowUpStatus.completed);
      expect(done.activityRecorded, isTrue);
      final sent = env.adapter.lastTo('POST', '/follow-ups/4/complete').json;
      expect(sent['create_activity'], isTrue);
      expect(sent['activity_description'], 'Rappelé');
      // No separate activity request (the server does it atomically).
      expect(
        env.adapter.requestsTo('POST', '/prospects/42/activities'),
        isEmpty,
      );
      expect(env.adapter.requestsTo('POST', '/activities'), isEmpty);

      final cancelled = await env.followUps.cancelFollowUp(
        4,
        reason: '  Client injoignable ',
      );
      expect(cancelled.status, FollowUpStatus.cancelled);
      expect(env.adapter.lastTo('POST', '/follow-ups/4/cancel').json, {
        'closing_note': 'Client injoignable',
      });
    });
  });

  group('Reference data repositories', () {
    test(
      'stages are sorted by sort_order; the full list is requested',
      () async {
        env.stubReferenceData();
        final stages = await env.stages.getStages(includeInactive: true);
        expect(stages.map((s) => s.id), [1, 2, 5, 6, 9]);
        expect(
          env.adapter
              .lastTo('GET', '/sales-stages')
              .query
              .containsKey('is_active'),
          isFalse,
        );

        await env.stages.getStages();
        expect(
          env.adapter.lastTo('GET', '/sales-stages').query['is_active'],
          '1',
        );
      },
    );

    test('reorder posts the new order', () async {
      env.adapter.reply(
        'POST',
        '/sales-stages/reorder',
        wrap([demoStage, openStage]),
      );
      await env.stages.reorderStages([2, 1]);
      expect(env.adapter.lastTo('POST', '/sales-stages/reorder').json, {
        'ids': [2, 1],
      });
    });

    test('activation uses PATCH with is_active only', () async {
      env.adapter
        ..reply('PATCH', '/products/1', wrap(productJson(isActive: false)))
        ..reply(
          'PATCH',
          '/loss-reasons/2',
          wrap(reasonJson(id: 2, isActive: false)),
        );
      final product = await env.products.setProductActive(1, false);
      expect(product.isActive, isFalse);
      expect(env.adapter.lastTo('PATCH', '/products/1').json, {
        'is_active': false,
      });
      await env.lossReasons.setLossReasonActive(2, false);
      expect(env.adapter.lastTo('PATCH', '/loss-reasons/2').json, {
        'is_active': false,
      });
    });

    test('products are sorted by name', () async {
      env.adapter.reply(
        'GET',
        '/products',
        wrap([
          productJson(id: 2, name: 'Paie'),
          productJson(id: 1, name: 'GestCom'),
        ]),
      );
      final products = await env.products.getProducts();
      expect(products.map((p) => p.name), ['GestCom', 'Paie']);
    });

    test('create product posts the payload', () async {
      env.adapter.reply(
        'POST',
        '/products',
        wrap(productJson(id: 8, name: 'CRM')),
        status: 201,
      );
      final created = await env.products.createProduct(
        const ProductPayload(name: 'CRM'),
      );
      expect(created.id, 8);
      expect(env.adapter.lastTo('POST', '/products').json['name'], 'CRM');
    });
  });
}
