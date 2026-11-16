import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/interventions_repository.dart';
import '../datasources/interventions_remote_data_source.dart';
import '../models/intervention.dart';

class InterventionsRepositoryImpl implements InterventionsRepository {
  const InterventionsRepositoryImpl(this._remote);

  final InterventionsRemoteDataSource _remote;

  @override
  Future<Paginated<Intervention>> getInterventions(InterventionFilter filter) =>
      _remote.getInterventions(filter);

  @override
  Future<Intervention> getIntervention(int id) => _remote.getIntervention(id);

  @override
  Future<Intervention> createIntervention(InterventionPayload payload) =>
      _remote.create(payload);

  @override
  Future<Intervention> updateIntervention(
    int id, {
    int? priorityId,
    bool clearPriority = false,
    String? assignedEmployee,
    bool clearAssignee = false,
    DateTime? scheduledAt,
    bool clearSchedule = false,
    String? title,
  }) {
    final changes = <String, dynamic>{
      if (priorityId != null || clearPriority)
        'intervention_priority_id': priorityId,
      if (assignedEmployee != null || clearAssignee)
        'assigned_employee': clearAssignee ? null : assignedEmployee?.trim(),
      if (scheduledAt != null || clearSchedule)
        'scheduled_at': scheduledAt == null ? null : toApiDateTime(scheduledAt),
      if (title != null) 'title': title.trim(),
    };
    return _remote.update(id, changes);
  }

  @override
  Future<List<AllowedTransition>> getTransitions(int id) =>
      _remote.getTransitions(id);

  @override
  Future<Intervention> transition(
    int id,
    int statusId, {
    String? customerMessage,
  }) {
    final text = customerMessage?.trim();
    return _remote.post(id, 'transition', {
      'status_id': statusId,
      if (text != null && text.isNotEmpty) 'customer_message': text,
    });
  }

  @override
  Future<Intervention> addMessage(
    int id, {
    required bool customerVisible,
    required String body,
  }) => _remote.post(id, 'messages', {
    'visibility': customerVisible ? 'customer' : 'internal',
    'body': body.trim(),
  });

  @override
  Future<Intervention> publish(int id, String customerResolution) => _remote
      .post(id, 'publish', {'customer_resolution': customerResolution.trim()});

  @override
  Future<Intervention> unpublish(int id) =>
      _remote.post(id, 'unpublish', const <String, dynamic>{});
}
