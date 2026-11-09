import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/config/app_settings_service.dart';
import 'app/config/key_value_store.dart';
import 'app/l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  for (final name in AppLocales.intlNames) {
    await initializeDateFormatting(name);
  }

  // Needed before the app builds (theme, initial route, API address).
  Get.put(AppSettingsService(GetStorageStore()), permanent: true);

  runApp(const SoftelCrmApp());
}
