import '../../../core/network/api_response.dart';
import '../data/models/intervention.dart';

/// After-sales triage. Internal notes and customer-visible replies share the
/// message endpoint but are strictly separated by `visibility`.
abstract interface class InterventionsRepository {
  Future<Paginated<Intervention>> getInterventions(InterventionFilter filter);
  Future<Intervention> getIntervention(int id);
  Future<Intervention> createIntervention(InterventionPayload payload);

  /// Triage: priority, assignee, schedule, title. Only the given fields are
  /// sent; pass `clear*` to reset a nullable field.
  Future<Intervention> updateIntervention(
    int id, {
    int? priorityId,
    bool clearPriority = false,
    String? assignedEmployee,
    bool clearAssignee = false,
    DateTime? scheduledAt,
    bool clearSchedule = false,
    String? title,
  });

  /// Statuses reachable from the current one (configured transitions only).
  Future<List<AllowedTransition>> getTransitions(int id);

  /// `422 INVALID_STATUS_TRANSITION` when the transition is not configured.
  Future<Intervention> transition(
    int id,
    int statusId, {
    String? customerMessage,
  });

  /// [customerVisible] false = internal staff note; true = reply the customer
  /// will see in the portal.
  Future<Intervention> addMessage(
    int id, {
    required bool customerVisible,
    required String body,
  });

  /// Publishes release/update notes to the affected customers.
  Future<Intervention> publish(int id, String customerResolution);
  Future<Intervention> unpublish(int id);
}
