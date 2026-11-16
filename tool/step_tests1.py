# -*- coding: utf-8 -*-
"""Updates existing Flutter tests to the new behaviour."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import edit  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ---------------------------------------------------------------- fixtures
FX = 'test/helpers/fixtures.dart'
edit(FX, """Map<String, dynamic> activityJson({int id = 9, String type = 'call'}) => {
  'id': id,
  'prospect_id': 42,
  'prospect': prospectSummaryJson(),
  'type': type,
  'description': 'Appel de suivi',""", """Map<String, dynamic> activityJson({
  int id = 9,
  String type = 'call',
  bool linked = true,
  String? title,
  String origin = 'direct',
  int? followUpId,
}) => {
  'id': id,
  'prospect_id': linked ? 42 : null,
  'prospect': linked ? prospectSummaryJson() : null,
  'is_linked': linked,
  'origin': origin,
  'follow_up_id': followUpId,
  'title': title,
  'linked_at': linked ? '2026-10-30T11:20:00+01:00' : null,
  'type': type,
  'description': 'Appel de suivi',""")
edit(FX, """  String? dueState = 'upcoming',
  String? closingNote,
}) => {""", """  String? dueState = 'upcoming',
  String? closingNote,
  String? activityType = 'call',
  int? activityId,
}) => {""")
edit(FX, "  'description': null,\n  'scheduled_at': dueAt,", "  'description': null,\n  'activity_type': activityType,\n  'activity_id': activityId,\n  'scheduled_at': dueAt,")

# ---------------------------------------------------------------- models test
edit('test/models/models_test.dart', """    test('Complete request keeps the activity text as closing note', () {
      final request = CompleteFollowUpRequest(
        activity: ActivityPayload(
          prospectId: 42,
          type: ActivityType.call,
          occurredAt: DateTime(2026, 11, 5, 9, 30),
          description: 'Rappel effectué',
          outcome: 'OK',
        ),
      ).toJson();
      expect(request, {'closing_note': 'Rappel effectué — OK'});
      expect(const CompleteFollowUpRequest().toJson(), isEmpty);
      expect(const CompleteFollowUpRequest(closingNote: ' Fait ').toJson(), {'closing_note': 'Fait'});
    });""", """    test('Complete request asks the server to record the activity in the same call', () {
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
      // The type is the follow-up's own: never sent unless it has none.
      expect(request.containsKey('activity_type'), isFalse);
      expect(const CompleteFollowUpRequest().toJson(), isEmpty);
      expect(
        const CompleteFollowUpRequest(recordActivity: true, fallbackType: ActivityType.message).toJson()['activity_type'],
        'message',
      );
    });

    test('FollowUp reads its activity type and converted activity; legacy rows have none', () {
      final typed = FollowUp.fromJson(followUpJson(activityType: 'appointment', activityId: 7));
      expect(typed.activityType, ActivityType.appointment);
      expect(typed.activityId, 7);
      final legacy = FollowUp.fromJson(followUpJson(activityType: null));
      expect(legacy.activityType, isNull);
      expect(legacy.activityId, isNull);
      final payload = FollowUpPayload(
        prospectId: 42,
        dueAt: DateTime(2026, 11, 5, 9),
        description: 'Visite',
        activityType: ActivityType.appointment,
      ).toJson();
      expect(payload['activity_type'], 'appointment');
    });""")

# ---------------------------------------------------------------- repositories test
edit('test/repositories/repositories_test.dart', """    test('complete then record the activity; cancel posts the closing note', () async {
      env.adapter
        ..reply('POST', '/follow-ups/4/complete', wrap(followUpJson(status: 'completed')))
        ..reply('POST', '/prospects/42/activities', wrap(activityJson(id: 30)), status: 201)
        ..reply('POST', '/follow-ups/4/cancel', wrap(followUpJson(status: 'cancelled')));

      final done = await env.followUps.completeFollowUp(
        4,
        CompleteFollowUpRequest(
          activity: ActivityPayload(
            prospectId: 42,
            type: ActivityType.call,
            occurredAt: DateTime(2026, 11, 5, 9),
            description: 'Rappelé',
          ),
        ),
      );
      expect(done.followUp.status, FollowUpStatus.completed);
      expect(done.activity!.id, 30);
      expect(env.adapter.lastTo('POST', '/follow-ups/4/complete').json, {'closing_note': 'Rappelé'});
      expect(env.adapter.lastTo('POST', '/prospects/42/activities').json['type'], 'call');
""", """    test('completion records the activity in ONE request; cancel posts the closing note', () async {
      env.adapter
        ..reply('POST', '/follow-ups/4/complete', wrap(followUpJson(status: 'completed', activityId: 30)))
        ..reply('POST', '/follow-ups/4/cancel', wrap(followUpJson(status: 'cancelled')));

      final done = await env.followUps.completeFollowUp(
        4,
        CompleteFollowUpRequest(recordActivity: true, description: 'Rappelé', occurredAt: DateTime(2026, 11, 5, 9)),
      );
      expect(done.followUp.status, FollowUpStatus.completed);
      expect(done.activityRecorded, isTrue);
      final sent = env.adapter.lastTo('POST', '/follow-ups/4/complete').json;
      expect(sent['create_activity'], isTrue);
      expect(sent['activity_description'], 'Rappelé');
      // No separate activity request (the server does it atomically).
      expect(env.adapter.requestsTo('POST', '/prospects/42/activities'), isEmpty);
      expect(env.adapter.requestsTo('POST', '/activities'), isEmpty);
""")
edit('test/repositories/repositories_test.dart', """      env.adapter.reply('POST', '/prospects/42/activities', wrap(activityJson(id: 12)), status: 201);""",
     """      env.adapter.reply('POST', '/activities', wrap(activityJson(id: 12)), status: 201);""")
edit('test/repositories/repositories_test.dart', """      expect(env.adapter.lastTo('POST', '/prospects/42/activities').json['type'], 'note');""",
     """      final sent = env.adapter.lastTo('POST', '/activities').json;
      expect(sent['type'], 'note');
      expect(sent['prospect_id'], 42);""")

# ---------------------------------------------------------------- controllers test
CT = 'test/controllers/follow_up_activity_controllers_test.dart'
src = open(os.path.join(ROOT, CT), encoding='utf-8').read()
start = src.index("    test('completes, then records the result as an activity of the prospect'")
end = src.index("    test('completing without recording an activity sends an empty body'")
src = src[:start] + """    test('completes and records the activity in one request, keeping the follow-up type', () async {
      env.adapter.reply(
        'POST',
        '/follow-ups/4/complete',
        wrap(followUpJson(status: 'completed', activityId: 70, activityType: 'appointment')),
      );
      final c = Get.put(CompleteFollowUpController(
        repository: env.followUps,
        followUp: FollowUp.fromJson(followUpJson(activityType: 'appointment')),
        clock: now,
      ));
      expect(c.description.text, 'Rappeler pour la validation'); // prefilled
      expect(c.typeComesFromFollowUp, isTrue);
      expect(c.activityType, ActivityType.appointment);
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
      // The type is the follow-up's: the client does not send one.
      expect(sent.containsKey('activity_type'), isFalse);
      expect(env.adapter.requests, hasLength(1));
    });

    test('an older follow-up without a type lets the user choose the activity type', () async {
      env.adapter.reply('POST', '/follow-ups/4/complete', wrap(followUpJson(status: 'completed', activityId: 71)));
      final c = Get.put(CompleteFollowUpController(
        repository: env.followUps,
        followUp: FollowUp.fromJson(followUpJson(activityType: null)),
        clock: now,
      ));
      expect(c.typeComesFromFollowUp, isFalse);
      c.fallbackType.value = ActivityType.message;
      await c.submit();
      expect(env.adapter.lastTo('POST', '/follow-ups/4/complete').json['activity_type'], 'message');
    });

    test('a server error while completing keeps the follow-up pending and sends nothing twice', () async {
      env.adapter.fail('POST', '/follow-ups/4/complete', DioExceptionType.receiveTimeout);
      final c = build();
      final done = await c.submit();
      expect(done, isNull);
      expect(c.errorMessage.value, isNotNull);
      expect(c.isSubmitting.value, isFalse);
      expect(env.adapter.requestsTo('POST', '/follow-ups/4/complete'), hasLength(1));
    });

""" + src[end:]
src = src.replace("""      final c = build();
      expect(await c.submit(), isNull);
      expect(c.errorMessage.value, contains('can no longer be completed'));
      expect(env.adapter.requestsTo('POST', '/prospects/42/activities'), isEmpty);""", """      final c = build();
      expect(await c.submit(), isNull);
      expect(c.errorMessage.value, contains('can no longer be completed'));
      expect(env.adapter.requestsTo('POST', '/activities'), isEmpty);""")
# form controller: type
src = src.replace("""      expect(body['scheduled_at'], startsWith('2026-11-02T09:00:00'));
    });
""", """      expect(body['scheduled_at'], startsWith('2026-11-02T09:00:00'));
      expect(body['activity_type'], 'call'); // default type of a new follow-up
    });

    test('the selected activity type is sent and kept when editing', () async {
      env.adapter.reply('POST', '/prospects/42/follow-ups', wrap(followUpJson(id: 11)), status: 201);
      final c = Get.put(FollowUpFormController(repository: env.followUps, prospect: prospect, clock: now));
      c.description.text = 'Passer au bureau';
      c.type.value = ActivityType.appointment;
      await c.submit();
      expect(env.adapter.lastTo('POST', '/prospects/42/follow-ups').json['activity_type'], 'appointment');

      env.adapter.reply('PUT', '/follow-ups/4', wrap(followUpJson(activityType: 'message')));
      final edit = Get.put(
        FollowUpFormController(
          repository: env.followUps,
          existing: FollowUp.fromJson(followUpJson(activityType: 'appointment', dueAt: '2026-11-05T09:00:00Z')),
          clock: now,
        ),
        tag: 'edit',
      );
      expect(edit.type.value, ActivityType.appointment);
      edit.type.value = ActivityType.message;
      await edit.submit();
      expect(env.adapter.lastTo('PUT', '/follow-ups/4').json['activity_type'], 'message');
    });

    test('an older follow-up without a type must get one before it can be saved', () async {
      final c = Get.put(FollowUpFormController(
        repository: env.followUps,
        existing: FollowUp.fromJson(followUpJson(activityType: null, dueAt: '2026-11-05T09:00:00Z')),
        clock: now,
      ));
      expect(c.type.value, isNull);
      expect(await c.submit(), isNull);
      expect(c.typeError, isNotNull);
      expect(env.adapter.requests, isEmpty);
    });
""", 1)

# activity form controller tests
start = src.index("  group('ActivityFormController'")
src = src[:start] + """  group('ActivityFormController', () {
    ActivityFormController build({ProspectRef? p = prospect}) => Get.put(ActivityFormController(
      activitiesRepository: env.activities,
      followUpsRepository: env.followUps,
      prospect: p,
      clock: now,
    ));

    test('saves the activity and schedules the follow-up with the same type', () async {
      env.adapter
        ..reply('POST', '/activities', wrap(activityJson(id: 50)), status: 201)
        ..reply('POST', '/prospects/42/follow-ups', wrap(followUpJson(id: 60)), status: 201);
      final c = build();
      c.type.value = ActivityType.appointment;
      c.title.text = 'Visite sur site';
      c.description.text = 'Présentation';
      c.nextFollowUpAt.value = DateTime(2026, 11, 8, 9);
      final result = await c.submit();
      expect(result!.activity.id, 50);
      expect(result.followUp!.id, 60);
      final activity = env.adapter.lastTo('POST', '/activities').json;
      expect(activity['prospect_id'], 42);
      expect(activity['title'], 'Visite sur site');
      expect(activity['type'], 'appointment');
      expect(activity['activity_at'], startsWith('2026-11-01T10:00:00'));
      final followUp = env.adapter.lastTo('POST', '/prospects/42/follow-ups').json;
      expect(followUp['activity_type'], 'appointment');
      expect(followUp['scheduled_at'], startsWith('2026-11-08T09:00:00'));
    });

    test('an activity can be created WITHOUT a prospect and only needs a title', () async {
      env.adapter.reply('POST', '/activities', wrap(activityJson(id: 52, linked: false, title: 'Appel entrant')), status: 201);
      final c = build(p: null);
      c.title.text = 'Appel entrant';
      c.type.value = ActivityType.call;
      final result = await c.submit();
      expect(result!.activity.isLinked, isFalse);
      expect(result.activity.prospect, isNull);
      final sent = env.adapter.lastTo('POST', '/activities').json;
      expect(sent.containsKey('prospect_id'), isFalse);
      expect(sent['description'], isNull);
      expect(env.adapter.requestsTo('POST', '/prospects/42/follow-ups'), isEmpty);
    });

    test('a failed follow-up is reported separately, the activity stays saved', () async {
      env.adapter
        ..reply('POST', '/activities', wrap(activityJson(id: 51)), status: 201)
        ..fail('POST', '/prospects/42/follow-ups', DioExceptionType.receiveTimeout);
      final c = build();
      c.title.text = 'Note';
      c.nextFollowUpAt.value = DateTime(2026, 11, 8, 9);
      final result = await c.submit();
      expect(result!.activity.id, 51);
      expect(result.followUp, isNull);
      expect(result.followUpError, isA<TimeoutApiException>());
    });

    test('without the checkbox no follow-up is created', () async {
      env.adapter.reply('POST', '/activities', wrap(activityJson()), status: 201);
      final c = build();
      c.title.text = 'Note';
      c.nextFollowUpAt.value = DateTime(2026, 11, 8, 9);
      c.scheduleFollowUp.value = false;
      await c.submit();
      expect(env.adapter.requestsTo('POST', '/prospects/42/follow-ups'), isEmpty);
    });

    test('requires a title and a past date; the prospect stays optional', () async {
      final c = build(p: null);
      c.title.text = '';
      c.occurredAt.value = DateTime(2026, 11, 3);
      expect(await c.submit(), isNull);
      final errors = c.validateAll();
      expect(errors.keys, containsAll(['title', 'activity_at']));
      expect(errors.containsKey('prospect_id'), isFalse);
      expect(env.adapter.requests, isEmpty);
    });

    test('server validation errors show next to the title', () async {
      env.adapter.reply(
        'POST',
        '/activities',
        validationError({'title': ['The title field is required.']}),
        status: 422,
      );
      final c = build(p: null);
      c.title.text = 'ok';
      expect(await c.submit(), isNull);
      expect(c.serverErrors['title'], 'The title field is required.');
    });
  });
}
"""
open(os.path.join(ROOT, CT), 'w', encoding='utf-8', newline='\n').write(src)
print('tests1 ok')
