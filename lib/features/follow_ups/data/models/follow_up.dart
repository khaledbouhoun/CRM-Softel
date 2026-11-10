import '../../../../core/utils/json_utils.dart';
import '../../../activities/data/models/activity_type.dart';
import '../../../prospects/data/models/prospect_ref.dart';
import '../../../../app/l10n/l10n.dart';

enum FollowUpStatus {
  pending('pending'),
  completed('completed'),
  cancelled('cancelled');

  const FollowUpStatus(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    pending => tr.followUpStatusPending,
    completed => tr.followUpStatusCompleted,
    cancelled => tr.followUpStatusCancelled,
  };

  static FollowUpStatus fromApi(Object? value) {
    final text = value?.toString().trim().toLowerCase();
    return FollowUpStatus.values.firstWhere((s) => s.apiValue == text, orElse: () => FollowUpStatus.pending);
  }
}

/// Tabs of the follow-ups page and their GET `/follow-ups` query.
///
/// today / overdue / upcoming are the API's due windows (`scope`, pending
/// only, whole days in the server's timezone); completed / cancelled filter
/// on `status`, most recently closed first.
enum FollowUpView {
  today('today'),
  overdue('overdue'),
  upcoming('upcoming'),
  completed('completed'),
  cancelled('cancelled');

  const FollowUpView(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    today => tr.followUpViewToday,
    overdue => tr.followUpViewOverdue,
    upcoming => tr.followUpViewUpcoming,
    completed => tr.followUpViewCompleted,
    cancelled => tr.followUpViewCancelled,
  };

  Map<String, dynamic> toQuery() => switch (this) {
    today || overdue || upcoming => {'scope': apiValue},
    completed => {'status': 'completed', 'sort': 'completed_at', 'direction': 'desc'},
    cancelled => {'status': 'cancelled', 'sort': 'created_at', 'direction': 'desc'},
  };
}

class FollowUp {
  const FollowUp({
    required this.id,
    required this.dueAt,
    required this.status,
    this.prospect,
    this.description,
    this.activityType,
    this.activityId,
    this.dueState,
    this.completedAt,
    this.cancelledAt,
    this.closingNote,
    this.createdAt,
  });

  final int id;
  final ProspectRef? prospect;

  /// API `scheduled_at`.
  final DateTime? dueAt;

  /// The text shown for the follow-up: API `description`, or `title` when
  /// there is no longer description (see [FollowUpPayload]).
  final String? description;
  final FollowUpStatus status;

  /// Planned kind (call, appointment, message). Null on follow-ups created
  /// before the field existed.
  final ActivityType? activityType;

  /// Activity this follow-up was converted into, if any.
  final int? activityId;

  /// API `due_state`: overdue | today | upcoming, null when not pending.
  final String? dueState;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  /// Note given when completing or cancelling.
  final String? closingNote;
  final DateTime? createdAt;

  bool get isPending => status == FollowUpStatus.pending;

  /// The server's verdict when present; otherwise "scheduled before today".
  bool isOverdue([DateTime? now]) {
    if (!isPending) return false;
    if (dueState != null) return dueState == 'overdue';
    if (dueAt == null) return false;
    final today = now ?? DateTime.now();
    return dueAt!.isBefore(DateTime(today.year, today.month, today.day));
  }

  factory FollowUp.fromJson(JsonMap json) {
    var prospect = ProspectRef.fromJsonOrNull(json['prospect']);
    final prospectId = asIntOrNull(json['prospect_id']);
    if (prospect == null && prospectId != null) {
      prospect = ProspectRef(id: prospectId, companyName: '');
    }
    return FollowUp(
      id: asInt(json['id']),
      prospect: prospect,
      dueAt: asDateTimeOrNull(json['scheduled_at']),
      description: asStringOrNull(json['description']) ?? asStringOrNull(json['title']),
      status: FollowUpStatus.fromApi(json['status']),
      activityType: json['activity_type'] == null ? null : ActivityType.fromApi(json['activity_type']).canonical,
      activityId: asIntOrNull(json['activity_id']),
      dueState: asStringOrNull(json['due_state']),
      completedAt: asDateTimeOrNull(json['completed_at']),
      cancelledAt: asDateTimeOrNull(json['cancelled_at']),
      closingNote: asStringOrNull(json['closing_note']),
      createdAt: asDateTimeOrNull(json['created_at']),
    );
  }

  /// Same shape as the API resource (used by tests and fixtures).
  JsonMap toJson() => {
    'id': id,
    'prospect_id': prospect?.id,
    'prospect': prospect?.toJson(),
    'title': description,
    'description': null,
    'activity_type': activityType?.apiValue,
    'activity_id': activityId,
    'scheduled_at': dueAt == null ? null : toApiDateTime(dueAt!),
    'status': status.apiValue,
    'due_state': dueState,
    'completed_at': completedAt == null ? null : toApiDateTime(completedAt!),
    'cancelled_at': cancelledAt == null ? null : toApiDateTime(cancelledAt!),
    'closing_note': closingNote,
    'created_at': createdAt == null ? null : toApiDateTime(createdAt!),
  };
}

/// Body of POST `/prospects/{prospectId}/follow-ups` and PUT `/follow-ups/{id}`.
///
/// The app edits a single text. The API requires a short `title` (≤ 200
/// characters): short texts are sent as the title only; longer texts are sent
/// in full as `description` with their beginning as the title.
class FollowUpPayload {
  const FollowUpPayload({required this.prospectId, required this.dueAt, required this.description, this.activityType});

  static const titleMaxLength = 200;

  final int prospectId;
  final DateTime dueAt;
  final String description;
  final ActivityType? activityType;

  JsonMap toJson() {
    final text = description.trim();
    final firstLine = text.split('\n').first.trim();
    final fitsInTitle = !text.contains('\n') && text.length <= titleMaxLength;
    final title = firstLine.length <= titleMaxLength ? firstLine : '${firstLine.substring(0, titleMaxLength - 1)}…';
    return {
      'title': fitsInTitle ? text : title,
      'description': fitsInTitle ? null : text,
      'scheduled_at': toApiDateTime(dueAt),
      if (activityType != null) 'activity_type': activityType!.apiValue,
    };
  }
}

/// Completing a follow-up (POST `/follow-ups/{id}/complete`). With
/// [recordActivity] the server also creates the activity in the same
/// transaction: type and prospect come from the follow-up, so the follow-up
/// can never end up with two activities.
class CompleteFollowUpRequest {
  const CompleteFollowUpRequest({
    this.recordActivity = false,
    this.description,
    this.outcome,
    this.occurredAt,
    this.type,
  });

  final bool recordActivity;

  /// Activity text; defaults to the follow-up text on the server.
  final String? description;

  /// Result of the exchange; also kept as the follow-up's closing note.
  final String? outcome;
  final DateTime? occurredAt;

  /// Used by the server only when the follow-up has no type (older rows).
  final ActivityType? type;

  JsonMap toJson() {
    String? clean(String? v, int max) {
      final t = v?.trim();
      if (t == null || t.isEmpty) return null;
      return t.length > max ? t.substring(0, max) : t;
    }

    final note = clean(outcome, 2000);
    return {
      'closing_note': ?note,
      if (recordActivity) ...{
        'create_activity': true,
        'activity_description': ?clean(description, 5000),
        'activity_outcome': ?clean(outcome, 5000),
        if (occurredAt != null) 'activity_at': toApiDateTime(occurredAt!),
        'activity_type': ?type?.apiValue,
      },
    };
  }
}
