import 'package:get/get.dart';

import '../controllers/billing_controllers.dart';

class BillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BillingListController(repository: Get.find()));
  }
}
