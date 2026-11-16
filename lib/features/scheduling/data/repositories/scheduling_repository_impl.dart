import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/scheduling_repository.dart';
import '../datasources/scheduling_remote_data_source.dart';
import '../models/appointment.dart';
import '../models/calendar_item.dart';
import '../models/portal_request.dart';

class SchedulingRepositoryImpl implements SchedulingRepository {
  const SchedulingRepositoryImpl(this._remote);

  final SchedulingRemoteDataSource _remote;

  static Map<String, dynamic> _reason(String? reason) {
    final text = reason?.trim();
    return {if (text != null && text.isNotEmpty) 'reason': text};
  }

  @override
  Future<Paginated<Appointment>> getAppointments(AppointmentFilter filter) =>
      _remote.getAppointments(filter);

  @override
  Future<Appointment> getAppointment(int id) => _remote.getAppointment(id);

  @override
  Future<ScheduleResult> schedule(SchedulePayload payload) =>
      _remote.schedule(payload);

  @override
  Future<Appointment> confirm(
    int id, {
    String? meetingUrl,
    String? assignedEmployee,
    String? message,
  }) {
    String? clean(String? v) {
      final t = v?.trim();
      return (t == null || t.isEmpty) ? null : t;
    }

    return _remote.action(
      id,
      'confirm',
      data: {
        'meeting_url': ?clean(meetingUrl),
        'assigned_employee': ?clean(assignedEmployee),
        'message': ?clean(message),
      },
    );
  }

  @override
  Future<Appointment> reject(int id, {String? reason}) =>
      _remote.action(id, 'reject', data: _reason(reason));

  @override
  Future<Appointment> cancel(int id, {String? reason}) =>
      _remote.action(id, 'cancel', data: _reason(reason));

  @override
  Future<Appointment> propose(int id, DateTime startsAt, {String? message}) {
    final text = message?.trim();
    return _remote.action(
      id,
      'propose',
      data: {
        'starts_at': toApiDateTime(startsAt),
        if (text != null && text.isNotEmpty) 'message': text,
      },
    );
  }

  @override
  Future<Appointment> reschedule(
    int id,
    DateTime startsAt,
    DateTime endsAt, {
    String? assignedEmployee,
  }) {
    final who = assignedEmployee?.trim();
    return _remote.action(
      id,
      'reschedule',
      data: {
        'starts_at': toApiDateTime(startsAt),
        'ends_at': toApiDateTime(endsAt),
        if (who != null && who.isNotEmpty) 'assigned_employee': who,
      },
    );
  }

  @override
  Future<Appointment> complete(int id, String outcome) =>
      _remote.action(id, 'complete', data: {'outcome': outcome.trim()});

  @override
  Future<Appointment> markNoShow(int id) => _remote.action(id, 'no-show');

  @override
  Future<int> cancelSeries(
    int seriesId, {
    int? fromAppointmentId,
    String? reason,
  }) => _remote.cancelSeries(
    seriesId,
    fromAppointmentId: fromAppointmentId,
    reason: reason,
  );

  @override
  Future<List<CalendarItem>> getCalendar(
    DateTime from,
    DateTime to,
    CalendarFilter filter,
  ) => _remote.getCalendar(from, to, filter);

  @override
  Future<Paginated<PortalRequest>> getPortalRequests({
    String? status,
    String? type,
    int page = 1,
    int perPage = 25,
  }) => _remote.getPortalRequests(
    status: status,
    type: type,
    page: page,
    perPage: perPage,
  );

  @override
  Future<PortalRequest> updatePortalRequest(
    int id,
    String status, {
    String? customerMessage,
  }) =>
      _remote.updatePortalRequest(id, status, customerMessage: customerMessage);
}
