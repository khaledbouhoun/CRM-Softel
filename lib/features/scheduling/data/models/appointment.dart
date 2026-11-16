import '../../../../app/l10n/l10n.dart';
import '../../../../core/models/named_ref.dart';
import '../../../../core/utils/json_utils.dart';

/// Appointment lifecycle as defined by the backend (`Appointment::*`).
enum AppointmentStatus {
  held('held'),
  proposed('proposed'),
  confirmed('confirmed'),
  rejected('rejected'),
  cancelled('cancelled'),
  expired('expired'),
  completed('completed'),
  noShow('no_show'),
  unknown('');

  const AppointmentStatus(this.apiValue);

  final String apiValue;

  static AppointmentStatus fromApi(Object? value) {
    final text = value?.toString().trim().toLowerCase();
    return AppointmentStatus.values.firstWhere(
      (s) => s.apiValue == text && s != unknown,
      orElse: () => unknown,
    );
  }

  /// The slot is occupied (it blocks other bookings).
  bool get isLive => this == held || this == proposed || this == confirmed;

  /// The meeting happened (or was missed): a recorded outcome, not a plan.
  bool get isDone => this == completed || this == noShow;

  String get label => switch (this) {
    held => tr.wfStatusHeld,
    proposed => tr.wfStatusProposed,
    confirmed => tr.wfStatusConfirmed,
    rejected => tr.wfStatusRejected,
    cancelled => tr.wfStatusCancelled,
    expired => tr.wfStatusExpired,
    completed => tr.wfStatusCompleted,
    noShow => tr.wfStatusNoShow,
    unknown => '—',
  };
}

/// Appointment type embedded in an appointment (`type`).
class AppointmentTypeRef {
  const AppointmentTypeRef({
    required this.id,
    required this.code,
    required this.name,
    required this.group,
    this.color,
  });

  final int id;
  final String code;
  final String name;

  /// `demo`, `meeting`, `training` or `accompaniment`.
  final String group;
  final String? color;

  bool get isDemo => group == 'demo';
  bool get isTraining => group == 'training';
  bool get isAccompaniment => group == 'accompaniment';

  factory AppointmentTypeRef.fromJson(JsonMap json) => AppointmentTypeRef(
    id: asInt(json['id']),
    code: asString(json['code']),
    name: asString(json['name']),
    group: asString(json['group']),
    color: asStringOrNull(json['color']),
  );
}

/// Customer/prospect summary embedded in an appointment.
class AppointmentProspect {
  const AppointmentProspect({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.isCustomer = false,
  });

  final int id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final bool isCustomer;

  factory AppointmentProspect.fromJson(JsonMap json) => AppointmentProspect(
    id: asInt(json['id']),
    name: asString(json['name']),
    contactPerson: asStringOrNull(json['contact_person']),
    phone: asStringOrNull(json['phone']),
    isCustomer: asBool(json['is_customer']),
  );
}

/// Prefilled `wa.me` link built by the server. Nothing is ever sent from
/// here: the employee opens the link and presses send in WhatsApp, so
/// [deliveryConfirmed] stays false.
class WhatsAppLink {
  const WhatsAppLink({
    required this.url,
    required this.message,
    this.deliveryConfirmed = false,
  });

  final String url;
  final String message;
  final bool deliveryConfirmed;

  static WhatsAppLink? fromJsonOrNull(Object? value) {
    final json = asMapOrNull(value);
    if (json == null) return null;
    final url = asStringOrNull(json['url']);
    if (url == null) return null;
    return WhatsAppLink(
      url: url,
      message: asString(json['message']),
      deliveryConfirmed: asBool(json['delivery_confirmed']),
    );
  }
}

