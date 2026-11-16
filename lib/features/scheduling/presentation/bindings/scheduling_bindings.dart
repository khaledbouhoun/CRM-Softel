import 'package:get/get.dart';

import '../../../../app/services/workflow_lookup_service.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/scheduling_lists_controllers.dart';

/// Loads the shared workflow lookups (types, employees...) without blocking
/// the page: filters fill in as soon as they arrive.
void _warmWorkflowLookups() {
  if (Get.isRegistered<WorkflowLookupService>()) {
    Get.find<WorkflowLookupService>().refreshQuietly();
  }
}

class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    _warmWorkflowLookups();
    Get.lazyPut(
      () => CalendarController(repository: Get.find(), activities: Get.find()),
    );
  }
}

class PendingRequestsBinding extends Bindings {
  @override
  void dependencies() {
    _warmWorkflowLookups();
    Get.lazyPut(() => PendingRequestsController(repository: Get.find()));
  }
}

class TrainingBinding extends Bindings {
  @override
  void dependencies() {
    _warmWorkflowLookups();
    Get.lazyPut(() => TrainingController(repository: Get.find()));
  }
}
