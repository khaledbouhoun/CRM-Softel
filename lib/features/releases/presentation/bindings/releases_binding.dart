import 'package:get/get.dart';

import '../controllers/releases_controllers.dart';

class ReleasesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReleasesController(repository: Get.find()));
  }
}
