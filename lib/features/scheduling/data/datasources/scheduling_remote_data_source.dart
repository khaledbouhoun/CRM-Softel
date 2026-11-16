import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_utils.dart';
import '../models/appointment.dart';
import '../models/calendar_item.dart';
import '../models/portal_request.dart';

class SchedulingRemoteDataSource {
  const SchedulingRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Appointment>> getAppointments(
    AppointmentFilter filter,
  ) async {
    final body = await _api.get(
      ApiEndpoints.appointments,
      query: filter.toQuery(),
    );
    return ApiResponse.paginated(body, Appointment.fromJson);
  }

  Future<Appointment> getAppointment(int id) async => Appointment.fromJson(
    ApiResponse.object(await _api.get(ApiEndpoints.appointment(id))),
  );

  Future<ScheduleResult> schedule(SchedulePayload payload) async {
    final body = await _api.post(
      ApiEndpoints.appointments,
      data: payload.toJson(),
    );
    return ScheduleResult.fromBody(ApiResponse.object(body));
  }

  Future<Appointment> action(
    int id,
    String action, {
    Map<String, dynamic>? data,
  }) async {
    final body = await _api.post(
      ApiEndpoints.appointmentAction(id, action),
      data: data ?? const <String, dynamic>{},
    );
    return Appointment.fromJson(ApiResponse.object(body));
  }

  Future<int> cancelSeries(
    int seriesId, {
    int? fromAppointmentId,
    String? reason,
  }) async {
    final base = ApiEndpoints.appointmentSeriesCancel(seriesId);
    final path = fromAppointmentId == null
        ? base
        : '$base?from_appointment_id=$fromAppointmentId';
    final body = await _api.post(
      path,
      data: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return asInt(ApiResponse.object(body)['cancelled']);
  }

  Future<List<CalendarItem>> getCalendar(
    DateTime from,
    DateTime to,
    CalendarFilter filter,
  ) async {
    final body = await _api.get(
      ApiEndpoints.calendar,
      query: filter.toQuery(from, to),
    );
    return ApiResponse.list(body, CalendarItem.fromJson);
  }

  Future<Paginated<PortalRequest>> getPortalRequests({
    String? status,
    String? type,
    int page = 1,
    int perPage = 25,
  }) async {
    final body = await _api.get(
      ApiEndpoints.portalRequests,
      query: {
        'status': status,
        'type': type,
        'page': page,
        'per_page': perPage,
      },
    );
    return ApiResponse.paginated(body, PortalRequest.fromJson);
  }

  Future<PortalRequest> updatePortalRequest(
    int id,
    String status, {
    String? customerMessage,
  }) async {
    final body = await _api.patch(
      ApiEndpoints.portalRequest(id),
      data: {
        'status': status,
        if (customerMessage != null && customerMessage.trim().isNotEmpty)
          'customer_message': customerMessage.trim(),
      },
    );
    return PortalRequest.fromJson(ApiResponse.object(body));
  }
}
