import 'package:get/get.dart';

import '../../../../app/services/workflow_lookup_service.dart';
import '../controllers/customers_controllers.dart';

class CustomersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CustomersListController(repository: Get.find()));
  }
}

/// Used by pages that open customer dialogs needing the workflow lookups.
class CustomerProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<WorkflowLookupService>()) {
      Get.find<WorkflowLookupService>().refreshQuietly();
    }
  }
}
