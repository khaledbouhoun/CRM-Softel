import '../../../core/network/api_response.dart';
import '../data/models/appointment.dart';
import '../data/models/calendar_item.dart';
import '../data/models/portal_request.dart';

/// Appointments, the unified calendar and website requests.
///
/// Every write is validated by the server; the client never assumes a slot
/// is free. Errors surface as `ApiException`s (`ConflictException` for
/// `APPOINTMENT_CONFLICT` / `SLOT_UNAVAILABLE`, `GoneException` for
/// `HOLD_EXPIRED`).
abstract interface class SchedulingRepository {
  Future<Paginated<Appointment>> getAppointments(AppointmentFilter filter);
  Future<Appointment> getAppointment(int id);

  /// One session, or all occurrences of an accompaniment series at once
  /// (all-or-nothing on the server).
  Future<ScheduleResult> schedule(SchedulePayload payload);

  /// Held -> confirmed. `410 HOLD_EXPIRED` when the hold already ran out.
  Future<Appointment> confirm(
    int id, {
    String? meetingUrl,
    String? assignedEmployee,
    String? message,
  });

  /// Releases the slot; [reason] is shown to the customer.
  Future<Appointment> reject(int id, {String? reason});
  Future<Appointment> cancel(int id, {String? reason});

  /// Offers the customer another time (holds the new slot).
  Future<Appointment> propose(int id, DateTime startsAt, {String? message});
  Future<Appointment> reschedule(
    int id,
    DateTime startsAt,
    DateTime endsAt, {
    String? assignedEmployee,
  });

  /// Records the outcome; the server creates the CRM activity.
  Future<Appointment> complete(int id, String outcome);
  Future<Appointment> markNoShow(int id);

  /// Cancels the remaining future sessions (optionally from one session on).
  Future<int> cancelSeries(
    int seriesId, {
    int? fromAppointmentId,
    String? reason,
  });

  Future<List<CalendarItem>> getCalendar(
    DateTime from,
    DateTime to,
    CalendarFilter filter,
  );

  Future<Paginated<PortalRequest>> getPortalRequests({
    String? status,
    String? type,
    int page = 1,
    int perPage = 25,
  });
  Future<PortalRequest> updatePortalRequest(
    int id,
    String status, {
    String? customerMessage,
  });
}
