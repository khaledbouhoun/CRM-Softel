import 'package:get/get.dart';

import '../../../../app/config/app_config.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/load_state.dart';
import '../../../activities/data/models/activity.dart';
import '../../../activities/domain/activities_repository.dart';
import '../../../follow_ups/data/models/follow_up.dart';
import '../../../follow_ups/domain/follow_ups_repository.dart';
import '../../data/models/prospect.dart';
import '../../data/models/stage_history_entry.dart';
import '../../domain/prospects_repository.dart';

/// Everything shown on a prospect's page. Each section loads independently
/// so one failing endpoint does not hide the others.
class ProspectDetailsController extends GetxController {
  ProspectDetailsController({
    required this.prospectId,
    required ProspectsRepository prospectsRepository,
    required ActivitiesRepository activitiesRepository,
    required FollowUpsRepository followUpsRepository,
  }) : _prospects = prospectsRepository,
       _activities = activitiesRepository,
       _followUps = followUpsRepository;

  final int prospectId;
  final ProspectsRepository _prospects;
  final ActivitiesRepository _activities;
  final FollowUpsRepository _followUps;

  final prospect = Rxn<Prospect>();
  final prospectState = LoadState();

  final activities = <Activity>[].obs;
  final activitiesTotal = 0.obs;
  final activitiesState = LoadState();
  int _activitiesPage = 1;
  final hasMoreActivities = false.obs;
  final isLoadingMoreActivities = false.obs;

  final followUps = <FollowUp>[].obs;
  final followUpsState = LoadState();

  final history = <StageHistoryEntry>[].obs;
  final historyState = LoadState();

  /// Pending first (soonest first), then the others (most recent first).
  List<FollowUp> get pendingFollowUps {
    final list = followUps.where((f) => f.isPending).toList();
    list.sort(
      (a, b) =>
          (a.dueAt ?? DateTime(9999)).compareTo(b.dueAt ?? DateTime(9999)),
    );
    return list;
  }

  List<FollowUp> get closedFollowUps {
    final list = followUps.where((f) => !f.isPending).toList();
    list.sort(
      (a, b) => (b.dueAt ?? DateTime(0)).compareTo(a.dueAt ?? DateTime(0)),
    );
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() => Future.wait([
    loadProspect(),
    loadActivities(),
    loadFollowUps(),
    loadHistory(),
  ]);

  Future<void> loadProspect() => prospectState.run(() async {
    prospect.value = await _prospects.getProspect(prospectId);
  });

  Future<void> loadActivities() => activitiesState.run(() async {
    final page = await _activities.getActivities(
      ActivityFilter(prospectId: prospectId, perPage: AppConfig.largePageSize),
    );
    _activitiesPage = 1;
    activities.assignAll(page.items);
    activitiesTotal.value = page.total;
    hasMoreActivities.value = page.hasNext;
  });

  Future<void> loadMoreActivities() async {
    if (isLoadingMoreActivities.value || !hasMoreActivities.value) return;
    isLoadingMoreActivities.value = true;
    try {
      final page = await _activities.getActivities(
        ActivityFilter(
          prospectId: prospectId,
          perPage: AppConfig.largePageSize,
          page: _activitiesPage + 1,
        ),
      );
      _activitiesPage = page.currentPage;
      activities.addAll(page.items);
      hasMoreActivities.value = page.hasNext;
    } catch (e) {
      activitiesState.error(ApiException.from(e));
    } finally {
      isLoadingMoreActivities.value = false;
    }
  }

  Future<void> loadFollowUps() => followUpsState.run(() async {
    final page = await _followUps.getFollowUps(
      prospectId: prospectId,
      perPage: AppConfig.largePageSize,
    );
    followUps.assignAll(page.items);
  });

  Future<void> loadHistory() => historyState.run(() async {
    history.assignAll(await _prospects.getStageHistory(prospectId));
  });

  // --- Refresh after confirmed mutations ---

  void onProspectSaved(Prospect updated) => prospect.value = updated;

  Future<void> onStageChanged(Prospect updated) async {
    prospect.value = updated;
    await loadHistory();
  }

  /// Activities also change "last activity" and may add a follow-up.
  Future<void> onActivityAdded() =>
      Future.wait([loadActivities(), loadFollowUps(), loadProspect()]);

  /// Completing a follow-up may also create an activity.
  Future<void> onFollowUpChanged() =>
      Future.wait([loadFollowUps(), loadActivities(), loadProspect()]);
}
