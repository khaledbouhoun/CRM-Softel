import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/state/load_state.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_filter.dart';
import '../../domain/prospects_repository.dart';

/// Server-side paginated / filtered / sorted prospects table.
class ProspectsListController extends GetxController {
  ProspectsListController({
    required ProspectsRepository repository,
    required this.lookups,
    ProspectFilter initialFilter = const ProspectFilter(),
  }) : _repository = repository,
       filter = initialFilter.obs;

  final ProspectsRepository _repository;
  final LookupService lookups;

  final Rx<ProspectFilter> filter;
  final page = Rx<Paginated<Prospect>>(const Paginated.empty());
  final state = LoadState();

  /// Ignores responses of superseded requests (fast typing, quick filters).
  int _requestId = 0;

  bool get hasLostStages => lookups.stages.any((s) => s.isLost);

  @override
  void onInit() {
    super.onInit();
    load();
    lookups.ensureLoaded().catchError((Object e) {
      // Filters degrade gracefully; the error is exposed by LookupService.
      debugPrint('[Prospects] lookups unavailable: $e');
    });
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state.loading();
    try {
      final result = await _repository.getProspects(filter.value);
      if (requestId != _requestId) return;
      // If the current page vanished (e.g. after filtering), go to the last.
      if (result.items.isEmpty &&
          result.currentPage > 1 &&
          result.lastPage < result.currentPage) {
        filter.value = filter.value.copyWith(page: result.lastPage);
        await load();
        return;
      }
      page.value = result;
      state.success();
    } catch (e) {
      if (requestId != _requestId) return;
      state.error(ApiException.from(e));
    }
  }

  void _apply(ProspectFilter next) {
    filter.value = next;
    load();
  }

  void setSearch(String query) {
    if (query.trim() == filter.value.search.trim()) return;
    _apply(filter.value.copyWith(search: query, page: 1));
  }

  void setStage(int? stageId) =>
      _apply(filter.value.copyWith(stageId: stageId, page: 1));

  void setProduct(int? productId) =>
      _apply(filter.value.copyWith(productId: productId, page: 1));

  void setSource(String? code) =>
      _apply(filter.value.copyWith(source: code, page: 1));

  void setBusinessActivity(String? code) =>
      _apply(filter.value.copyWith(businessActivity: code, page: 1));

  void setPreviousSoftware(String? code) =>
      _apply(filter.value.copyWith(previousSoftware: code, page: 1));

  void setLossReason(int? reasonId) =>
      _apply(filter.value.copyWith(lossReasonId: reasonId, page: 1));

  void setCreatedRange(DateTime? from, DateTime? to) =>
      _apply(filter.value.copyWith(createdFrom: from, createdTo: to, page: 1));

  void clearFilters() => _apply(
    ProspectFilter(
      sort: filter.value.sort,
      ascending: filter.value.ascending,
      perPage: filter.value.perPage,
    ),
  );

  /// Clicking the sorted column toggles the direction.
  void sortBy(ProspectSort sort) {
    final current = filter.value;
    final ascending = current.sort == sort
        ? !current.ascending
        : sort.defaultsToAscending;
    _apply(current.copyWith(sort: sort, ascending: ascending, page: 1));
  }

  void goToPage(int pageNumber) =>
      _apply(filter.value.copyWith(page: pageNumber));

  void setPerPage(int perPage) =>
      _apply(filter.value.copyWith(perPage: perPage, page: 1));

  /// After a create/edit/stage change confirmed by the API.
  Future<void> refreshAfterMutation() => load();
}
