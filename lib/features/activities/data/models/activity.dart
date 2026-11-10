import '../../../../app/config/app_config.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../prospects/data/models/prospect_ref.dart';
import 'activity_type.dart';

/// How an activity came to exist (API `origin`).
enum ActivityOrigin {
  /// Created on its own (from a prospect page or standalone).
  direct,

  /// Converted from a follow-up.
  followUp;

  static ActivityOrigin fromApi(Object? value) =>
      value == 'follow_up' ? followUp : direct;
}

class Activity {
  const Activity({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.description,
    this.prospect,
    this.title,
    this.outcome,
    this.origin = ActivityOrigin.direct,
    this.followUpId,
    this.linkedAt,
    this.createdAt,
  });

  final int id;
  final ProspectRef? prospect;
  final ActivityType type;

  /// API `activity_at`.
  final DateTime? occurredAt;
  final String description;

  /// Optional short summary.
  final String? title;
  final String? outcome;
  final ActivityOrigin origin;

  /// Follow-up this activity was converted from.
  final int? followUpId;
  final DateTime? linkedAt;
  final DateTime? createdAt;

  /// Linked to a prospect (native activities start unlinked).
  bool get isLinked => followUpId != null;
  bool get isLinkedToFollowUp => followUpId != null;

  /// Converted from a follow-up: stays with that follow-up's prospect.
  bool get isFromFollowUp => origin == ActivityOrigin.followUp;

  /// Title when there is one, otherwise the start of the description.
  String get headline {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return description;
  }

  factory Activity.fromJson(JsonMap json) {
    var prospect = ProspectRef.fromJsonOrNull(json['prospect']);
    final prospectId = asIntOrNull(json['prospect_id']);
    if (prospect == null && prospectId != null) {
      prospect = ProspectRef(id: prospectId, companyName: '');
    }
    return Activity(
      id: asInt(json['id']),
      prospect: prospect,
      type: ActivityType.fromApi(json['type']),
      occurredAt: asDateTimeOrNull(json['activity_at']),
      description: asString(json['description']),
      title: asStringOrNull(json['title']),
      outcome: asStringOrNull(json['outcome']),
      origin: ActivityOrigin.fromApi(json['origin']),
      followUpId: asIntOrNull(json['follow_up_id']),
      linkedAt: asDateTimeOrNull(json['linked_at']),
      createdAt: asDateTimeOrNull(json['created_at']),
    );
  }

  /// Same shape as the API resource (used by tests and fixtures).
  JsonMap toJson() => {
    'id': id,
    'prospect_id': prospect?.id,
    'prospect': prospect?.toJson(),
    'type': type.apiValue,
    'activity_at': occurredAt == null ? null : toApiDateTime(occurredAt!),
    'description': description,
    'title': title,
    'outcome': outcome,
    'is_linked': isLinked,
    'origin': origin == ActivityOrigin.followUp ? 'follow_up' : 'direct',
    'follow_up_id': followUpId,
    'linked_at': linkedAt == null ? null : toApiDateTime(linkedAt!),
    'created_at': createdAt == null ? null : toApiDateTime(createdAt!),
  };
}

/// Body of POST `/prospects/{prospectId}/activities` (the prospect is in the
/// URL) or of POST `/activities` ([toNativeJson], prospect optional).
class ActivityPayload {
  const ActivityPayload({
    this.prospectId,
    this.followUpId,
    required this.type,
    required this.occurredAt,
    required this.description,
    this.title,
    this.outcome,
  });

  final int? prospectId;
  final int? followUpId;
  final String? title;
  final ActivityType type;
  final DateTime occurredAt;
  final String description;
  final String? outcome;

  JsonMap toJson() {
    final result = outcome?.trim();
    return {
      'type': type.apiValue,
      'activity_at': toApiDateTime(occurredAt),
      'description': description.trim(),
      'outcome': (result == null || result.isEmpty) ? null : result,
    };
  }

  /// Body of POST `/activities`: title required by the API, description and
  /// prospect optional.
  JsonMap toNativeJson() {
    final result = outcome?.trim();
    final text = description.trim();
    return {
      'type': type.apiValue,
      'title': title?.trim(),
      'description': text.isEmpty ? null : text,
      'outcome': (result == null || result.isEmpty) ? null : result,
      'activity_at': toApiDateTime(occurredAt),
      if (prospectId != null) 'prospect_id': prospectId,
      if (followUpId != null) 'follow_up_id': followUpId,
    };
  }
}

/// Query of GET `/activities`.
class ActivityFilter {
  const ActivityFilter({
    this.search = '',
    this.type,
    this.prospectId,
    this.followUpId,
    this.linked,
    this.dateFrom,
    this.dateTo,
    this.page = 1,
    this.perPage = AppConfig.defaultPageSize,
  });

  final String search;
  final ActivityType? type;
  final int? prospectId;
  final int? followUpId;

  /// true = linked only, false = unlinked only, null = both.
  final bool? linked;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int page;
  final int perPage;

  bool get hasActiveFilters =>
      search.trim().isNotEmpty ||
      type != null ||
      linked != null ||
      dateFrom != null ||
      dateTo != null;

  Map<String, dynamic> toQuery() => {
    'search': search.trim(),
    'type': type?.apiValue,
    'prospect_id': prospectId,
    'linked': linked,
    'date_from': dateFrom == null ? null : toApiDate(dateFrom!),
    'date_to': dateTo == null ? null : toApiDate(dateTo!),
    'page': page,
    'per_page': perPage,
  };

  static const _keep = Object();

  ActivityFilter copyWith({
    String? search,
    Object? type = _keep,
    Object? linked = _keep,
    Object? dateFrom = _keep,
    Object? dateTo = _keep,
    int? page,
    int? perPage,
  }) => ActivityFilter(
    search: search ?? this.search,
    type: identical(type, _keep) ? this.type : type as ActivityType?,
    prospectId: prospectId,
    linked: identical(linked, _keep) ? this.linked : linked as bool?,
    dateFrom: identical(dateFrom, _keep)
        ? this.dateFrom
        : dateFrom as DateTime?,
    dateTo: identical(dateTo, _keep) ? this.dateTo : dateTo as DateTime?,
    page: page ?? this.page,
    perPage: perPage ?? this.perPage,
  );
}
