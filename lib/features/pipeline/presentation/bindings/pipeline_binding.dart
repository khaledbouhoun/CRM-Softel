import 'package:get/get.dart';

import '../controllers/pipeline_controller.dart';

class PipelineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => PipelineController(
        prospectsRepository: Get.find(),
        stagesRepository: Get.find(),
      ),
    );
  }
}
