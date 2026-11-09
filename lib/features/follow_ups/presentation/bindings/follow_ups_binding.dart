import 'package:get/get.dart';

import '../../data/models/follow_up.dart';
import '../controllers/follow_ups_controller.dart';

class FollowUpsBinding extends Bindings {
  @override
  void dependencies() {
    final requested = Get.parameters['view'];
    Get.lazyPut(
      () => FollowUpsController(
        repository: Get.find(),
        initialView: FollowUpView.values.firstWhere(
          (v) => v.apiValue == requested,
          orElse: () => FollowUpView.today,
        ),
      ),
    );
  }
}
