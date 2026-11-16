import '../../../../app/l10n/l10n.dart';
import '../../../../core/models/named_ref.dart';
import '../../../../core/utils/json_utils.dart';
import 'appointment.dart';

/// What a calendar entry is. `activity` is a *completed* CRM activity (the
/// past); the others are plans.
enum CalendarKind {
  appointment('appointment'),
  followUp('follow_up'),
  intervention('intervention'),
  activity('activity');

  const CalendarKind(this.apiValue);

  final String apiValue;

  /// Kinds the `/calendar` endpoint can return.
  static const serverKinds = [appointment, followUp, intervention];

  static CalendarKind fromApi(Object? value) {
    final text = value?.toString();
    return CalendarKind.values.firstWhere(
      (k) => k.apiValue == text,
      orElse: () => CalendarKind.appointment,
    );
  }

  String get label => switch (this) {
    appointment => tr.wfKindAppointment,
    followUp => tr.wfKindFollowUp,
    intervention => tr.wfKindIntervention,
    activity => tr.wfKindActivity,
  };
}

/// One overlap flagged by the server on a calendar item.
class ItemConflict {
  const ItemConflict({required this.appointmentId, required this.reason});

  final int appointmentId;

  /// `same_customer` or `same_employee`.
  final String reason;

  String get reasonLabel => switch (reason) {
    'same_employee' => tr.wfConflictEmployee,
    'same_customer' => tr.wfConflictCustomer,
    _ => reason,
  };

  factory ItemConflict.fromJson(JsonMap json) => ItemConflict(
    appointmentId: asInt(json['appointment_id']),
    reason: asString(json['reason']),
  );
}

/// Flat entry of `GET /calendar` (or a completed activity overlay).
class CalendarItem {
  const CalendarItem({
    required this.kind,
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.color,
    this.typeCode,
    this.group,
    this.prospect,
    this.product,
    this.assignedEmployee,
    this.conflicts = const [],
  });

  final CalendarKind kind;
  final int id;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;

  /// Raw status string (appointment status, follow-up status, intervention
  /// status code).
  final String status;

  /// `#RRGGBB` from the configuration; never hard-coded in the client.
  final String? color;
  final String? typeCode;
  final String? group;
  final NamedRef? prospect;
  final NamedRef? product;
  final String? assignedEmployee;
  final List<ItemConflict> conflicts;

  bool get hasConflict => conflicts.isNotEmpty;

  AppointmentStatus get appointmentStatus => AppointmentStatus.fromApi(status);

  /// Completed work (a recorded activity or a finished appointment), as
  /// opposed to something still scheduled.
  bool get isCompleted =>
      kind == CalendarKind.activity ||
      (kind == CalendarKind.appointment && appointmentStatus.isDone);

  bool get isCancelledLike =>
      kind == CalendarKind.appointment &&
      (appointmentStatus == AppointmentStatus.cancelled ||
          appointmentStatus == AppointmentStatus.rejected ||
          appointmentStatus == AppointmentStatus.expired);

  /// Tentative: waiting for an employee or customer decision.
  bool get isTentative =>
      kind == CalendarKind.appointment &&
      (appointmentStatus == AppointmentStatus.held ||
          appointmentStatus == AppointmentStatus.proposed);

  bool overlapsDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return startsAt.isBefore(end) && endsAt.isAfter(start) ||
        (startsAt.isAtSameMomentAs(endsAt) &&
            !startsAt.isBefore(start) &&
            startsAt.isBefore(end));
  }

  factory CalendarItem.fromJson(JsonMap json) {
    final start = asDateTimeOrNull(json['starts_at']) ?? DateTime.now();
    return CalendarItem(
      kind: CalendarKind.fromApi(json['kind']),
      id: asInt(json['id']),
      title: asString(json['title']),
      startsAt: start,
      endsAt: asDateTimeOrNull(json['ends_at']) ?? start,
      status: asString(json['status']),
      color: asStringOrNull(json['color']),
      typeCode: asStringOrNull(json['type_code']),
      group: asStringOrNull(json['group']),
      prospect: NamedRef.fromJsonOrNull(json['prospect']),
      product: NamedRef.fromJsonOrNull(json['product']),
      assignedEmployee: asStringOrNull(json['assigned_employee']),
      conflicts: asList(json['conflicts'], ItemConflict.fromJson),
    );
  }
}

/// Filters of `GET /calendar`.
class CalendarFilter {
  const CalendarFilter({
    this.employee,
    this.prospectId,
    this.productId,
    this.type,
    this.status,
    this.kinds = CalendarKind.serverKinds,
  });

  final String? employee;
  final int? prospectId;
  final int? productId;
  final String? type;
  final String? status;
  final List<CalendarKind> kinds;

  bool get hasActiveFilters =>
      employee != null ||
      prospectId != null ||
      productId != null ||
      type != null ||
      status != null;

  Map<String, dynamic> toQuery(DateTime from, DateTime to) => {
    'from': toApiDate(from),
    'to': toApiDate(to),
    'employee': employee,
    'prospect_id': prospectId,
    'product_id': productId,
    'type': type,
    'status': status,
    'kinds[]': kinds
        .where(CalendarKind.serverKinds.contains)
        .map((k) => k.apiValue)
        .toList(),
  };

  CalendarFilter copyWith({
    Object? employee = _keep,
    Object? prospectId = _keep,
    Object? productId = _keep,
    Object? type = _keep,
    Object? status = _keep,
    List<CalendarKind>? kinds,
  }) => CalendarFilter(
    employee: identical(employee, _keep) ? this.employee : employee as String?,
    prospectId: identical(prospectId, _keep)
        ? this.prospectId
        : prospectId as int?,
    productId: identical(productId, _keep) ? this.productId : productId as int?,
    type: identical(type, _keep) ? this.type : type as String?,
    status: identical(status, _keep) ? this.status : status as String?,
    kinds: kinds ?? this.kinds,
  );

  static const _keep = Object();
}
