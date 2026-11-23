import 'package:get/get.dart';

import '../../../follow_ups/domain/follow_ups_repository.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => DashboardController(
        repository: Get.find(),
        followUpsRepository: Get.isRegistered<FollowUpsRepository>()
            ? Get.find<FollowUpsRepository>()
            : null,
      ),
    );
  }
}
