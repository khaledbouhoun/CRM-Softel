import '../../../../core/models/named_ref.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../workflow_settings/data/models/config_models.dart';

/// One entry of an intervention's conversation. `internal` messages are
/// employee-only notes; `customer` messages are visible in the portal.
class InterventionMessage {
  const InterventionMessage({
    required this.id,
    required this.authorType,
    required this.visibility,
    required this.body,
    this.authorName,
    this.statusId,
    this.createdAt,
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

  bool get isInternal => visibility == 'internal';
  bool get isFromCustomer => authorType == 'customer';

  factory InterventionMessage.fromJson(JsonMap json) => InterventionMessage(
    id: asInt(json['id']),
    authorType: asString(json['author_type']),
    authorName: asStringOrNull(json['author_name']),
    visibility: asString(json['visibility'], fallback: 'internal'),
    body: asString(json['body']),
    statusId: asIntOrNull(json['status_id']),
    createdAt: asDateTimeOrNull(json['created_at']),
  );
}

class InterventionAttachment {
  const InterventionAttachment({
    required this.id,
    required this.name,
    this.mime,
    this.size,
    this.visibility,
  });

  final int id;
  final String name;
  final String? mime;
  final int? size;
  final String? visibility;

  factory InterventionAttachment.fromJson(JsonMap json) =>
      InterventionAttachment(
        id: asInt(json['id']),
        name: asString(json['name']),
        mime: asStringOrNull(json['mime']),
        size: asIntOrNull(json['size']),
        visibility: asStringOrNull(json['visibility']),
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
  final List<InterventionMessage> messages;
  final List<InterventionAttachment> attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isFromCustomer => source == 'customer';
  bool get isClosed => status?.isClosed ?? closedAt != null;

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
