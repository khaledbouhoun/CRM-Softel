import 'package:get/get.dart';

import '../../data/models/prospect_filter.dart';
import '../controllers/prospects_list_controller.dart';

/// Accepts optional route parameters (global search, dashboard links):
/// `search`, `stage_id`, `loss_reason_id`.
class ProspectsBinding extends Bindings {
  @override
  void dependencies() {
    final params = Get.parameters;
    Get.lazyPut(
      () => ProspectsListController(
        repository: Get.find(),
        lookups: Get.find(),
        initialFilter: ProspectFilter(
          search: params['search'] ?? '',
          stageId: int.tryParse(params['stage_id'] ?? ''),
          lossReasonId: int.tryParse(params['loss_reason_id'] ?? ''),
        ),
      ),
    );
  }
}
