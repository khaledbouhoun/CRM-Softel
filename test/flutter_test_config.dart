import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';
import 'package:softel_crm/app/l10n/l10n.dart';
import 'package:softel_crm/app/theme/app_theme.dart';

/// Runs before every test file: same locale setup as `main()`.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  for (final name in AppLocales.intlNames) {
    await initializeDateFormatting(name);
  }
  // google_fonts would try to download fonts; tests use the plain theme.
  AppTheme.useGoogleFonts = false;
  // Existing tests assert French text; language-specific tests switch it.
  L10n.current = AppLocales.french;
  await testMain();
}
