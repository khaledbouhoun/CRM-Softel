import 'package:get/get.dart';

import '../../../../core/state/load_state.dart';
import '../../data/models/analytics_models.dart';
import '../../domain/analytics_repository.dart';

/// Time ranges offered by the filter bar (values are the API `range` codes).
abstract final class AnalyticsRange {
  static const month = 'month';
  static const quarter = 'quarter';
  static const year = 'year';
  static const all = 'all';

  static const values = [month, quarter, year, all];
}

class AnalyticsController extends GetxController {
  AnalyticsController({required AnalyticsRepository repository})
    : _repository = repository;

  final AnalyticsRepository _repository;

  final data = Rxn<AnalyticsData>();
  final state = LoadState();
  final range = AnalyticsRange.month.obs;
  final lastUpdatedAt = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final requested = range.value;
    var latest = true;
    final ok = await state.run(() async {
      final result = await _repository.getAnalytics(range: requested);
      // Ignore a slow answer if the user switched range meanwhile.
      latest = requested == range.value;
      if (latest) data.value = result;
    });
    if (ok && latest) lastUpdatedAt.value = DateTime.now();
  }

  Future<void> setRange(String value) async {
    if (!AnalyticsRange.values.contains(value) || value == range.value) return;
    range.value = value;
    await load();
  }
}
