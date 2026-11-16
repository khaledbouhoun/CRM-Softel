/// JSON payloads shaped exactly like the Laravel backend's responses
/// (backend `docs/API.md`, section 3 "Resource shapes").
library;

const _ts = '2026-10-01T09:00:00+01:00';

Map<String, dynamic> stageJson({
  int id = 1,
  String name = 'Nouveau',
  String type = 'open',
  int position = 1,
  bool isActive = true,
  String color = '#3B82F6',
  int? prospectsCount = 3,
}) => {
  'id': id,
  'name': name,
  'description': null,
  'color': color,
  'sort_order': position,
  'stage_type': type,
  'is_active': isActive,
  'prospects_count': ?prospectsCount,
  'created_at': _ts,
  'updated_at': _ts,
};

final openStage = stageJson(id: 1, name: 'Nouveau', position: 1);
final demoStage = stageJson(id: 2, name: 'Démo faite', position: 2);
final wonStage = stageJson(
  id: 5,
  name: 'Signé',
  type: 'won',
  position: 5,
  color: '#22C55E',
);
final lostStage = stageJson(
  id: 6,
  name: 'Abandonné',
  type: 'lost',
  position: 6,
  color: '#EF4444',
);
final inactiveStage = stageJson(
  id: 9,
  name: 'Ancienne étape',
  position: 9,
  isActive: false,
);

Map<String, dynamic> reasonJson({
  int id = 1,
  String label = 'Trop cher',
  bool requiresDetails = false,
  int position = 1,
  bool isActive = true,
}) => {
  'id': id,
  'name': label,
  'description': null,
  'requires_note': requiresDetails,
  'sort_order': position,
  'is_active': isActive,
  'created_at': _ts,
  'updated_at': _ts,
};

final tooExpensive = reasonJson(id: 1, label: 'Trop cher');
final competitor = reasonJson(
  id: 2,
  label: 'Concurrent choisi',
  requiresDetails: true,
  position: 2,
);

Map<String, dynamic> productJson({
  int id = 1,
  String name = 'GestCom',
  bool isActive = true,
}) => {
  'id': id,
  'name': name,
  'description': 'Gestion commerciale',
  'is_active': isActive,
  'prospects_count': 4,
  'created_at': _ts,
  'updated_at': _ts,
};

Map<String, dynamic> prospectJson({
  int id = 42,
  String companyName = 'SARL Exemple',
  Map<String, dynamic>? stage,
  List<Map<String, dynamic>>? products,
  Map<String, dynamic>? lossReason,
  String? lossDetails,
}) {
  final salesStage = stage ?? openStage;
  return {
    'id': id,
    'name': companyName,
    'contact_person': 'M. Benali',
    'phone': '0550 00 00 00',
    'email': 'contact@exemple.dz',
    'address': '12 rue des Oliviers',
    'city': 'Alger',
    'notes': null,
    'sales_stage_id': salesStage['id'],
    'sales_stage': salesStage,
    'loss_reason_id': lossReason?['id'],
    'loss_reason': lossReason,
    'loss_note': lossDetails,
    'products': products ?? [productJson()],
    'activities_count': 3,
    'pending_follow_ups_count': 1,
    'last_activity_at': '2026-10-30T11:15:00+01:00',
    'next_follow_up_at': '2026-11-05T10:00:00+01:00',
    'created_at': '2026-09-01T09:00:00+01:00',
    'updated_at': '2026-10-20T10:00:00+01:00',
  };
}

Map<String, dynamic> prospectSummaryJson({int id = 42}) => {
  'id': id,
  'name': 'SARL Exemple',
  'contact_person': 'M. Benali',
  'phone': '0550',
  'sales_stage_id': 1,
  'is_deleted': false,
};

Map<String, dynamic> activityJson({
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
  'description': 'Appel de suivi',
  'outcome': 'Intéressé',
  'activity_at': '2026-10-30T11:15:00+01:00',
  'created_at': '2026-10-30T11:20:00+01:00',
  'updated_at': '2026-10-30T11:20:00+01:00',
};

/// [dueState] is the server's `due_state`; it is null when not pending.
Map<String, dynamic> followUpJson({
  int id = 4,
  String status = 'pending',
  String dueAt = '2026-11-05T10:00:00+01:00',
  String? dueState = 'upcoming',
  String? closingNote,
  String? activityType = 'call',
  int? activityId,
}) => {
  'id': id,
  'prospect_id': 42,
  'prospect': prospectSummaryJson(),
  'title': 'Rappeler pour la validation',
  'description': null,
  'activity_type': activityType,
  'activity_id': activityId,
  'scheduled_at': dueAt,
  'status': status,
  'due_state': status == 'pending' ? dueState : null,
  'completed_at': status == 'completed' ? '2026-11-05T10:30:00+01:00' : null,
  'cancelled_at': status == 'cancelled' ? '2026-11-05T10:30:00+01:00' : null,
  'closing_note': closingNote,
  'created_at': '2026-10-30T11:20:00+01:00',
  'updated_at': '2026-10-30T11:20:00+01:00',
};

/// Paginated list in the API envelope.
Map<String, dynamic> paginated(
  List<Map<String, dynamic>> items, {
  int page = 1,
  int lastPage = 1,
  int perPage = 25,
  int? total,
}) => {
  'success': true,
  'message': 'Retrieved successfully.',
  'data': items,
  'meta': {
    'current_page': page,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total ?? items.length,
    'from': items.isEmpty ? null : (page - 1) * perPage + 1,
    'to': items.isEmpty ? null : (page - 1) * perPage + items.length,
  },
};

/// Single object or full list in the API envelope.
Map<String, dynamic> wrap(Object data) => {
  'success': true,
  'message': 'OK.',
  'data': data,
  'meta': data is List ? {'total': data.length} : null,
};

/// Response of POST /prospects/{id}/change-stage: the updated prospect and
/// the new stage history record.
Map<String, dynamic> stageChanged(
  Map<String, dynamic> prospect, {
  int? fromStageId = 1,
}) => wrap({
  'prospect': prospect,
  'stage_history': {
    'id': 99,
    'prospect_id': prospect['id'],
    'from_stage_id': fromStageId,
    'from_stage': null,
    'to_stage_id': prospect['sales_stage_id'],
    'to_stage': prospect['sales_stage'],
    'loss_reason_id': prospect['loss_reason_id'],
    'loss_reason': prospect['loss_reason'],
    'loss_note': prospect['loss_note'],
    'changed_at': '2026-11-01T10:00:00+01:00',
    'created_at': '2026-11-01T10:00:00+01:00',
  },
});

/// 422 field validation error as the API sends it.
Map<String, dynamic> validationError(Map<String, List<String>> errors) => {
  'success': false,
  'message': 'Validation failed.',
  'error_code': 'VALIDATION_FAILED',
  'errors': errors,
};
