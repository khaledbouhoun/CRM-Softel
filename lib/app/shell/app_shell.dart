import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../config/app_config.dart';
import '../../features/prospects/presentation/dialogs/prospect_search_dialog.dart';
import '../config/app_settings_service.dart';
import 'language_menu.dart';
import '../routes/app_routes.dart';
import '../services/connection_service.dart';
import '../theme/app_theme.dart';
import 'navigation.dart';
import '../l10n/l10n.dart';

class _NavItem {
  const _NavItem(this.route, this.label, this.icon, this.selectedIcon);

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

List<_NavItem> get _mainItems => [
  _NavItem(
    Routes.dashboard,
    tr.navDashboard,
    Icons.space_dashboard_outlined,
    Icons.space_dashboard,
  ),
  _NavItem(
    Routes.prospects,
    tr.navProspects,
    Icons.people_alt_outlined,
    Icons.people_alt,
  ),
  _NavItem(
    Routes.pipeline,
    tr.navPipeline,
    Icons.view_kanban_outlined,
    Icons.view_kanban,
  ),
  _NavItem(
    Routes.activities,
    tr.navActivities,
    Icons.history_outlined,
    Icons.history,
  ),
  _NavItem(
    Routes.followUps,
    tr.navFollowUps,
    Icons.event_note_outlined,
    Icons.event_note,
  ),
  _NavItem(
    Routes.products,
    tr.navProducts,
    Icons.inventory_2_outlined,
    Icons.inventory_2,
  ),
];

List<_NavItem> get _settingsItems => [
  _NavItem(
    Routes.stagesSettings,
    tr.navSalesStages,
    Icons.linear_scale_outlined,
    Icons.linear_scale,
  ),
  _NavItem(
    Routes.lossReasonsSettings,
    tr.navLossReasons,
    Icons.report_gmailerrorred_outlined,
    Icons.report,
  ),
  _NavItem(
    Routes.settings,
    tr.navServerDisplay,
    Icons.settings_ethernet_outlined,
    Icons.settings_ethernet,
  ),
];

/// Desktop layout: sidebar navigation + top bar + page content.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.route, required this.child});

  /// Top-level route this page belongs to (selects the sidebar item).
  final String route;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 1180;
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(selected: route, compact: compact),
          Expanded(
            child: Column(
              children: [
                const _TopBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.compact});

  final String selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    return Container(
      width: compact ? 72 : 236,
      color: crm.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (!compact) const SizedBox(width: 20),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: crm.sidebarAccent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.handshake_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 12),
                  Text(
                    AppConfig.appName,
                    style: TextStyle(
                      color: crm.sidebarForeground,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                for (final item in _mainItems) _tile(context, item),
                const SizedBox(height: 18),
                if (!compact)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 8),
                    child: Text(
                      tr.navSettingsSection,
                      style: TextStyle(
                        color: crm.sidebarMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  )
                else
                  Divider(color: crm.sidebarMuted.withValues(alpha: 0.3)),
                for (final item in _settingsItems) _tile(context, item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, _NavItem item) {
    final crm = context.crm;
    final isSelected = selected == item.route;
    final color = isSelected
        ? Colors.white
        : crm.sidebarForeground.withValues(alpha: 0.82);
    final tile = Material(
      color: isSelected ? crm.sidebarSelected : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withValues(alpha: 0.05),
        onTap: () => AppNavigation.goTo(item.route),
        child: Container(
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: BorderDirectional(
                    start: BorderSide(color: crm.sidebarAccent, width: 3),
                  ),
                )
              : null,
          child: Row(
            mainAxisAlignment: compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: 20,
                color: isSelected ? crm.sidebarAccent : color,
              ),
              if (!compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: compact ? Tooltip(message: item.label, child: tile) : tile,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsService>();
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          const _GlobalSearch(),
          const Spacer(),
          Text(
            Formatters.longDate(DateTime.now()),
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          const _ConnectionIndicator(),
          const SizedBox(width: 4),
          const LanguageMenuButton(),
          Obx(() {
            final dark = settings.themeMode.value == ThemeMode.dark;
            return IconButton(
              tooltip: dark ? tr.themeToggleToLight : tr.themeToggleToDark,
              icon: Icon(
                dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                final mode = dark ? ThemeMode.light : ThemeMode.dark;
                settings.saveThemeMode(mode);
                Get.changeThemeMode(mode);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _GlobalSearch extends StatefulWidget {
  const _GlobalSearch();

  @override
  State<_GlobalSearch> createState() => _GlobalSearchState();
}

class _GlobalSearchState extends State<_GlobalSearch> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 380,
    child: TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: tr.globalSearchHint,
        prefixIcon: const Icon(Icons.search, size: 20),
        fillColor: context.colors.surfaceContainerHigh.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      onSubmitted: (value) async {
        final query = value.trim();
        _controller.clear();
        // Same lookup as everywhere else: all stages, with each stage shown.
        final prospect = await showProspectSearchDialog(initialQuery: query);
        if (prospect != null) AppNavigation.openProspect(prospect.id);
      },
    ),
  );
}

class _ConnectionIndicator extends StatelessWidget {
  const _ConnectionIndicator();

  @override
  Widget build(BuildContext context) {
    final service = Get.find<ConnectionService>();
    final settings = Get.find<AppSettingsService>();
    final crm = context.crm;
    return Obx(() {
      final (color, label) = switch (service.status.value) {
        ConnectionStatus.online => (crm.success, tr.connOnline),
        ConnectionStatus.offline => (crm.danger, tr.connOffline),
        ConnectionStatus.checking => (crm.warning, tr.connChecking),
        ConnectionStatus.unknown => (context.colors.outline, tr.connUnknown),
      };
      final error = service.lastError.value;
      final tooltip = StringBuffer(tr.connServer(settings.apiBaseUrl.value));
      if (error != null) tooltip.write('\n${error.message}');
      if (service.lastCheckedAt.value != null) {
        tooltip.write(
          tr.connLastCheck(Formatters.time(service.lastCheckedAt.value)),
        );
      }
      tooltip.write(tr.connClickToCheck);
      return Tooltip(
        message: tooltip.toString(),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: service.checkNow,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
