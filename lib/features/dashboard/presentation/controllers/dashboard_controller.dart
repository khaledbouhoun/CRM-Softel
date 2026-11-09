import 'package:get/get.dart';

import '../../../../core/state/load_state.dart';
import '../../data/models/dashboard_summary.dart';
import '../../domain/dashboard_repository.dart';

class DashboardController extends GetxController {
  DashboardController({required DashboardRepository repository})
    : _repository = repository;

  final DashboardRepository _repository;

  final summary = Rxn<DashboardSummary>();
  final state = LoadState();
  final lastUpdatedAt = Rxn<DateTime>();

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
  }
}
