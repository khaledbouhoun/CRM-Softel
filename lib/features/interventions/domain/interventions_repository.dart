import 'dart:typed_data';

import '../../../core/network/api_response.dart';
import '../../../core/utils/file_access.dart';
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
  /// will see in the portal. [files] (max 5) turn the request into a
  /// multipart upload (`files[]`); [body] may then be empty.
  ///
  /// `422 INTERVENTION_CLOSED` when the intervention was closed meanwhile.
  Future<Intervention> addMessage(
    int id, {
    required bool customerVisible,
    required String body,
    List<PickedFile> files = const [],

    /// Flags the attached file(s) as a private hotfix patch for the customer
    /// (only meaningful for customer-visible replies with files).
    bool hotfix = false,
  });

  /// Reopens a closed intervention (replies are enabled again).
  /// [statusId] defaults to the initial status on the server.
  Future<Intervention> reopen(int id, {int? statusId, String? note});

  /// Inline preview bytes of an image/PDF attachment.
  Future<Uint8List> previewAttachment(int id, int attachmentId);

  /// Streams an attachment to [savePath] (any type, any size).
  Future<void> downloadAttachment(
    int id,
    int attachmentId,
    String savePath, {
    void Function(int received, int total)? onProgress,
  });

  /// Publishes release/update notes to the affected customers.
  Future<Intervention> publish(int id, String customerResolution);
  Future<Intervention> unpublish(int id);
}
