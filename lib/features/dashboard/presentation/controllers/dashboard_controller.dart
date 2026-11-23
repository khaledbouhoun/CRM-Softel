import 'package:get/get.dart';

import '../../../../core/state/load_state.dart';
import '../../../follow_ups/data/models/follow_up.dart';
import '../../../follow_ups/domain/follow_ups_repository.dart';
import '../../data/models/dashboard_summary.dart';
import '../../domain/dashboard_repository.dart';

class DashboardController extends GetxController {
  DashboardController({
    required DashboardRepository repository,
    FollowUpsRepository? followUpsRepository,
  }) : _repository = repository,
       _followUps = followUpsRepository;

  final DashboardRepository _repository;
  final FollowUpsRepository? _followUps;

  final summary = Rxn<DashboardSummary>();
  final state = LoadState();
  final lastUpdatedAt = Rxn<DateTime>();

  /// Pending follow-ups due today (first page only; the dashboard shows a few).
  final todayFollowUps = <FollowUp>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final ok = await state.run(() async {
      summary.value = await _repository.getSummary();
    });
    if (ok) lastUpdatedAt.value = DateTime.now();
    await _loadTodayFollowUps();
  }

  /// Secondary data: a failure here must not turn the dashboard into an error.
  Future<void> _loadTodayFollowUps() async {
    final repo = _followUps;
    if (repo == null) return;
    try {
      final page = await repo.getFollowUps(
        view: FollowUpView.today,
        perPage: 8,
      );
      todayFollowUps.assignAll(page.items.where((f) => f.isPending));
    } catch (_) {
      // Keep the previous list.
    }
  }
}
