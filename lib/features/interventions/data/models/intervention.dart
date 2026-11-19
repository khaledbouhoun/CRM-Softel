import '../../../../core/models/named_ref.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../workflow_settings/data/models/config_models.dart';

/// Who wrote a chat entry (`sender` of the API): `client`, `employee` or
/// `system` (timeline events).
class InterventionSender {
  const InterventionSender({required this.role, this.name, this.avatarUrl});

  static const client = 'client';
  static const employee = 'employee';
  static const system = 'system';

  final String role;
  final String? name;
  final String? avatarUrl;

  bool get isEmployee => role == employee;
  bool get isClient => role == client;
  bool get isSystem => role == system;

  static InterventionSender? fromJsonOrNull(Object? value) {
    final json = asMapOrNull(value);
    if (json == null) return null;
    return InterventionSender(
      role: asString(json['role']),
      name: asStringOrNull(json['name']),
      avatarUrl: asStringOrNull(json['avatar_url']),
    );
  }
}

/// A status as embedded in a timeline event.
class EventStatus {
  const EventStatus({required this.id, required this.name, this.color});

  final int id;
  final String name;
  final String? color;

  static EventStatus? fromJsonOrNull(Object? value) {
    final json = asMapOrNull(value);
    if (json == null) return null;
    return EventStatus(
      id: asInt(json['id']),
      name: asString(json['name']),
      color: asStringOrNull(json['color']),
    );
  }
}

/// A timeline event: a status change or a reopening.
class InterventionEvent {
  const InterventionEvent({
    required this.type,
    this.actorRole,
    this.actorName,
    this.oldStatus,
    this.newStatus,
    this.at,
  });

  /// `status_change` or `reopened`.
  final String type;
  final String? actorRole;
  final String? actorName;
  final EventStatus? oldStatus;
  final EventStatus? newStatus;
  final DateTime? at;

  bool get isReopen => type == 'reopened';

  static InterventionEvent? fromJsonOrNull(Object? value) {
    final json = asMapOrNull(value);
    if (json == null) return null;
    final actor = asMapOrNull(json['actor']);
    return InterventionEvent(
      type: asString(json['type'], fallback: 'status_change'),
      actorRole: asStringOrNull(actor?['role']),
      actorName: asStringOrNull(actor?['name']),
      oldStatus: EventStatus.fromJsonOrNull(json['old_status']),
      newStatus: EventStatus.fromJsonOrNull(json['new_status']),
      at: asDateTimeOrNull(json['at']),
    );
  }
}

/// One entry of an intervention's conversation. `internal` messages are
/// employee-only notes; `customer` messages are visible in the portal.
/// Entries with [isEvent] are timeline events (status change, reopening),
/// not messages.
class InterventionMessage {
  const InterventionMessage({
    required this.id,
    required this.authorType,
    required this.visibility,
    required this.body,
    this.authorName,
    this.statusId,
    this.createdAt,
    this.kind = 'message',
    this.sender,
    this.event,
    this.attachments = const [],
    this.statusEventFlag = false,
  });

  final int id;

  /// `employee` or `customer`.
  final String authorType;
  final String? authorName;

  /// `customer` or `internal`.
  final String visibility;
  final String body;
  final int? statusId;
  final DateTime? createdAt;

  /// `message`, `status_change` or `reopened`.
  final String kind;
  final InterventionSender? sender;
  final InterventionEvent? event;
  final List<InterventionAttachment> attachments;

  /// `is_status_event` as sent by some API versions.
  final bool statusEventFlag;

  bool get isInternal => visibility == 'internal';
  bool get isFromCustomer => authorType == 'customer';

  /// A timeline event (rendered as a centred pill), not a chat bubble.
  bool get isEvent =>
      event != null ||
      statusEventFlag ||
      (kind != 'message' && kind.isNotEmpty);

  /// Who wrote it, from `sender.role` (fallback: `author_type`).
  String get senderRole =>
      sender?.role ??
      (isEvent
          ? InterventionSender.system
          : (isFromCustomer
                ? InterventionSender.client
                : InterventionSender.employee));

  bool get isFromEmployee => senderRole == InterventionSender.employee;

  String? get displayName => sender?.name ?? authorName;

