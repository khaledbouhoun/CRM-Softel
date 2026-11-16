# -*- coding: utf-8 -*-
"""Shell: language menu, global prospect search dialog."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import edit  # noqa: E402

SH = 'lib/app/shell/app_shell.dart'
edit(SH, "          const _ConnectionIndicator(),\n          const SizedBox(width: 4),\n          Obx(() {",
     "          const _ConnectionIndicator(),\n          const SizedBox(width: 4),\n          const LanguageMenuButton(),\n          Obx(() {")
edit(SH, "              tooltip: dark ? tr.themeLight : tr.themeDark,", "              tooltip: dark ? tr.themeToggleToLight : tr.themeToggleToDark,")
edit(SH, """      onSubmitted: (value) {
        AppNavigation.searchProspects(value.trim());
        _controller.clear();
      },""", """      onSubmitted: (value) async {
        final query = value.trim();
        _controller.clear();
        // Same lookup as everywhere else: all stages, with each stage shown.
        final prospect = await showProspectSearchDialog(initialQuery: query);
        if (prospect != null) AppNavigation.openProspect(prospect.id);
      },""")
edit(SH, "import '../config/app_settings_service.dart';",
     "import '../../features/prospects/presentation/dialogs/prospect_search_dialog.dart';\nimport '../config/app_settings_service.dart';\nimport 'language_menu.dart';")
print('ui4 ok')
