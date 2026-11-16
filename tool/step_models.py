# -*- coding: utf-8 -*-
"""Model-layer changes for the enhancement (prospect fields, activity link, relance type)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import edit  # noqa: E402

P = 'lib/features/prospects/data/models/'
A = 'lib/features/activities/data/models/'
F = 'lib/features/follow_ups/data/models/'

# ------------------------------------------------------------------ Prospect
edit(P + 'prospect.dart', "    this.city,\n    this.notes,\n    this.stage,",
     "    this.city,\n    this.businessActivity,\n    this.source,\n    this.sourceOther,\n    this.previousSoftware,\n    this.notes,\n    this.stage,")
edit(P + 'prospect.dart', "  final String? city;\n  final String? notes;\n  final SalesStage? stage;",
     "  final String? city;\n\n  /// Stable code (e.g. `wholesale`) or free text. Null on older prospects.\n  final String? businessActivity;\n\n  /// Stable code (e.g. `facebook`); [sourceOther] holds the detail for `other`.\n  final String? source;\n  final String? sourceOther;\n\n  /// Stable code (e.g. `sage`) or free text.\n  final String? previousSoftware;\n  final String? notes;\n  final SalesStage? stage;")
edit(P + 'prospect.dart', "    contactName: contactName,\n    phone: phone,\n  );",
     "    contactName: contactName,\n    phone: phone,\n    stage: stage,\n  );")
edit(P + 'prospect.dart', "      city: asStringOrNull(json['city']),\n      notes: asStringOrNull(json['notes']),",
     "      city: asStringOrNull(json['city']),\n      businessActivity: asStringOrNull(json['business_activity']),\n      source: asStringOrNull(json['source']),\n      sourceOther: asStringOrNull(json['source_other']),\n      previousSoftware: asStringOrNull(json['previous_software']),\n      notes: asStringOrNull(json['notes']),")
edit(P + 'prospect.dart', "    'city': city,\n    'notes': notes,",
     "    'city': city,\n    'business_activity': businessActivity,\n    'source': source,\n    'source_other': sourceOther,\n    'previous_software': previousSoftware,\n    'notes': notes,")

# ------------------------------------------------------------------ ProspectRef (+ stage for search results)
edit(P + 'prospect_ref.dart', "import '../../../../core/utils/json_utils.dart';",
     "import '../../../../core/utils/json_utils.dart';\nimport '../../../settings/data/models/sales_stage.dart';")
edit(P + 'prospect_ref.dart', "    this.phone,\n    this.isDeleted = false,\n  });",
     "    this.phone,\n    this.stage,\n    this.isDeleted = false,\n  });")
edit(P + 'prospect_ref.dart', "  final String? phone;\n\n  /// The prospect was deleted",
     "  final String? phone;\n\n  /// Current stage when the API embedded it (search results, activities).\n  final SalesStage? stage;\n\n  /// The prospect was deleted")
edit(P + 'prospect_ref.dart', "  factory ProspectRef.fromJson(JsonMap json) => ProspectRef(\n    id: asInt(json['id']),",
     "  factory ProspectRef.fromJson(JsonMap json) => ProspectRef(\n    stage: asMapOrNull(json['sales_stage']) == null ? null : SalesStage.fromJson(asMapOrNull(json['sales_stage'])!),\n    id: asInt(json['id']),")
edit(P + 'prospect_ref.dart', "    'phone': phone,\n    'is_deleted': isDeleted,",
     "    'phone': phone,\n    'sales_stage_id': stage?.id,\n    'sales_stage': stage?.toJson(),\n    'is_deleted': isDeleted,")

# ------------------------------------------------------------------ ProspectPayload
edit(P + 'prospect_requests.dart', "    this.city,\n    this.notes,\n    this.salesStageId,",
     "    this.city,\n    this.businessActivity,\n    this.source,\n    this.sourceOther,\n    this.previousSoftware,\n    this.notes,\n    this.salesStageId,")
edit(P + 'prospect_requests.dart', "  final String? city;\n  final String? notes;\n\n  /// Only sent on creation.",
     "  final String? city;\n  final String? businessActivity;\n  final String? source;\n\n  /// Only meaningful (and only kept by the API) when [source] is `other`.\n  final String? sourceOther;\n  final String? previousSoftware;\n  final String? notes;\n\n  /// Only sent on creation.")
edit(P + 'prospect_requests.dart', "    'city': _clean(city),\n    'notes': _clean(notes),",
     "    'city': _clean(city),\n    'business_activity': _clean(businessActivity),\n    'source': _clean(source),\n    'source_other': source == 'other' ? _clean(sourceOther) : null,\n    'previous_software': _clean(previousSoftware),\n    'notes': _clean(notes),")

# ------------------------------------------------------------------ ProspectFilter
edit(P + 'prospect_filter.dart', "    this.lossReasonId,\n    this.createdFrom,\n    this.createdTo,\n    this.sort",
     "    this.lossReasonId,\n    this.source,\n    this.businessActivity,\n    this.previousSoftware,\n    this.createdFrom,\n    this.createdTo,\n    this.sort")
edit(P + 'prospect_filter.dart', "  final int? lossReasonId;\n  final DateTime? createdFrom;",
     "  final int? lossReasonId;\n  final String? source;\n  final String? businessActivity;\n  final String? previousSoftware;\n  final DateTime? createdFrom;")
edit(P + 'prospect_filter.dart', "      lossReasonId != null ||\n      createdFrom != null ||",
     "      lossReasonId != null ||\n      source != null ||\n      businessActivity != null ||\n      previousSoftware != null ||\n      createdFrom != null ||")
edit(P + 'prospect_filter.dart', "    'loss_reason_id': lossReasonId,\n    'created_from'",
     "    'loss_reason_id': lossReasonId,\n    'source': source,\n    'business_activity': businessActivity,\n    'previous_software': previousSoftware,\n    'created_from'")
edit(P + 'prospect_filter.dart', "    Object? lossReasonId = _keep,\n    Object? createdFrom = _keep,",
     "    Object? lossReasonId = _keep,\n    Object? source = _keep,\n    Object? businessActivity = _keep,\n    Object? previousSoftware = _keep,\n    Object? createdFrom = _keep,")
edit(P + 'prospect_filter.dart', "    createdFrom: identical(createdFrom, _keep)\n        ? this.createdFrom",
     "    source: identical(source, _keep) ? this.source : source as String?,\n    businessActivity: identical(businessActivity, _keep)\n        ? this.businessActivity\n        : businessActivity as String?,\n    previousSoftware: identical(previousSoftware, _keep)\n        ? this.previousSoftware\n        : previousSoftware as String?,\n    createdFrom: identical(createdFrom, _keep)\n        ? this.createdFrom")

# ------------------------------------------------------------------ ActivityType
edit(A + 'activity_type.dart', "  call('call'),\n  meeting('meeting'),",
     "  call('call'),\n\n  /// Legacy code of rows created before `appointment` existed. Same meaning.\n  meeting('meeting'),\n  appointment('appointment'),")
edit(A + 'activity_type.dart', "    meeting => tr.activityTypeAppointment,",
     "    meeting || appointment => tr.activityTypeAppointment,")
edit(A + 'activity_type.dart', "  static ActivityType fromApi",
     "  /// The three types offered when creating an activity or a follow-up.\n  static const selectable = [call, appointment, message];\n\n  /// `meeting` rows are appointments.\n  ActivityType get canonical => this == meeting ? appointment : this;\n\n  static ActivityType fromApi")

# ------------------------------------------------------------------ Activity
edit(A + 'activity.dart', "import 'activity_type.dart';\n\nclass Activity {",
     "import 'activity_type.dart';\n\n/// How an activity came to exist (API `origin`).\nenum ActivityOrigin {\n  /// Created on its own (from a prospect page or standalone).\n  direct,\n\n  /// Converted from a follow-up.\n  followUp;\n\n  static ActivityOrigin fromApi(Object? value) =>\n      value == 'follow_up' ? followUp : direct;\n}\n\nclass Activity {")
edit(A + 'activity.dart', "    this.prospect,\n    this.outcome,\n    this.createdAt,\n  });\n\n  final int id;",
     "    this.prospect,\n    this.title,\n    this.outcome,\n    this.origin = ActivityOrigin.direct,\n    this.followUpId,\n    this.linkedAt,\n    this.createdAt,\n  });\n\n  final int id;")
edit(A + 'activity.dart', "  final String description;\n  final String? outcome;\n  final DateTime? createdAt;\n\n  factory",
     "  final String description;\n\n  /// Optional short summary.\n  final String? title;\n  final String? outcome;\n  final ActivityOrigin origin;\n\n  /// Follow-up this activity was converted from.\n  final int? followUpId;\n  final DateTime? linkedAt;\n  final DateTime? createdAt;\n\n  /// Linked to a prospect (native activities start unlinked).\n  bool get isLinked => prospect != null;\n\n  /// Converted from a follow-up: stays with that follow-up's prospect.\n  bool get isFromFollowUp => origin == ActivityOrigin.followUp;\n\n  /// Title when there is one, otherwise the start of the description.\n  String get headline {\n    final t = title?.trim();\n    if (t != null && t.isNotEmpty) return t;\n    return description;\n  }\n\n  factory")
edit(A + 'activity.dart', "      description: asString(json['description']),\n      outcome: asStringOrNull(json['outcome']),\n      createdAt",
     "      description: asString(json['description']),\n      title: asStringOrNull(json['title']),\n      outcome: asStringOrNull(json['outcome']),\n      origin: ActivityOrigin.fromApi(json['origin']),\n      followUpId: asIntOrNull(json['follow_up_id']),\n      linkedAt: asDateTimeOrNull(json['linked_at']),\n      createdAt")
edit(A + 'activity.dart', "    'description': description,\n    'outcome': outcome,\n    'created_at'",
     "    'description': description,\n    'title': title,\n    'outcome': outcome,\n    'is_linked': isLinked,\n    'origin': origin == ActivityOrigin.followUp ? 'follow_up' : 'direct',\n    'follow_up_id': followUpId,\n    'linked_at': linkedAt == null ? null : toApiDateTime(linkedAt!),\n    'created_at'")

# ActivityPayload: prospect optional + title; native body
edit(A + 'activity.dart', "/// Body of POST `/prospects/{prospectId}/activities` (the prospect is in the\n/// URL, not in the body).\nclass ActivityPayload {\n  const ActivityPayload({\n    required this.prospectId,\n    required this.type,\n    required this.occurredAt,\n    required this.description,\n    this.outcome,\n  });\n\n  final int prospectId;",
     "/// Body of POST `/prospects/{prospectId}/activities` (the prospect is in the\n/// URL) or of POST `/activities` ([toNativeJson], prospect optional).\nclass ActivityPayload {\n  const ActivityPayload({\n    this.prospectId,\n    required this.type,\n    required this.occurredAt,\n    required this.description,\n    this.title,\n    this.outcome,\n  });\n\n  final int? prospectId;\n  final String? title;")
edit(A + 'activity.dart', "      'description': description.trim(),\n      'outcome': (result == null || result.isEmpty) ? null : result,\n    };\n  }\n}",
     "      'description': description.trim(),\n      'outcome': (result == null || result.isEmpty) ? null : result,\n    };\n  }\n\n  /// Body of POST `/activities`: title required by the API, description and\n  /// prospect optional.\n  JsonMap toNativeJson() {\n    final result = outcome?.trim();\n    final text = description.trim();\n    return {\n      'type': type.apiValue,\n      'title': title?.trim(),\n      'description': text.isEmpty ? null : text,\n      'outcome': (result == null || result.isEmpty) ? null : result,\n      'activity_at': toApiDateTime(occurredAt),\n      if (prospectId != null) 'prospect_id': prospectId,\n    };\n  }\n}")

# ActivityFilter: linked / origin
edit(A + 'activity.dart', "    this.prospectId,\n    this.dateFrom,\n    this.dateTo,\n    this.page = 1,\n    this.perPage = AppConfig.defaultPageSize,\n  });\n\n  final String search;\n  final ActivityType? type;\n  final int? prospectId;",
     "    this.prospectId,\n    this.linked,\n    this.dateFrom,\n    this.dateTo,\n    this.page = 1,\n    this.perPage = AppConfig.defaultPageSize,\n  });\n\n  final String search;\n  final ActivityType? type;\n  final int? prospectId;\n\n  /// true = linked only, false = unlinked only, null = both.\n  final bool? linked;")
edit(A + 'activity.dart', "      type != null ||\n      dateFrom != null ||", "      type != null ||\n      linked != null ||\n      dateFrom != null ||")
edit(A + 'activity.dart', "    'prospect_id': prospectId,\n    'date_from'", "    'prospect_id': prospectId,\n    'linked': linked,\n    'date_from'")
edit(A + 'activity.dart', "    Object? type = _keep,\n    Object? dateFrom = _keep,", "    Object? type = _keep,\n    Object? linked = _keep,\n    Object? dateFrom = _keep,")
edit(A + 'activity.dart', "    prospectId: prospectId,\n    dateFrom: identical", "    prospectId: prospectId,\n    linked: identical(linked, _keep) ? this.linked : linked as bool?,\n    dateFrom: identical")

# ------------------------------------------------------------------ FollowUp
edit(F + 'follow_up.dart', "    this.prospect,\n    this.description,\n    this.dueState,", "    this.prospect,\n    this.description,\n    this.activityType,\n    this.activityId,\n    this.dueState,")
edit(F + 'follow_up.dart', "  final FollowUpStatus status;\n\n  /// API `due_state`",
     "  final FollowUpStatus status;\n\n  /// Planned kind (call, appointment, message). Null on follow-ups created\n  /// before the field existed.\n  final ActivityType? activityType;\n\n  /// Activity this follow-up was converted into, if any.\n  final int? activityId;\n\n  /// API `due_state`")
edit(F + 'follow_up.dart', "      status: FollowUpStatus.fromApi(json['status']),\n      dueState",
     "      status: FollowUpStatus.fromApi(json['status']),\n      activityType: json['activity_type'] == null ? null : ActivityType.fromApi(json['activity_type']).canonical,\n      activityId: asIntOrNull(json['activity_id']),\n      dueState")
edit(F + 'follow_up.dart', "    'description': null,\n    'scheduled_at'", "    'description': null,\n    'activity_type': activityType?.apiValue,\n    'activity_id': activityId,\n    'scheduled_at'")
edit(F + 'follow_up.dart', "import '../../../activities/data/models/activity.dart';",
     "import '../../../activities/data/models/activity.dart';\nimport '../../../activities/data/models/activity_type.dart';")

# FollowUpPayload: type
edit(F + 'follow_up.dart', "    required this.dueAt,\n    required this.description,\n  });\n\n  static const titleMaxLength = 200;\n\n  final int prospectId;\n  final DateTime dueAt;\n  final String description;",
     "    required this.dueAt,\n    required this.description,\n    this.activityType,\n  });\n\n  static const titleMaxLength = 200;\n\n  final int prospectId;\n  final DateTime dueAt;\n  final String description;\n  final ActivityType? activityType;")
edit(F + 'follow_up.dart', "      'scheduled_at': toApiDateTime(dueAt),\n    };\n  }\n}\n\n/// Completing",
     "      'scheduled_at': toApiDateTime(dueAt),\n      if (activityType != null) 'activity_type': activityType!.apiValue,\n    };\n  }\n}\n\n/// Completing")

# CompleteFollowUpRequest -> single atomic call
start = open(F + 'follow_up.dart', encoding='utf-8').read().index('/// Completing a follow-up')
src = open(F + 'follow_up.dart', encoding='utf-8').read()[:start]
src += '''/// Completing a follow-up (POST `/follow-ups/{id}/complete`). With
/// [recordActivity] the server also creates the activity in the same
/// transaction: type and prospect come from the follow-up, so the follow-up
/// can never end up with two activities.
class CompleteFollowUpRequest {
  const CompleteFollowUpRequest({
    this.recordActivity = false,
    this.description,
    this.outcome,
    this.occurredAt,
    this.fallbackType,
  });

  final bool recordActivity;

  /// Activity text; defaults to the follow-up text on the server.
  final String? description;

  /// Result of the exchange; also kept as the follow-up's closing note.
  final String? outcome;
  final DateTime? occurredAt;

  /// Used by the server only when the follow-up has no type (older rows).
  final ActivityType? fallbackType;

  JsonMap toJson() {
    String? clean(String? v, int max) {
      final t = v?.trim();
      if (t == null || t.isEmpty) return null;
      return t.length > max ? t.substring(0, max) : t;
    }

    final note = clean(outcome, 2000);
    return {
      if (note != null) 'closing_note': note,
      if (recordActivity) ...{
        'create_activity': true,
        if (clean(description, 5000) != null) 'activity_description': clean(description, 5000),
        if (clean(outcome, 5000) != null) 'activity_outcome': clean(outcome, 5000),
        if (occurredAt != null) 'activity_at': toApiDateTime(occurredAt!),
        if (fallbackType != null) 'activity_type': fallbackType!.apiValue,
      },
    };
  }
}
'''
open(F + 'follow_up.dart', 'w', encoding='utf-8', newline='\n').write(src)
print('models ok')
