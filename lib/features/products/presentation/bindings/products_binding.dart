import 'package:get/get.dart';

import '../../../../app/services/lookup_service.dart';
import '../controllers/products_controllers.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ProductsController(
        repository: Get.find(),
        // Explicit type: the parameter is nullable.
        lookups: Get.find<LookupService>(),
      ),
    );
  }
}
