import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/features/activities/data/models/activity.dart';
import 'package:softel_crm/features/activities/data/models/activity_type.dart';
import 'package:softel_crm/features/dashboard/data/models/dashboard_summary.dart';
import 'package:softel_crm/features/follow_ups/data/models/follow_up.dart';
import 'package:softel_crm/features/products/data/models/product.dart';
import 'package:softel_crm/features/prospects/data/models/prospect.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_filter.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_requests.dart';
import 'package:softel_crm/features/prospects/data/models/stage_history_entry.dart';
import 'package:softel_crm/features/settings/data/models/loss_reason.dart';
import 'package:softel_crm/features/settings/data/models/sales_stage.dart';

import '../helpers/fixtures.dart';

void main() {
  group('SalesStage', () {
    test('parses stage_type from the API, never from the name', () {
      final stage = SalesStage.fromJson(
        stageJson(name: 'Perdu (ancien)', type: 'open'),
      );
      expect(stage.isLost, isFalse);
      final lost = SalesStage.fromJson(
        stageJson(name: 'Signé ?', type: 'lost'),
      );
      expect(lost.isLost, isTrue);
      expect(lost.type.isTerminal, isTrue);
      expect(lost.position, 1);
    });

    test('tolerates 0/1 booleans; usage comes from prospects_count', () {
      final json = stageJson(prospectsCount: 0)..['is_active'] = 0;
      final stage = SalesStage.fromJson(json);
      expect(stage.isActive, isFalse);
      expect(stage.isUsed, isFalse);
      // Without a count (embedded stage), assume used so deletion stays blocked.
      final embedded = SalesStage.fromJson(stageJson(prospectsCount: null));
      expect(embedded.isUsed, isTrue);
    });

    test('round-trips through toJson', () {
      final stage = SalesStage.fromJson(wonStage);
      expect(SalesStage.fromJson(stage.toJson()).toJson(), stage.toJson());
    });

    test('payload', () {
      const payload = SalesStagePayload(
        name: '  Démo ',
        colorHex: '#aabbcc',
        type: StageType.lost,
        isActive: false,
      );
      expect(payload.toJson(), {
        'name': 'Démo',
        'color': '#AABBCC',
        'stage_type': 'lost',
        'is_active': false,
      });
    });
  });

  group('LossReason & Product', () {
    test('LossReason parses name, requires_note and sort_order', () {
      final reason = LossReason.fromJson(competitor);
      expect(reason.requiresDetails, isTrue);
      expect(reason.label, 'Concurrent choisi');
      expect(reason.position, 2);
      expect(
        const LossReasonPayload(
          label: ' Autre ',
          requiresDetails: true,
          isActive: true,
        ).toJson(),
        {'name': 'Autre', 'requires_note': true, 'is_active': true},
      );
    });

    test('Product payload trims and nulls empty description', () {
      final product = Product.fromJson(productJson());
      expect(product.prospectsCount, 4);
      expect(
        const ProductPayload(name: ' GestCom ', description: '  ').toJson(),
        {
          'name': 'GestCom',
          'description': null,
          'is_active': true,
          'pack_id': null,
          'demo_url': null,
          'is_active_on_web': false,
        },
      );
    });
  });

  group('Prospect', () {
    test('parses nested stage, products, loss info and activity dates', () {
      final p = Prospect.fromJson(
        prospectJson(
          stage: lostStage,
          products: [
            productJson(id: 1),
            productJson(id: 2, name: 'Paie'),
          ],
          lossReason: competitor,
          lossDetails: 'Concurrent X',
        ),
      );
      expect(p.companyName, 'SARL Exemple');
      expect(p.contactName, 'M. Benali');
      expect(p.isLost, isTrue);
      expect(p.products.map((x) => x.id), [1, 2]);
      expect(p.lossReason!.label, 'Concurrent choisi');
      expect(p.lossDetails, 'Concurrent X');
      expect(p.lastActivityAt, DateTime.utc(2026, 10, 30, 10, 15).toLocal());
      expect(p.nextFollowUpAt, DateTime.utc(2026, 11, 5, 9).toLocal());
      expect(p.activitiesCount, 3);
      expect(p.pendingFollowUpsCount, 1);
      expect(p.toRef().id, 42);
    });

    test('next follow-up is overdue only when scheduled before today', () {
      final p = Prospect.fromJson(prospectJson());
      expect(
        p.isNextFollowUpOverdue(DateTime(2026, 11, 5, 18)),
        isFalse,
      ); // same day
      expect(p.isNextFollowUpOverdue(DateTime(2026, 11, 6, 8)), isTrue);
    });

    test('round-trips through toJson', () {
      final p = Prospect.fromJson(prospectJson(stage: wonStage));
      final again = Prospect.fromJson(p.toJson());
      expect(again.isWon, isTrue);
      expect(again.products.single.name, 'GestCom');
      expect(again.createdAt, p.createdAt);
      expect(again.nextFollowUpAt, p.nextFollowUpAt);
    });

    test('create payload includes the stage; update payload does not', () {
      const payload = ProspectPayload(
        companyName: ' SARL Test ',
        contactName: '',
        email: 'a@b.dz',
        salesStageId: 1,
        productIds: [2, 1],
      );
      final create = payload.toJson(isCreate: true);
      expect(create['name'], 'SARL Test');
      expect(create['contact_person'], isNull);
      expect(create.containsKey('company_name'), isFalse);
      expect(create['sales_stage_id'], 1);
      expect(create['product_ids'], [2, 1]);
      final update = payload.toJson(isCreate: false);
      expect(update.containsKey('sales_stage_id'), isFalse);
      expect(update['product_ids'], [2, 1]);
    });

    test('filter query uses the API names and can clear nullable filters', () {
      final filter = ProspectFilter(
        search: ' ben ',
        stageId: 2,
        productId: 3,
        createdFrom: DateTime(2026, 1, 1),
        createdTo: DateTime(2026, 1, 31),
        sort: ProspectSort.companyName,
        ascending: true,
        page: 2,
      );
      expect(filter.toQuery(), {
        'search': 'ben',
        'sales_stage_id': 2,
        'product_id': 3,
        'loss_reason_id': null,
        'source': null,
        'business_activity': null,
        'previous_software': null,
        'created_from': '2026-01-01',
        'created_to': '2026-01-31',
        'sort': 'name',
        'direction': 'asc',
        'page': 2,
        'per_page': 25,
      });
      final cleared = filter.copyWith(stageId: null, page: 1);
      expect(cleared.stageId, isNull);
      expect(cleared.productId, 3);
      expect(const ProspectFilter().hasActiveFilters, isFalse);
      expect(filter.hasActiveFilters, isTrue);
      // Only the columns the API can sort on.
      expect(ProspectSort.values.map((s) => s.apiValue), [
        'name',
        'city',
        'created_at',
        'updated_at',
      ]);
    });

    test('stage history entry', () {
      final entry = StageHistoryEntry.fromJson({
        'id': 1,
        'from_stage_id': 1,
        'from_stage': openStage,
        'to_stage_id': 6,
        'to_stage': lostStage,
        'loss_reason_id': 1,
        'loss_reason': tooExpensive,
        'loss_note': 'Budget gelé',
        'changed_at': '2026-10-20T10:00:00+01:00',
      });
      expect(entry.fromStage!.id, 1);
      expect(entry.toStage!.isLost, isTrue);
      expect(entry.lossReason!.id, 1);
      expect(entry.lossDetails, 'Budget gelé');
    });

    test('stage transition request sends loss_note, only for a lost stage', () {
      final lost = SalesStage.fromJson(lostStage);
      final reason = LossReason.fromJson(competitor);
      expect(
        StageTransitionRules.build(
          target: lost,
          lossReason: reason,
          lossDetails: ' Concurrent X ',
        ).toJson(),
        {'sales_stage_id': 6, 'loss_reason_id': 2, 'loss_note': 'Concurrent X'},
      );
    });
  });

  group('Activity & FollowUp', () {
    test('Activity parses and serializes payload with offset dates', () {
      final a = Activity.fromJson(activityJson(type: 'meeting'));
      expect(a.type, ActivityType.meeting);
      expect(a.prospect!.companyName, 'SARL Exemple');
      expect(a.occurredAt, DateTime.utc(2026, 10, 30, 10, 15).toLocal());
      expect(ActivityType.fromApi('unknown'), ActivityType.other);

      final payload = ActivityPayload(
        prospectId: 42,
        type: ActivityType.call,
        occurredAt: DateTime(2026, 10, 30, 10, 15),
        description: ' Appel ',
        outcome: '',
      ).toJson();
      expect(payload.containsKey('prospect_id'), isFalse); // in the URL
      expect(payload['type'], 'call');
      expect(payload['description'], 'Appel');
      expect(payload['outcome'], isNull);
      expect(payload['activity_at'], startsWith('2026-10-30T10:15:00'));
    });

    test('FollowUp reads scheduled_at, title and the server due_state', () {
      final upcoming = FollowUp.fromJson(followUpJson());
      expect(upcoming.dueAt, DateTime.utc(2026, 11, 5, 9).toLocal());
      expect(upcoming.description, 'Rappeler pour la validation'); // from title
      expect(upcoming.isOverdue(), isFalse);

      final serverSaysOverdue = FollowUp.fromJson(
        followUpJson(dueAt: '2099-01-01T00:00:00Z', dueState: 'overdue'),
      );
      expect(serverSaysOverdue.isOverdue(), isTrue);
      final computed = FollowUp.fromJson(
        followUpJson(dueAt: '2020-01-01T00:00:00Z', dueState: null),
      );
      expect(computed.isOverdue(), isTrue);
      final completed = FollowUp.fromJson(
        followUpJson(
          status: 'completed',
          dueAt: '2020-01-01T00:00:00Z',
          closingNote: 'OK',
        ),
      );
      expect(completed.isOverdue(), isFalse);
      expect(completed.status, FollowUpStatus.completed);
      expect(completed.closingNote, 'OK');

      final withDescription = FollowUp.fromJson(
        followUpJson()..['description'] = 'Texte complet',
      );
      expect(withDescription.description, 'Texte complet');
    });

    test('views map to the API scope / status filters', () {
      expect(FollowUpView.overdue.toQuery(), {'scope': 'overdue'});
      expect(FollowUpView.today.toQuery(), {'scope': 'today'});
      expect(FollowUpView.completed.toQuery()['status'], 'completed');
      expect(FollowUpView.cancelled.toQuery()['status'], 'cancelled');
    });

    test('Complete request asks the server to record the activity in the same call', () {
      final request = CompleteFollowUpRequest(
        recordActivity: true,
        description: 'Rappel effectué',
        outcome: 'OK',
        occurredAt: DateTime(2026, 11, 5, 9, 30),
      ).toJson();
      expect(request['create_activity'], isTrue);
      expect(request['activity_description'], 'Rappel effectué');
      expect(request['activity_outcome'], 'OK');
      expect(request['closing_note'], 'OK');
      expect(request['activity_at'], startsWith('2026-11-05T09:30:00'));
      // A type is only sent when the form provides one.
      expect(request.containsKey('activity_type'), isFalse);
      expect(const CompleteFollowUpRequest().toJson(), isEmpty);
      expect(
        const CompleteFollowUpRequest(
          recordActivity: true,
          type: ActivityType.message,
        ).toJson()['activity_type'],
        'message',
      );
    });

    test('FollowUp reads its activity type and converted activity; legacy rows have none', () {
      final typed = FollowUp.fromJson(
        followUpJson(activityType: 'appointment', activityId: 7),
      );
      expect(typed.activityType, ActivityType.meeting);
      expect(typed.activityId, 7);
      final legacy = FollowUp.fromJson(followUpJson(activityType: null));
      expect(legacy.activityType, isNull);
      expect(legacy.activityId, isNull);
      final payload = FollowUpPayload(
        prospectId: 42,
        dueAt: DateTime(2026, 11, 5, 9),
        description: 'Visite',
        activityType: ActivityType.meeting,
      ).toJson();
      expect(payload['activity_type'], 'meeting');
    });
  });

  test(
    'DashboardSummary parses figures, orders stages and computes win rate',
    () {
      final s = DashboardSummary.fromJson({
        'prospects': {'total': 120, 'open': 85, 'won': 20, 'lost': 15},
        'prospects_by_stage': [
          {
            'sales_stage_id': 2,
            'name': 'Démo',
            'color': '#000000',
            'stage_type': 'open',
            'sort_order': 2,
            'is_active': true,
            'count': 30,
          },
          {
            'sales_stage_id': 1,
            'name': 'Nouveau',
            'color': '#111111',
            'stage_type': 'open',
            'sort_order': 1,
            'is_active': true,
            'count': 55,
          },
        ],
        'lost_by_reason': [
          {
            'loss_reason_id': 1,
            'name': 'Trop cher',
            'is_active': true,
            'count': 6,
          },
        ],
        'this_month': {
          'month': '2026-11',
          'won': 2,
          'lost': 1,
          'new_prospects': 6,
        },
        'follow_ups': {
          'today': 4,
          'overdue': 2,
          'upcoming': 17,
          'upcoming_window_days': 7,
        },
        'recent_activities': [activityJson()],
        'generated_at': '2026-11-01T10:00:00+01:00',
      });
      expect(s.totalProspects, 120);
      expect(s.openProspects, 85);
      expect(s.followUpsOverdue, 2);
      expect(s.upcomingWindowDays, 7);
      expect(s.stages.map((x) => x.id), [1, 2]);
      expect(s.stages.first.prospectsCount, 55);
      expect(s.lostByReason!.single.id, 1);
      expect(s.lostByReason!.single.count, 6);
      expect(s.recentActivities, hasLength(1));
      expect(s.winRate, closeTo(20 / 35, 0.0001));
      expect(DashboardSummary.fromJson({}).lostByReason, isNull);
    },
  );
}