  factory InterventionMessage.fromJson(JsonMap json) => InterventionMessage(
    id: asInt(json['id']),
    authorType: asString(json['author_type']),
    authorName: asStringOrNull(json['author_name']),
    visibility: asString(json['visibility'], fallback: 'internal'),
    body: asString(json['body']),
    statusId: asIntOrNull(json['status_id']),
    createdAt: asDateTimeOrNull(json['created_at']),
    kind: asString(json['kind'], fallback: 'message'),
    sender: InterventionSender.fromJsonOrNull(json['sender']),
    event: InterventionEvent.fromJsonOrNull(json['event']),
    attachments: asList(json['attachments'], InterventionAttachment.fromJson),
    statusEventFlag: asBool(json['is_status_event']),
  );
}

class InterventionAttachment {
  const InterventionAttachment({
    required this.id,
    required this.name,
    this.mime,
    this.size,
    this.visibility,
    this.messageId,
    this.isPreviewable = false,
    this.downloadUrl,
    this.previewUrl,
    this.uploadedByName,
  });

  final int id;
  final String name;
  final String? mime;
  final int? size;
  final String? visibility;
  final int? messageId;

  /// The server can show it inline (images and PDFs only).
  final bool isPreviewable;

  /// API-relative paths sent by the server; the client builds its own URLs
  /// from the ids (the base URL is configurable), so these are informative.
  final String? downloadUrl;
  final String? previewUrl;
  final String? uploadedByName;

  factory InterventionAttachment.fromJson(JsonMap json) =>
      InterventionAttachment(
        id: asInt(json['id']),
        name: asString(json['name']),
        mime: asStringOrNull(json['mime']),
        size: asIntOrNull(json['size']),
        visibility: asStringOrNull(json['visibility']),
        messageId: asIntOrNull(json['message_id']),
        isPreviewable: asBool(json['is_previewable']),
        downloadUrl: asStringOrNull(json['download_url']),
        previewUrl: asStringOrNull(json['preview_url']),
        uploadedByName: asStringOrNull(json['uploaded_by_name']),
      );
}

