import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'bindings/initial_binding.dart';
import 'config/app_config.dart';
import 'l10n/l10n.dart';
import 'config/app_settings_service.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class SoftelCrmApp extends StatelessWidget {
  const SoftelCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsService>();
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode.value,
      locale: settings.locale.value,
      fallbackLocale: AppLocales.fallback,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialBinding: InitialBinding(),
      // First launch goes to the server settings: there is no sensible
      // default address on employee computers.
      initialRoute: settings.isConfigured ? Routes.dashboard : Routes.settings,
      getPages: AppPages.pages,
      unknownRoute: AppPages.pages.first,
      defaultTransition: Transition.fadeIn,
    );
  }
}
