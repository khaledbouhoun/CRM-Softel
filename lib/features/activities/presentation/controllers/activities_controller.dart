import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/state/load_state.dart';
import '../../data/models/activity.dart';
import '../../data/models/activity_type.dart';
import '../../domain/activities_repository.dart';

class ActivitiesController extends GetxController {
  ActivitiesController({required ActivitiesRepository repository})
    : _repository = repository;

  final ActivitiesRepository _repository;

  final filter = const ActivityFilter().obs;
  final page = Rx<Paginated<Activity>>(const Paginated.empty());
  final state = LoadState();
  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state.loading();
    try {
      final result = await _repository.getActivities(filter.value);
      if (requestId != _requestId) return;
      page.value = result;
      state.success();
    } catch (e) {
      if (requestId != _requestId) return;
      state.error(ApiException.from(e));
    }
  }

  void _apply(ActivityFilter next) {
    filter.value = next;
    load();
  }

  void setSearch(String query) {
    if (query.trim() == filter.value.search.trim()) return;
    _apply(filter.value.copyWith(search: query, page: 1));
  }

  void setType(ActivityType? type) =>
      _apply(filter.value.copyWith(type: type, page: 1));

  /// true = linked only, false = unlinked only, null = all.
  void setLinked(bool? linked) =>
      _apply(filter.value.copyWith(linked: linked, page: 1));

  /// Replaces one row after the server confirmed a change (e.g. a link).
  void replaceActivity(Activity updated) {
    final items = [
      for (final a in page.value.items) a.id == updated.id ? updated : a,
    ];
    page.value = page.value.copyWith(items: items);
  }

  void setDateRange(DateTime? from, DateTime? to) =>
      _apply(filter.value.copyWith(dateFrom: from, dateTo: to, page: 1));

  void clearFilters() => _apply(ActivityFilter(perPage: filter.value.perPage));

  void goToPage(int number) => _apply(filter.value.copyWith(page: number));

  void setPerPage(int perPage) =>
      _apply(filter.value.copyWith(perPage: perPage, page: 1));
}
