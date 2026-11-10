import 'package:get/get.dart';

import '../../../../app/services/connection_service.dart';
import '../../../../app/services/lookup_service.dart';
import '../controllers/connection_settings_controller.dart';
import '../controllers/loss_reasons_settings_controllers.dart';
import '../controllers/prospect_form_options_settings_controllers.dart';
import '../controllers/stages_settings_controllers.dart';

// Explicit type arguments are required: the controllers take nullable
// services, and `Get.find()` would otherwise look up `LookupService?`.

class StagesSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => StagesSettingsController(
        repository: Get.find(),
        lookups: Get.find<LookupService>(),
      ),
    );
  }
}

class LossReasonsSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LossReasonsSettingsController(
        repository: Get.find(),
        lookups: Get.find<LookupService>(),
      ),
    );
  }
}

class ProspectFormOptionsSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ProspectFormOptionsSettingsController(
        repository: Get.find(),
        lookups: Get.find<LookupService>(),
      ),
    );
  }
}

class ConnectionSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ConnectionSettingsController(
        settings: Get.find(),
        networkInfo: Get.find(),
        connection: Get.find<ConnectionService>(),
        lookups: Get.find<LookupService>(),
      ),
    );
  }
}
