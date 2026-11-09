import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_settings_service.dart';
import '../l10n/l10n.dart';

/// Top-bar language switcher: العربية / Français / English.
///
/// Switching is immediate (no restart) and persisted on this computer.
class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsService>();
    return Obx(() {
      final current = settings.locale.value;
      return PopupMenuButton<Locale>(
        tooltip: tr.languageMenuTooltip,
        initialValue: current,
        position: PopupMenuPosition.under,
        onSelected: (locale) {
          if (locale != current) settings.saveLocale(locale);
        },
        itemBuilder: (_) => [
          for (final locale in AppLocales.supported)
            PopupMenuItem<Locale>(
              value: locale,
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: locale == current
                        ? const Icon(Icons.check, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(AppLocales.nativeName(locale)),
                ],
              ),
            ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 20),
              const SizedBox(width: 6),
              Text(
                AppLocales.nativeName(current),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