/// A scheduled (future) or recorded meeting. Distinct from an `Activity`,
/// which is only created once the appointment is completed.
class Appointment {
  const Appointment({
    required this.id,
    required this.status,
    required this.type,
    required this.prospect,
    required this.startsAt,
    required this.endsAt,
    this.title,
    this.isHoldExpired = false,
    this.holdExpiresAt,
    this.product,
    this.portalAccountId,
    this.assignedEmployee,
    this.meetingUrl,
    this.internalNotes,
    this.customerMessage,
    this.outcome,
    this.activityId,
    this.seriesId,
    this.trainingKind,
    this.sendWhatsapp = false,
    this.resourceUrl,
    this.whatsapp,
    this.decidedBy,
    this.decidedAt,
    this.createdAt,
  });

  final int id;
  final String? title;
  final AppointmentStatus status;
  final bool isHoldExpired;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? holdExpiresAt;
  final AppointmentTypeRef type;
  final AppointmentProspect prospect;
  final NamedRef? product;
  final int? portalAccountId;
  final String? assignedEmployee;
  final String? meetingUrl;

  /// Employee-only; never shown to the customer.
  final String? internalNotes;

  /// Customer-visible reason / message.
  final String? customerMessage;
  final String? outcome;
  final int? activityId;
  final int? seriesId;

  /// `first` or `follow_up` for training sessions.
  final String? trainingKind;
  final bool sendWhatsapp;
  final String? resourceUrl;
  final WhatsAppLink? whatsapp;
  final String? decidedBy;
  final DateTime? decidedAt;
  final DateTime? createdAt;

  String get displayTitle =>
      (title == null || title!.trim().isEmpty) ? type.name : title!;

  /// A held demo that still waits for an employee decision.
  bool get isAwaitingDecision =>
      status == AppointmentStatus.held && !isHoldExpired;

  bool get canComplete =>
      status == AppointmentStatus.confirmed &&
      startsAt != null &&
      !startsAt!.isAfter(DateTime.now());

  bool get canCancel =>
      status == AppointmentStatus.confirmed ||
      status == AppointmentStatus.held ||
      status == AppointmentStatus.proposed;

  /// Remaining time before the hold runs out (null when no hold).
  Duration? holdRemaining([DateTime? now]) {
    if (holdExpiresAt == null) return null;
    return holdExpiresAt!.difference(now ?? DateTime.now());
  }

  factory Appointment.fromJson(JsonMap json) {
    final typeJson = asMapOrNull(json['type']) ?? const <String, dynamic>{};
    final prospectJson =
        asMapOrNull(json['prospect']) ?? const <String, dynamic>{};
    return Appointment(
      id: asInt(json['id']),
      title: asStringOrNull(json['title']),
      status: AppointmentStatus.fromApi(json['status']),
      isHoldExpired: asBool(json['is_hold_expired']),
      startsAt: asDateTimeOrNull(json['starts_at']),
      endsAt: asDateTimeOrNull(json['ends_at']),
      holdExpiresAt: asDateTimeOrNull(json['hold_expires_at']),
      type: AppointmentTypeRef.fromJson(typeJson),
      prospect: AppointmentProspect.fromJson(prospectJson),
      product: NamedRef.fromJsonOrNull(json['product']),
      portalAccountId: asIntOrNull(json['portal_account_id']),
      assignedEmployee: asStringOrNull(json['assigned_employee']),
      meetingUrl: asStringOrNull(json['meeting_url']),
      internalNotes: asStringOrNull(json['internal_notes']),
      customerMessage: asStringOrNull(json['customer_message']),
      outcome: asStringOrNull(json['outcome']),
      activityId: asIntOrNull(json['activity_id']),
      seriesId: asIntOrNull(json['series_id']),
      trainingKind: asStringOrNull(json['training_kind']),
      sendWhatsapp: asBool(json['send_whatsapp']),
      resourceUrl: asStringOrNull(json['resource_url']),
      whatsapp: WhatsAppLink.fromJsonOrNull(json['whatsapp']),
      decidedBy: asStringOrNull(json['decided_by']),
      decidedAt: asDateTimeOrNull(json['decided_at']),
      createdAt: asDateTimeOrNull(json['created_at']),
    );
  }
}

/// One entry of `errors.conflicts` of a `409 APPOINTMENT_CONFLICT`.
class ScheduleConflict {
  const ScheduleConflict({
    required this.occurrence,
    required this.reason,
    this.startsAt,
    this.conflictingAppointmentId,
  });

