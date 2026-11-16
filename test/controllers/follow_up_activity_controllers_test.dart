import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/core/network/api_exceptions.dart';
import 'package:softel_crm/features/activities/data/models/activity_type.dart';
import 'package:softel_crm/features/activities/presentation/controllers/activity_form_controller.dart';
import 'package:softel_crm/features/follow_ups/data/models/follow_up.dart';
import 'package:softel_crm/features/follow_ups/presentation/controllers/follow_up_form_controllers.dart';
import 'package:softel_crm/features/follow_ups/presentation/controllers/follow_ups_controller.dart';
import 'package:softel_crm/features/prospects/data/models/prospect_ref.dart';

import '../helpers/fixtures.dart';
import '../helpers/mock_http_adapter.dart';
import '../helpers/test_env.dart';

void main() {
  late TestEnv env;
  // Fixed "now" so date rules are deterministic.
  DateTime now() => DateTime(2026, 11, 1, 10, 0);
  const prospect = ProspectRef(id: 42, companyName: 'SARL Exemple');

  setUp(() {
    Get.testMode = true;
    env = TestEnv();
  });

  tearDown(Get.reset);

  group('FollowUpsController', () {
    test('loads the today view and the badge counts', () async {
      env.adapter.on('GET', '/follow-ups', (r) {
        final scope = r.query['scope'];
        final total = {'today': 3, 'overdue': 2, 'upcoming': 7}[scope] ?? 0;
        return MockResponse(200, paginated([followUpJson()], total: total));
      });
      final c = Get.put(FollowUpsController(repository: env.followUps));
      await settle();
      expect(c.view.value, FollowUpView.today);
      expect(c.state.isSuccess, isTrue);
      expect(c.counts[FollowUpView.today], 3);
      expect(c.counts[FollowUpView.overdue], 2);
      expect(c.counts[FollowUpView.upcoming], 7);

      c.setView(FollowUpView.overdue);
      await settle();
      final last = env.adapter.requests.last;
      expect(last.query['scope'], 'overdue');
      expect(last.query['page'], '1');

      c.setView(FollowUpView.completed);
      await settle();
      final completed = env.adapter.requests.last.query;
      expect(completed['status'], 'completed');
      expect(completed['sort'], 'completed_at');
      expect(completed.containsKey('scope'), isFalse);
    });

    test(
      'list failure is reported; count failures only drop the badge',
      () async {
        env.adapter.fail(
          'GET',
          '/follow-ups',
          DioExceptionType.connectionError,
        );
        final c = Get.put(FollowUpsController(repository: env.followUps));
        await settle();
        expect(c.state.hasError, isTrue);
        expect(c.counts, isEmpty);
      },
    );
  });

  group('CompleteFollowUpController', () {
    CompleteFollowUpController build() => Get.put(
      CompleteFollowUpController(
        repository: env.followUps,
        followUp: FollowUp.fromJson(followUpJson()),
        clock: now,
      ),
    );

    test('completes and records the activity in one request, keeping the follow-up type', () async {
      env.adapter.reply(
        'POST',
        '/follow-ups/4/complete',
        wrap(
          followUpJson(
            status: 'completed',
            activityId: 70,
            activityType: 'appointment',
          ),
        ),
      );
      final c = Get.put(
        CompleteFollowUpController(
          repository: env.followUps,
          followUp: FollowUp.fromJson(
            followUpJson(activityType: 'appointment'),
          ),
          clock: now,
        ),
      );
      expect(c.description.text, 'Rappeler pour la validation'); // prefilled
      expect(c.type.value, ActivityType.meeting);
      c.description.text = 'Rendez-vous fait';
      c.outcome.text = 'Accord de principe';
      final done = await c.submit();
      expect(done!.followUp.status, FollowUpStatus.completed);
      expect(done.activityRecorded, isTrue);

      final sent = env.adapter.lastTo('POST', '/follow-ups/4/complete').json;
      expect(sent['create_activity'], isTrue);
      expect(sent['activity_description'], 'Rendez-vous fait');
      expect(sent['activity_outcome'], 'Accord de principe');
      expect(sent['closing_note'], 'Accord de principe');
      // An activity cannot be in the future: a follow-up due later is recorded now.
      expect(sent['activity_at'], startsWith('2026-11-01T10:00:00'));
      // The type is the follow-up's own, prefilled in the form and sent with the request.
      expect(sent['activity_type'], 'meeting');
      expect(env.adapter.requests, hasLength(1));
    });

    test('an older follow-up without a type lets the user choose the activity type', () async {
      env.adapter.reply(
        'POST',
        '/follow-ups/4/complete',
        wrap(followUpJson(status: 'completed', activityId: 71)),
      );
      final c = Get.put(
        CompleteFollowUpController(
          repository: env.followUps,
          followUp: FollowUp.fromJson(followUpJson(activityType: null)),
          clock: now,
        ),
      );
      expect(c.type.value, isNull);
      c.type.value = ActivityType.message;
      await c.submit();
      expect(
        env.adapter
            .lastTo('POST', '/follow-ups/4/complete')
            .json['activity_type'],
        'message',
      );
    });

    test('a server error while completing keeps the follow-up pending and sends nothing twice', () async {
      env.adapter.fail(
        'POST',
        '/follow-ups/4/complete',
        DioExceptionType.receiveTimeout,
      );
      final c = build();
      final done = await c.submit();
      expect(done, isNull);
      expect(c.errorMessage.value, isNotNull);
      expect(c.isSubmitting.value, isFalse);
      expect(
        env.adapter.requestsTo('POST', '/follow-ups/4/complete'),
        hasLength(1),
      );
    });

    test(
      'completing without recording an activity sends an empty body',
      () async {
        env.adapter.reply(
          'POST',
          '/follow-ups/4/complete',
          wrap(followUpJson(status: 'completed')),
        );
        final c = build();
        c.recordActivity.value = false;
        c.description.text = '';
        expect(await c.submit(), isNotNull);
        expect(
          env.adapter.lastTo('POST', '/follow-ups/4/complete').json,
          isEmpty,
        );
        expect(
          env.adapter.requestsTo('POST', '/prospects/42/activities'),
          isEmpty,
        );
      },
    );

    test('recording an activity requires a description', () async {
      final c = build();
      c.description.text = ' ';
      expect(await c.submit(), isNull);
      expect(env.adapter.requests, isEmpty);
    });

    test('server refusal keeps the follow-up pending in the UI', () async {
      env.adapter.reply('POST', '/follow-ups/4/complete', {
        'success': false,
        'message':
            'This follow-up is cancelled and can no longer be completed.',
        'error_code': 'INVALID_FOLLOW_UP_STATE',
        'errors': null,
      }, status: 422);
      final c = build();
      expect(await c.submit(), isNull);
      expect(c.errorMessage.value, contains('can no longer be completed'));
      expect(env.adapter.requestsTo('POST', '/activities'), isEmpty);
    });
  });

  group('FollowUpFormController', () {
    test(
      'defaults to tomorrow 09:00 and creates the follow-up under the prospect',
      () async {
        env.adapter.reply(
          'POST',
          '/prospects/42/follow-ups',
          wrap(followUpJson(id: 10)),
          status: 201,
        );
        final c = Get.put(
          FollowUpFormController(
            repository: env.followUps,
            prospect: prospect,
            clock: now,
          ),
        );
        expect(c.dueAt.value, DateTime(2026, 11, 2, 9));
        c.description.text = 'Rappeler';
        final saved = await c.submit();
        expect(saved!.id, 10);
        final body = env.adapter
            .lastTo('POST', '/prospects/42/follow-ups')
            .json;
        expect(body.containsKey('prospect_id'), isFalse);
        expect(body['title'], 'Rappeler');
        expect(body['description'], isNull);
        expect(body['scheduled_at'], startsWith('2026-11-02T09:00:00'));
        expect(
          body['activity_type'],
          'call',
        ); // default type of a new follow-up
      },
    );

    test('the selected activity type is sent and kept when editing', () async {
      env.adapter.reply(
        'POST',
        '/prospects/42/follow-ups',
        wrap(followUpJson(id: 11)),
        status: 201,
      );
      final c = Get.put(
        FollowUpFormController(
          repository: env.followUps,
          prospect: prospect,
          clock: now,
        ),
      );
      c.description.text = 'Passer au bureau';
      c.type.value = ActivityType.meeting;
      await c.submit();
      expect(
        env.adapter
            .lastTo('POST', '/prospects/42/follow-ups')
            .json['activity_type'],
        'meeting',
      );

      env.adapter.reply(
        'PUT',
        '/follow-ups/4',
        wrap(followUpJson(activityType: 'message')),
      );
      final edit = Get.put(
        FollowUpFormController(
          repository: env.followUps,
          existing: FollowUp.fromJson(
            followUpJson(
              activityType: 'appointment',
              dueAt: '2026-11-05T09:00:00Z',
            ),
          ),
          clock: now,
        ),
        tag: 'edit',
      );
      expect(edit.type.value, ActivityType.meeting);
      edit.type.value = ActivityType.message;
      await edit.submit();
      expect(
        env.adapter.lastTo('PUT', '/follow-ups/4').json['activity_type'],
        'message',
      );
    });

    test(
      'an older follow-up without a type must get one before it can be saved',
      () async {
        final c = Get.put(
          FollowUpFormController(
            repository: env.followUps,
            existing: FollowUp.fromJson(
              followUpJson(activityType: null, dueAt: '2026-11-05T09:00:00Z'),
            ),
            clock: now,
          ),
        );
        expect(c.type.value, isNull);
        expect(await c.submit(), isNull);
        expect(c.typeError, isNotNull);
        expect(env.adapter.requests, isEmpty);
      },
    );

    test('a long text becomes a short title plus the full description', () {
      final long = 'Préparer la démo\n${'x' * 300}';
      final body = FollowUpPayload(
        prospectId: 42,
        dueAt: DateTime(2026, 11, 2, 9),
        description: long,
      ).toJson();
      expect(body['title'], 'Préparer la démo');
      expect(body['description'], long);
      final oneLine = FollowUpPayload(
        prospectId: 42,
        dueAt: DateTime(2026, 11, 2),
        description: 'y' * 250,
      ).toJson();
      expect(
        (oneLine['title'] as String).length,
        FollowUpPayload.titleMaxLength,
      );
      expect(oneLine['description'], 'y' * 250);
    });

    test('a date in the past is refused', () async {
      final c = Get.put(
        FollowUpFormController(
          repository: env.followUps,
          prospect: prospect,
          clock: now,
        ),
      );
      c.dueAt.value = DateTime(2026, 10, 30, 9);
      c.description.text = 'Trop tard';
      expect(await c.submit(), isNull);
      expect(c.dueAtError, isNotNull);
      expect(env.adapter.requests, isEmpty);
    });

    test(
      'server errors on title / scheduled_at show next to the fields',
      () async {
        env.adapter.reply(
          'POST',
          '/prospects/42/follow-ups',
          validationError({
            'title': ['The title field is required.'],
            'scheduled_at': ['The scheduled at cannot be earlier than today.'],
          }),
          status: 422,
        );
        final c = Get.put(
          FollowUpFormController(
            repository: env.followUps,
            prospect: prospect,
            clock: now,
          ),
        );
        c.description.text = 'Rappeler';
        expect(await c.submit(), isNull);
        expect(c.serverErrors['description'], 'The title field is required.');
        expect(c.dueAtError, 'The scheduled at cannot be earlier than today.');
        expect(c.errorMessage.value, 'Certaines données sont invalides.');
      },
    );

    test('editing a pending follow-up uses PUT without prospect_id', () async {
      env.adapter.reply('PUT', '/follow-ups/4', wrap(followUpJson()));
      final c = Get.put(
        FollowUpFormController(
          repository: env.followUps,
          existing: FollowUp.fromJson(
            followUpJson(dueAt: '2026-11-05T09:00:00Z'),
          ),
          clock: now,
        ),
      );
      expect(c.prospectLocked, isTrue);
      c.description.text = 'Nouvelle description';
      expect(await c.submit(), isNotNull);
      final body = env.adapter.lastTo('PUT', '/follow-ups/4').json;
      expect(body.containsKey('prospect_id'), isFalse);
      expect(body['title'], 'Nouvelle description');
    });

    test('cancel sends the reason as closing note', () async {
      env.adapter.reply(
        'POST',
        '/follow-ups/4/cancel',
        wrap(followUpJson(status: 'cancelled', closingNote: 'Plus intéressé')),
      );
      final c = Get.put(
        CancelFollowUpController(
          repository: env.followUps,
          followUp: FollowUp.fromJson(followUpJson()),
        ),
      );
      c.reason.text = 'Plus intéressé';
      final cancelled = await c.submit();
      expect(cancelled!.status, FollowUpStatus.cancelled);
      expect(cancelled.closingNote, 'Plus intéressé');
      expect(env.adapter.lastTo('POST', '/follow-ups/4/cancel').json, {
        'closing_note': 'Plus intéressé',
      });
    });
  });

  group('ActivityFormController', () {
    ActivityFormController build({ProspectRef? p = prospect}) => Get.put(
      ActivityFormController(
        activitiesRepository: env.activities,
        followUpsRepository: env.followUps,
        prospect: p,
        clock: now,
      ),
    );

    test(
      'saves the activity and schedules the follow-up with the same type',
      () async {
        env.adapter
          ..reply(
            'POST',
            '/activities',
            wrap(activityJson(id: 50)),
            status: 201,
          )
          ..reply(
            'POST',
            '/prospects/42/follow-ups',
            wrap(followUpJson(id: 60)),
            status: 201,
          );
        final c = build();
        c.type.value = ActivityType.meeting;
        c.title.text = 'Visite sur site';
        c.description.text = 'Présentation';
        c.nextFollowUpAt.value = DateTime(2026, 11, 8, 9);
        final result = await c.submit();
        expect(result!.activity.id, 50);
        expect(result.followUp!.id, 60);
        final activity = env.adapter.lastTo('POST', '/activities').json;
        expect(activity['prospect_id'], 42);
        expect(activity['title'], 'Visite sur site');
        expect(activity['type'], 'meeting');
        expect(activity['activity_at'], startsWith('2026-11-01T10:00:00'));
        final followUp = env.adapter
            .lastTo('POST', '/prospects/42/follow-ups')
            .json;
        expect(followUp['activity_type'], 'meeting');
        expect(followUp['scheduled_at'], startsWith('2026-11-08T09:00:00'));
      },
    );

    test(
      'an activity can be created WITHOUT a prospect and only needs a title',
      () async {
        env.adapter.reply(
          'POST',
          '/activities',
          wrap(activityJson(id: 52, linked: false, title: 'Appel entrant')),
          status: 201,
        );
        final c = build(p: null);
        c.title.text = 'Appel entrant';
        c.type.value = ActivityType.call;
        final result = await c.submit();
        expect(result!.activity.isLinked, isFalse);
        expect(result.activity.prospect, isNull);
        final sent = env.adapter.lastTo('POST', '/activities').json;
        expect(sent.containsKey('prospect_id'), isFalse);
        expect(sent['description'], isNull);
        expect(
          env.adapter.requestsTo('POST', '/prospects/42/follow-ups'),
          isEmpty,
        );
      },
    );

    test(
      'a failed follow-up is reported separately, the activity stays saved',
      () async {
        env.adapter
          ..reply(
            'POST',
            '/activities',
            wrap(activityJson(id: 51)),
            status: 201,
          )
          ..fail(
            'POST',
            '/prospects/42/follow-ups',
            DioExceptionType.receiveTimeout,
          );
        final c = build();
        c.title.text = 'Note';
        c.nextFollowUpAt.value = DateTime(2026, 11, 8, 9);
        final result = await c.submit();
        expect(result!.activity.id, 51);
        expect(result.followUp, isNull);
        expect(result.followUpError, isA<TimeoutApiException>());
      },
    );

    test('without the checkbox no follow-up is created', () async {
      env.adapter.reply(
        'POST',
        '/activities',
        wrap(activityJson()),
        status: 201,
      );
      final c = build();
      c.title.text = 'Note';
      c.nextFollowUpAt.value = DateTime(2026, 11, 8, 9);
      c.scheduleFollowUp.value = false;
      await c.submit();
      expect(
        env.adapter.requestsTo('POST', '/prospects/42/follow-ups'),
        isEmpty,
      );
    });

    test(
      'requires a title and a past date; the prospect stays optional',
      () async {
        final c = build(p: null);
        c.title.text = '';
        c.occurredAt.value = DateTime(2026, 11, 3);
        expect(await c.submit(), isNull);
        final errors = c.validateAll();
        expect(errors.keys, containsAll(['title', 'activity_at']));
        expect(errors.containsKey('prospect_id'), isFalse);
        expect(env.adapter.requests, isEmpty);
      },
    );

    test('server validation errors show next to the title', () async {
      env.adapter.reply(
        'POST',
        '/activities',
        validationError({
          'title': ['The title field is required.'],
        }),
        status: 422,
      );
      final c = build(p: null);
      c.title.text = 'ok';
      expect(await c.submit(), isNull);
      expect(c.serverErrors['title'], 'The title field is required.');
    });
  });
}
