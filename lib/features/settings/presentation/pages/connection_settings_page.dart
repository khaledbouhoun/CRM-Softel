import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/config/app_settings_service.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../controllers/connection_settings_controller.dart';
import '../../../../app/l10n/l10n.dart';

class ConnectionSettingsPage extends GetView<ConnectionSettingsController> {
  const ConnectionSettingsPage({super.key});

  Future<void> _save() async {
    switch (await controller.save()) {
      case ConnectionSaveResult.notSaved:
        return;
      case ConnectionSaveResult.savedOnline:
        AppFeedback.success(tr.settingsSavedOnline);
      case ConnectionSaveResult.savedOffline:
        AppFeedback.warning(tr.settingsSavedOffline);
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.settings,
    child: ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        PageHeader(title: tr.navServerDisplay, subtitle: tr.settingsSubtitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (controller.isFirstLaunch) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.crm.infoContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.waving_hand_outlined),
                          SizedBox(width: 12),
                          Expanded(child: Text(tr.firstLaunchHint)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _ServerCard(controller, onSave: _save),
                  const SizedBox(height: 16),
                  const _AppearanceCard(),
                  const SizedBox(height: 16),
                  const _AboutCard(),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ServerCard extends StatelessWidget {
  const _ServerCard(this.c, {required this.onSave});

  final ConnectionSettingsController c;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.settingsServerTitle,
    icon: Icons.dns_outlined,
    subtitle: tr.settingsServerSubtitle,
    child: Form(
      key: c.formKey,
      child: Obx(() {
        final status = c.testStatus.value;
        final crm = context.crm;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: c.baseUrl,
              decoration: InputDecoration(
                labelText: tr.fieldApiAddress,
                hintText: AppConfig.defaultApiBaseUrl,
                helperText: tr.apiAddressHelp,
                prefixIcon: Icon(Icons.link, size: 20),
              ),
              validator: c.validateUrl,
              onChanged: (_) => c.onUrlChanged(),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(tr.fieldTimeout, style: context.text.bodyMedium),
                Expanded(
                  child: Slider(
                    value: c.timeoutSeconds.value.toDouble(),
                    min: AppConfig.minTimeoutSeconds.toDouble(),
                    max: 60,
                    divisions: 57,
                    label: tr.secondsShort(c.timeoutSeconds.value),
                    onChanged: (v) => c.setTimeout(v.round()),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(tr.secondsShort(c.timeoutSeconds.value)),
                ),
              ],
            ),
            if (c.testMessage.value != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: status == ConnectionTestStatus.success
                      ? crm.successContainer
                      : crm.dangerContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == ConnectionTestStatus.success
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: status == ConnectionTestStatus.success
                          ? crm.success
                          : crm.danger,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(c.testMessage.value!)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: status == ConnectionTestStatus.testing
                      ? null
                      : c.testConnection,
                  icon: status == ConnectionTestStatus.testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_check, size: 18),
                  label: Text(
                    status == ConnectionTestStatus.testing
                        ? tr.testing
                        : tr.testConnection,
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: c.isSaving.value ? null : onSave,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    c.isSaving.value ? tr.actionSaving : tr.actionSave,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    ),
  );
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsService>();
    return SectionCard(
      title: tr.settingsDisplay,
      icon: Icons.palette_outlined,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.settingsLanguage, style: context.text.labelLarge),
            const SizedBox(height: 4),
            Text(
              tr.settingsLanguageHint,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<Locale>(
              showSelectedIcon: false,
              segments: [
                for (final locale in AppLocales.supported)
                  ButtonSegment(
                    value: locale,
                    label: Text(AppLocales.nativeName(locale)),
                  ),
              ],
              selected: {settings.locale.value},
              onSelectionChanged: (s) => settings.saveLocale(s.first),
            ),
            const SizedBox(height: 18),
            Text(tr.settingsDisplay, style: context.text.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(tr.themeLightShort),
                  icon: const Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(tr.themeDarkShort),
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(tr.themeSystemShort),
                  icon: const Icon(Icons.computer),
                ),
              ],
              selected: {settings.themeMode.value},
              onSelectionChanged: (s) {
                settings.saveThemeMode(s.first);
                Get.changeThemeMode(s.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.settingsAbout,
    icon: Icons.info_outline,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRow(
          label: tr.aboutApplication,
          value: tr.aboutClient(AppConfig.appName),
        ),
        InfoRow(label: tr.aboutVersion, value: '1.0.0'),
        InfoRow(label: tr.aboutData, value: tr.aboutDataBody),
      ],
    ),
  );
}