  /// 1-based index of the occurrence of the series that cannot be booked.
  final int occurrence;
  final DateTime? startsAt;

  /// `holiday`, `employee_busy` or `customer_busy`.
  final String reason;
  final int? conflictingAppointmentId;

  String get reasonLabel => switch (reason) {
    'holiday' => tr.wfConflictHoliday,
    'employee_busy' => tr.wfConflictEmployee,
    'customer_busy' => tr.wfConflictCustomer,
    _ => reason,
  };

  factory ScheduleConflict.fromJson(JsonMap json) => ScheduleConflict(
    occurrence: asInt(json['occurrence'], fallback: 1),
    startsAt: asDateTimeOrNull(json['starts_at']),
    reason: asString(json['reason']),
    conflictingAppointmentId: asIntOrNull(json['conflicting_appointment_id']),
  );

  /// Parses `errors.conflicts` of an API error envelope.
  static List<ScheduleConflict> listFrom(Map<String, dynamic> details) =>
      asList(details['conflicts'], ScheduleConflict.fromJson);
}

/// Result of `POST /appointments`: a single session, or a whole series.
class ScheduleResult {
  const ScheduleResult({required this.appointments, this.seriesId});

  final int? seriesId;
  final List<Appointment> appointments;

  bool get isSeries => seriesId != null;

  factory ScheduleResult.fromBody(Object? data) {
    final map = asMapOrNull(data) ?? const <String, dynamic>{};
    if (map['appointments'] is List) {
      return ScheduleResult(
        seriesId: asIntOrNull(map['series_id']),
        appointments: asList(map['appointments'], Appointment.fromJson),
      );
    }
    return ScheduleResult(appointments: [Appointment.fromJson(map)]);
  }
}

/// Body of `POST /appointments`.
class SchedulePayload {
  const SchedulePayload({
    required this.prospectId,
    required this.appointmentTypeId,
    required this.startsAt,
    this.endsAt,
    this.productId,
    this.assignedEmployee,
    this.internalNotes,
    this.meetingUrl,
    this.sendWhatsapp = false,
    this.resourceUrl,
    this.occurrences,
    this.intervalDays,
  });

  final int prospectId;
  final int appointmentTypeId;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int? productId;
  final String? assignedEmployee;
  final String? internalNotes;
  final String? meetingUrl;
  final bool sendWhatsapp;
  final String? resourceUrl;
  final int? occurrences;
  final int? intervalDays;

  JsonMap toJson() {
    String? clean(String? v) {
      final t = v?.trim();
      return (t == null || t.isEmpty) ? null : t;
    }

    return {
      'prospect_id': prospectId,
      'appointment_type_id': appointmentTypeId,
      'starts_at': toApiDateTime(startsAt),
      if (endsAt != null) 'ends_at': toApiDateTime(endsAt!),
      'product_id': ?productId,
      'assigned_employee': ?clean(assignedEmployee),
      'internal_notes': ?clean(internalNotes),
      'meeting_url': ?clean(meetingUrl),
      'send_whatsapp': sendWhatsapp,
      'resource_url': ?clean(resourceUrl),
      'occurrences': ?occurrences,
      'interval_days': ?intervalDays,
    };
  }
}

/// Filters of `GET /appointments`.
class AppointmentFilter {
  const AppointmentFilter({
    this.status,
    this.group,
    this.prospectId,
    this.from,
    this.to,
    this.page = 1,
    this.perPage = 50,
    this.descending = false,
  });

  final AppointmentStatus? status;
  final String? group;
  final int? prospectId;
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int perPage;
  final bool descending;

  Map<String, dynamic> toQuery() => {
    'status': status?.apiValue,
    'group': group,
    'prospect_id': prospectId,
    'from': from == null ? null : toApiDate(from!),
    'to': to == null ? null : toApiDate(to!),
    'page': page,
    'per_page': perPage,
    'direction': descending ? 'desc' : null,
  };
}
