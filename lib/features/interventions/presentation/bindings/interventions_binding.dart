import 'package:get/get.dart';

import '../../../../app/services/workflow_lookup_service.dart';
import '../controllers/interventions_controllers.dart';

class InterventionsBinding extends Bindings {
  @override
  void dependencies() {
    final workflow = Get.find<WorkflowLookupService>()..refreshQuietly();
    Get.lazyPut(
      () => InterventionsController(repository: Get.find(), workflow: workflow),
    );
  }
}
