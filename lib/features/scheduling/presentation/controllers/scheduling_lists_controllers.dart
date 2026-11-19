import 'package:get/get.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../data/models/appointment.dart';
import '../../data/models/portal_request.dart';
import '../../domain/scheduling_repository.dart';

/// "Pending requests / holds": slots held for visitors who asked for a demo
/// (waiting for an employee decision) and the other website requests.
class PendingRequestsController extends GetxController {
  PendingRequestsController({required SchedulingRepository repository}) : _repository = repository;

  final SchedulingRepository _repository;

  /// 0 = holds, 1 = website requests.
  final tab = 0.obs;

  // --- holds ---
  final holds = <Appointment>[].obs;
  final holdsState = LoadState();

  // --- website requests ---
  final requests = Rx<Paginated<PortalRequest>>(const Paginated.empty());
  final requestsState = LoadState();
  final requestStatus = RxnString();
  final requestType = RxnString();
  final busyRequestIds = <int>{}.obs;
  int _page = 1;
  int _perPage = 25;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() => Future.wait([loadHolds(), loadRequests()]);

  /// Held (waiting for the employee) and proposed (waiting for the
  /// customer) appointments, soonest expiry first.
  Future<void> loadHolds() => holdsState.run(() async {
    final results = await Future.wait([
      _repository.getAppointments(const AppointmentFilter(status: AppointmentStatus.held, perPage: 100)),
      _repository.getAppointments(const AppointmentFilter(status: AppointmentStatus.proposed, perPage: 100)),
    ]);
    final merged = [for (final page in results) ...page.items]
      ..sort((a, b) {
        final ea = a.holdExpiresAt ?? a.startsAt ?? DateTime(9999);
        final eb = b.holdExpiresAt ?? b.startsAt ?? DateTime(9999);
        return ea.compareTo(eb);
      });
    holds.assignAll(merged);
  });

  Future<void> loadRequests() => requestsState.run(() async {
    requests.value = await _repository.getPortalRequests(
      status: requestStatus.value,
      type: requestType.value,
      page: _page,
      perPage: _perPage,
    );
  });

  Future<void> setRequestStatus(String? value) {
    requestStatus.value = value;
    _page = 1;
    return loadRequests();
  }

  Future<void> setRequestType(String? value) {
    requestType.value = value;
    _page = 1;
    return loadRequests();
  }

  Future<void> goToPage(int value) {
    _page = value;
    return loadRequests();
  }

  Future<void> setPerPage(int value) {
    _perPage = value;
    _page = 1;
    return loadRequests();
  }

  /// Closes a quotation / trial request (`handled`, `rejected`, `cancelled`).
  Future<ActionResult<PortalRequest>> updateRequest(
    PortalRequest request,
    String status, {
    String? customerMessage,
  }) async {
    if (busyRequestIds.contains(request.id)) {
      return ActionResult.success(request);
    }
    busyRequestIds.add(request.id);
    try {
      final result = await ActionResult.guard(
        () => _repository.updatePortalRequest(request.id, status, customerMessage: customerMessage),
      );
      if (result.isSuccess) await loadRequests();
      return result;
    } finally {
      busyRequestIds.remove(request.id);
    }
  }
}

/// Training sessions and accompaniment series.
class TrainingController extends GetxController {
  TrainingController({required SchedulingRepository repository, DateTime Function()? clock})
    : _repository = repository,
      _clock = clock ?? DateTime.now;

  final SchedulingRepository _repository;
  final DateTime Function() _clock;

  /// null = training and accompaniment, otherwise one group.
  final group = RxnString();
  final status = Rxn<AppointmentStatus>();
  final showPast = false.obs;
  final sessions = <Appointment>[].obs;
  final state = LoadState();
  final busyIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    final from = showPast.value ? today.subtract(const Duration(days: 90)) : today;
    final groups = group.value == null ? const ['training', 'accompaniment'] : [group.value!];
    final pages = await Future.wait([
      for (final g in groups)
        _repository.getAppointments(AppointmentFilter(group: g, status: status.value, from: from, perPage: 100)),
    ]);
    final merged = [for (final p in pages) ...p.items]
      ..sort((a, b) => (a.startsAt ?? DateTime(9999)).compareTo(b.startsAt ?? DateTime(9999)));
    sessions.assignAll(merged);
  });

  Future<void> setGroup(String? value) {
    group.value = value;
    return load();
  }

  Future<void> setStatus(AppointmentStatus? value) {
    status.value = value;
    return load();
  }

  Future<void> setShowPast(bool value) {
    showPast.value = value;
    return load();
  }

  /// Cancels one future session; the rest of the series is untouched.
  Future<ActionResult<Appointment>> cancelSession(Appointment a, {String? reason}) =>
      _guard(a.id, () => _repository.cancel(a.id, reason: reason));

  /// Cancels this session and every later one of its series (completed
  /// history is never touched by the server).
  Future<ActionResult<int>> cancelRemainingSeries(Appointment a, {String? reason}) async {
    final seriesId = a.seriesId;
    if (seriesId == null) {
      return ActionResult.success(0);
    }
    if (busyIds.contains(a.id)) return ActionResult.success(0);
    busyIds.add(a.id);
    try {
      final result = await ActionResult.guard(
        () => _repository.cancelSeries(seriesId, fromAppointmentId: a.id, reason: reason),
      );
      if (result.isSuccess) await load();
      return result;
    } finally {
      busyIds.remove(a.id);
    }
  }

  Future<ActionResult<Appointment>> markNoShow(Appointment a) => _guard(a.id, () => _repository.markNoShow(a.id));

  Future<ActionResult<Appointment>> _guard(int id, Future<Appointment> Function() task) async {
    if (busyIds.contains(id)) return const ActionResult.success();
    busyIds.add(id);
    try {
      final result = await ActionResult.guard(task);
      if (result.isSuccess) await load();
      return result;
    } finally {
      busyIds.remove(id);
    }
  }
}