/// After-sales record: a customer request (bug, question, remark) or an
/// employee-published work item (fix, release, update).
class Intervention {
  const Intervention({
    required this.id,
    required this.reference,
    required this.source,
    required this.title,
    this.description,
    this.type,
    this.status,
    this.priority,
    this.prospect,
    this.product,
    this.customers = const [],
    this.assignedEmployee,
    this.isPublished = false,
    this.publishedAt,
    this.customerResolution,
    this.scheduledAt,
    this.closedAt,
    this.canReplyFlag,
    this.messages = const [],
    this.attachments = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String reference;

  /// `customer` or `employee`.
  final String source;
  final String title;
  final String? description;
  final InterventionType? type;
  final InterventionStatus? status;
  final InterventionPriority? priority;
  final NamedRef? prospect;
  final NamedRef? product;
  final List<NamedRef> customers;
  final String? assignedEmployee;
  final bool isPublished;
  final DateTime? publishedAt;
  final String? customerResolution;
  final DateTime? scheduledAt;
  final DateTime? closedAt;

  /// `can_reply` as sent by the server; null when an older API omits it.
  final bool? canReplyFlag;
  final List<InterventionMessage> messages;
  final List<InterventionAttachment> attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isFromCustomer => source == 'customer';
  bool get isClosed => status?.isClosed ?? closedAt != null;

  /// Replies are only possible while the intervention is open: a closed one
  /// shows a banner and no composer until an employee reopens it.
  bool get canReply => canReplyFlag ?? !isClosed;

  /// Employee-originated work items can be published as release notes.
  bool get canPublish => source == 'employee' || customers.isNotEmpty;

  Intervention copyWithMessages(List<InterventionMessage> value) =>
      Intervention(
        id: id,
        reference: reference,
        source: source,
        title: title,
        description: description,
        type: type,
        status: status,
        priority: priority,
        prospect: prospect,
        product: product,
        customers: customers,
        assignedEmployee: assignedEmployee,
        isPublished: isPublished,
        publishedAt: publishedAt,
        customerResolution: customerResolution,
        scheduledAt: scheduledAt,
        closedAt: closedAt,
        canReplyFlag: canReplyFlag,
        messages: value,
        attachments: attachments,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory Intervention.fromJson(JsonMap json) {
    final typeJson = asMapOrNull(json['type']);
    final statusJson = asMapOrNull(json['status']);
    final priorityJson = asMapOrNull(json['priority']);
    return Intervention(
      id: asInt(json['id']),
      reference: asString(json['reference']),
      source: asString(json['source']),
      title: asString(json['title']),
      description: asStringOrNull(json['description']),
      type: typeJson == null ? null : InterventionType.fromJson(typeJson),
      status: statusJson == null
          ? null
          : InterventionStatus.fromJson(statusJson),
      priority: priorityJson == null
          ? null
          : InterventionPriority.fromJson(priorityJson),
      prospect: NamedRef.fromJsonOrNull(json['prospect']),
      product: NamedRef.fromJsonOrNull(json['product']),
      customers: asList(json['customers'], NamedRef.fromJson),
      assignedEmployee: asStringOrNull(json['assigned_employee']),
      isPublished: asBool(json['is_published']),
      publishedAt: asDateTimeOrNull(json['published_at']),
      customerResolution: asStringOrNull(json['customer_resolution']),
      scheduledAt: asDateTimeOrNull(json['scheduled_at']),
      closedAt: asDateTimeOrNull(json['closed_at']),
      canReplyFlag: json['can_reply'] == null ? null : asBool(json['can_reply']),
      messages: asList(json['messages'], InterventionMessage.fromJson),
      attachments: asList(json['attachments'], InterventionAttachment.fromJson),
      createdAt: asDateTimeOrNull(json['created_at']),
      updatedAt: asDateTimeOrNull(json['updated_at']),
    );
  }
}

/// A status reachable from the current one (`GET .../transitions`).
class AllowedTransition {
  const AllowedTransition({
    required this.statusId,
    this.customerAllowed = false,
  });

  final int statusId;
  final bool customerAllowed;

  factory AllowedTransition.fromJson(JsonMap json) => AllowedTransition(
    statusId: asInt(json['status_id']),
    customerAllowed: asBool(json['customer_allowed']),
  );
}

/// Filters of `GET /interventions`.
class InterventionFilter {
  const InterventionFilter({
    this.statusId,
    this.priorityId,
    this.typeId,
    this.source,
    this.assignedEmployee,
    this.prospectId,
    this.open,
    this.page = 1,
    this.perPage = 25,
  });

  final int? statusId;
  final int? priorityId;
  final int? typeId;
  final String? source;
  final String? assignedEmployee;
  final int? prospectId;

  /// true = open only, false = closed only, null = all.
  final bool? open;
  final int page;
  final int perPage;

  bool get hasActiveFilters =>
      statusId != null ||
      priorityId != null ||
      typeId != null ||
      source != null ||
      assignedEmployee != null ||
      open != null;

  Map<String, dynamic> toQuery() => {
    'status_id': statusId,
    'priority_id': priorityId,
    'type_id': typeId,
    'source': source,
    'assigned_employee': assignedEmployee,
    'prospect_id': prospectId,
    'open': open,
    'page': page,
    'per_page': perPage,
  };

  InterventionFilter copyWith({
    Object? statusId = _keep,
    Object? priorityId = _keep,
    Object? typeId = _keep,
    Object? source = _keep,
    Object? assignedEmployee = _keep,
    Object? open = _keep,
    int? page,
  }) => InterventionFilter(
    statusId: identical(statusId, _keep) ? this.statusId : statusId as int?,
    priorityId: identical(priorityId, _keep)
        ? this.priorityId
        : priorityId as int?,
    typeId: identical(typeId, _keep) ? this.typeId : typeId as int?,
    source: identical(source, _keep) ? this.source : source as String?,
    assignedEmployee: identical(assignedEmployee, _keep)
        ? this.assignedEmployee
        : assignedEmployee as String?,
    prospectId: prospectId,
    open: identical(open, _keep) ? this.open : open as bool?,
    page: page ?? this.page,
    perPage: perPage,
  );

  static const _keep = Object();
}

/// Body of `POST /interventions` (employee-originated work).
class InterventionPayload {
  const InterventionPayload({
    required this.typeId,
    required this.title,
    required this.description,
    this.priorityId,
    this.productId,
    this.customerIds = const [],
    this.assignedEmployee,
    this.scheduledAt,
  });

  final int typeId;
  final String title;
  final String description;
  final int? priorityId;
  final int? productId;

  /// Customers affected (they see it once it is published).
  final List<int> customerIds;
  final String? assignedEmployee;
  final DateTime? scheduledAt;

  JsonMap toJson() {
    final who = assignedEmployee?.trim();
    return {
      'intervention_type_id': typeId,
      'title': title.trim(),
      'description': description.trim(),
      'intervention_priority_id': ?priorityId,
      'product_id': ?productId,
      if (customerIds.isNotEmpty) 'customer_ids': customerIds,
      if (who != null && who.isNotEmpty) 'assigned_employee': who,
      if (scheduledAt != null) 'scheduled_at': toApiDateTime(scheduledAt!),
    };
  }
}
