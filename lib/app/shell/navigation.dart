import 'package:get/get.dart';

import '../../features/prospects/presentation/controllers/prospects_list_controller.dart';
import '../routes/app_routes.dart';

/// Navigation helpers.
///
/// Top-level pages replace the whole stack (sidebar navigation); detail pages
/// are pushed so the back button works. Re-opening the current top-level page
/// is a no-op, which avoids GetX disposing the controller of the page it
/// just created.
class AppNavigation {
  const AppNavigation._();

  /// Current route without its query string.
  static String get currentPath => Uri.parse(Get.currentRoute).path;

  static void goTo(String route) {
    if (currentPath == route) return;
    Get.offAllNamed(route);
  }

  static Future<T?>? openProspect<T>(int id) =>
      Get.toNamed<T>(Routes.prospect(id));

  static void searchProspects(String query) {
    if (currentPath == Routes.prospects &&
        Get.isRegistered<ProspectsListController>()) {
      Get.find<ProspectsListController>().setSearch(query);
      return;
    }
    Get.offAllNamed(
      Routes.prospects,
      parameters: query.isEmpty ? null : {'search': query},
    );
  }
}
