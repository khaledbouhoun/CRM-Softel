import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../app/config/app_config.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/state/load_state.dart';
import '../../data/models/follow_up.dart';
import '../../domain/follow_ups_repository.dart';

class FollowUpsController extends GetxController {
  FollowUpsController({
    required FollowUpsRepository repository,
    FollowUpView initialView = FollowUpView.today,
  }) : _repository = repository,
       view = initialView.obs;

  final FollowUpsRepository _repository;

  final Rx<FollowUpView> view;
  final search = ''.obs;
  final pageNumber = 1.obs;
  final perPage = AppConfig.defaultPageSize.obs;
  final page = Rx<Paginated<FollowUp>>(const Paginated.empty());
  final state = LoadState();

  /// Badge counts for the pending views (null until known).
  final counts = <FollowUpView, int>{}.obs;

  int _requestId = 0;

  static const countedViews = [
    FollowUpView.today,
    FollowUpView.overdue,
    FollowUpView.upcoming,
  ];

  @override
  void onInit() {
    super.onInit();
    load();
    refreshCounts();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state.loading();
    try {
      final result = await _repository.getFollowUps(
        view: view.value,
        search: search.value,
        page: pageNumber.value,
        perPage: perPage.value,
      );
      if (requestId != _requestId) return;
      page.value = result;
      if (countedViews.contains(view.value)) counts[view.value] = result.total;
      state.success();
    } catch (e) {
      if (requestId != _requestId) return;
      state.error(ApiException.from(e));
    }
  }

  /// Fetches only the totals of the pending views (1 item per request).
  Future<void> refreshCounts() async {
    await Future.wait(
      countedViews.map((v) async {
        try {
          final result = await _repository.getFollowUps(view: v, perPage: 1);
          counts[v] = result.total;
        } on ApiException catch (e) {
          // Badges are decorative; the main list reports errors to the user.
          debugPrint('[FollowUps] count for ${v.apiValue} failed: $e');
          counts.remove(v);
        }
      }),
    );
  }

  void setView(FollowUpView next) {
    if (next == view.value) return;
    view.value = next;
    pageNumber.value = 1;
    page.value = const Paginated.empty();
    load();
  }

  void setSearch(String query) {
    if (query.trim() == search.value.trim()) return;
    search.value = query;
    pageNumber.value = 1;
    load();
  }

  void goToPage(int number) {
    pageNumber.value = number;
    load();
  }

  void setPerPage(int size) {
    perPage.value = size;
    pageNumber.value = 1;
    load();
  }

  /// After a follow-up was created/edited/completed/cancelled (confirmed).
  Future<void> refreshAfterMutation() => Future.wait([load(), refreshCounts()]);
}
