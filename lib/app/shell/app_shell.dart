import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/utils/formatters.dart';
import '../../features/employees/data/employee_options.dart';
import '../../features/prospects/presentation/dialogs/prospect_search_dialog.dart';
import '../config/app_settings_service.dart';
import '../l10n/l10n.dart';
import '../routes/app_routes.dart';
import '../services/connection_service.dart';
import '../services/employee_identity.dart';
import '../services/presence_service.dart';
import '../theme/app_theme.dart';
import 'language_menu.dart';
import 'navigation.dart';
import 'settings_nav.dart';

class _NavItem {
  const _NavItem(this.route, this.label, this.icon, [HugeData? selectedIcon]) : selectedIcon = selectedIcon ?? icon;

  final String route;
  final String label;
  final HugeData icon;
  final HugeData selectedIcon;
}

/// One of the six sidebar workspaces.
class _Workspace {
  const _Workspace(this.label, this.items);

  final String label;
  final List<_NavItem> items;
}

/// Sidebar workspaces. Employees all share the same access level, so every
/// entry is always visible (no role checks).
List<_Workspace> get _workspaces => [
  // 1. Prospects & sales lifecycle.
  _Workspace(tr.navWorkspaceProspects, [
    _NavItem(
      Routes.dashboard,
      tr.navDashboard,
      HugeIcons.strokeRoundedDashboardSquare01,
      HugeIcons.strokeRoundedDashboardSquare02,
    ),
    _NavItem(
      Routes.calendar,
      tr.navCalendar,
      HugeIcons.strokeRoundedCalendar03,
      HugeIcons.strokeRoundedCalendarFavorite01,
    ),
    _NavItem(Routes.prospects, tr.navProspects, HugeIcons.strokeRoundedUserGroup),
    _NavItem(Routes.pipeline, tr.navPipeline, HugeIcons.strokeRoundedUserAdd01),
    _NavItem(Routes.followUps, tr.navFollowUps, HugeIcons.strokeRoundedNote01),
    _NavItem(Routes.activities, tr.navActivities, HugeIcons.strokeRoundedTime02),
  ]),
  // 2. Customers & operations.
  _Workspace(tr.navWorkspaceCustomers, [
    _NavItem(Routes.customers, tr.navCustomers, HugeIcons.strokeRoundedBuilding02, HugeIcons.strokeRoundedUserCheck01),
    _NavItem(
      Routes.afterSales,
      tr.navAfterSales,
      HugeIcons.strokeRoundedHeadset,
      HugeIcons.strokeRoundedCustomerService,
    ),
    _NavItem(Routes.training, tr.navTraining, HugeIcons.strokeRoundedMortarboard01),
    _NavItem(Routes.requests, tr.navRequests, HugeIcons.strokeRoundedFile01, HugeIcons.strokeRoundedInvoice01),
  ]),
  // 3. Billing & subscriptions.
  _Workspace(tr.navWorkspaceBilling, [
    _NavItem(Routes.billing, tr.navBilling, HugeIcons.strokeRoundedCreditCard),
  ]),
  // 4. Products & releases.
  _Workspace(tr.navWorkspaceProducts, [
    _NavItem(Routes.products, tr.navProducts, HugeIcons.strokeRoundedPackage),
    _NavItem(
      Routes.releases,
      tr.navReleases,
      HugeIcons.strokeRoundedDownload04,
      HugeIcons.strokeRoundedSoftwareLicense,
    ),
  ]),
  // 5. Team & workstations.
  _Workspace(tr.navWorkspaceTeam, [
    _NavItem(Routes.employees, tr.navEmployees, HugeIcons.strokeRoundedUserSettings01),
  ]),
  // 6. Analytics & reports.
  _Workspace(tr.navWorkspaceAnalytics, [
    _NavItem(Routes.analytics, tr.navAnalytics, HugeIcons.strokeRoundedAnalytics01, HugeIcons.strokeRoundedAnalytics02),
  ]),
];

/// Sidebar collapsed by hand. Global so the choice survives page changes
/// (every page builds its own [AppShell]).
final _sidebarCollapsed = ValueNotifier<bool>(false);

/// Narrow windows collapse the sidebar on their own.
const _autoCompactWidth = 1180.0;

/// Desktop layout: sidebar navigation + top bar + page content.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.route, required this.child, this.crumb, this.settingsSection});

  /// Top-level route this page belongs to (selects the sidebar item).
  final String route;
  final Widget child;

  /// Optional last breadcrumb for detail pages (e.g. a customer name).
  final String? crumb;

  /// Section of the workflow settings page being shown (breadcrumb only).
  final String? settingsSection;

  @override
  Widget build(BuildContext context) {
    final autoCompact = MediaQuery.sizeOf(context).width < _autoCompactWidth;
    return Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: _sidebarCollapsed,
        builder: (context, collapsed, _) => Row(
          children: [
            _Sidebar(selected: route, compact: autoCompact || collapsed, canToggle: !autoCompact),
            Expanded(
              child: Column(
                children: [
                  _TopBar(route: route, crumb: crumb, settingsSection: settingsSection),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.compact, required this.canToggle});

  final String selected;
  final bool compact;
  final bool canToggle;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    return Container(
      width: compact ? 72 : 256,
      decoration: BoxDecoration(
        color: crm.sidebarBackground,
        border: BorderDirectional(end: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                for (final workspace in _workspaces) ...[
                  _workspaceHeader(context, workspace.label),
                  for (final item in workspace.items) _tile(context, item),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
          _footer(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final crm = context.crm;
    final logo = Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
      child: Image.asset(
        'assets/branding/crm-softel-icon.png',
        width: compact ? 36 : 120,
        height: compact ? 36 : 40,
        fit: BoxFit.contain,
      ),
    );
    final toggle = canToggle
        ? IconButton(
            tooltip: tr.navToggleSidebar,
            iconSize: 20,
            color: crm.sidebarMuted,
            onPressed: () => _sidebarCollapsed.value = !_sidebarCollapsed.value,
            icon: HugeIcon(
              // The sidebar sits on the right in RTL, so the arrows flip.
              icon: (compact == (Directionality.of(context) == TextDirection.ltr))
                  ? HugeIcons.strokeRoundedArrowRightDouble
                  : HugeIcons.strokeRoundedArrowLeftDouble,
              color: crm.sidebarMuted,
              size: 20,
            ),
          )
        : null;
    if (compact) {
      return SizedBox(
        height: canToggle ? 108 : 64,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [logo, ?toggle]),
      );
    }
    return SizedBox(
      height: 64,
      child: Row(children: [const SizedBox(width: 18), logo, ?toggle, const SizedBox(width: 6)]),
    );
  }

  Widget _workspaceHeader(BuildContext context, String label) {
    final crm = context.crm;
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: context.colors.outlineVariant),
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 18, 0, 6),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: crm.sidebarMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8),
      ),
    );
  }

  /// Pinned bottom entry: the settings hub (groups live in its sub-navigation).
  Widget _footer(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: context.colors.outlineVariant)),
    ),
    child: _tile(
      context,
      _NavItem(
        Routes.settings,
        tr.navSettingsSection,
        HugeIcons.strokeRoundedSettings02,
        HugeIcons.strokeRoundedConfiguration01,
      ),
      selectedOverride: SettingsNav.isSettingsRoute(selected),
    ),
  );

  Widget _tile(BuildContext context, _NavItem item, {bool? selectedOverride}) {
    final crm = context.crm;
    final isSelected = selectedOverride ?? selected == item.route;
    final color = isSelected ? crm.sidebarForeground : crm.sidebarMuted;
    final tile = Material(
      color: isSelected ? crm.sidebarSelected : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        hoverColor: context.colors.onSurface.withValues(alpha: 0.05),
        onTap: () => AppNavigation.goTo(item.route),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
          child: Row(
            mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              HugeIcon(
                icon: isSelected ? item.selectedIcon : item.icon,
                size: 21,
                strokeWidth: isSelected ? 2 : 1.6,
                color: isSelected ? crm.sidebarAccent : color,
              ),
              if (!compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? crm.sidebarForeground : color,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
  const _TopBar({required this.route, this.crumb, this.settingsSection});

  final String route;
  final String? crumb;
  final String? settingsSection;

  /// `Workspace › Page [› detail]` for the current route, or null.
  String? get _trail {
    for (final w in _workspaces) {
      for (final i in w.items) {
        if (i.route == route) {
          return [w.label, i.label, ?crumb].join('  ›  ');
        }
      }
    }
    final settingsTrail = SettingsNav.trail(route, settingsSection);
    if (settingsTrail != null) {
      return crumb == null ? settingsTrail : '$settingsTrail  ›  $crumb';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsService>();
    final wide = MediaQuery.sizeOf(context).width >= 1500;
    final trail = _trail;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: Row(
        children: [
          // Compact breadcrumb; the search bar takes all the remaining width.
          if (trail != null)
            Flexible(
              flex: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                // One Text so a crumb never duplicates a label elsewhere.
                child: Text(
                  trail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const Expanded(
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: _GlobalSearch()),
          ),
          if (wide)
            Text(
              Formatters.longDate(DateTime.now()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          const SizedBox(width: 12),
          const _ConnectionIndicator(),
          const SizedBox(width: 4),
          const LanguageMenuButton(),
          Obx(() {
            final dark = settings.themeMode.value == ThemeMode.dark;
            return IconButton(
              tooltip: dark ? tr.themeToggleToLight : tr.themeToggleToDark,
              icon: HugeIcon(
                icon: dark ? HugeIcons.strokeRoundedSun03 : HugeIcons.strokeRoundedMoon02,
                color: context.colors.onSurfaceVariant,
                size: 21,
              ),
              onPressed: () {
                final mode = dark ? ThemeMode.light : ThemeMode.dark;
                settings.saveThemeMode(mode);
                Get.changeThemeMode(mode);
              },
            );
          }),
          const SizedBox(width: 6),
          const _UserAvatar(),
        ],
      ),
    );
  }
}

/// The staff member using this workstation (Windows user name; the CRM has
/// no per-employee login or roles). The menu switches this workstation's
/// presence (available, in a call, on-site, on break) for the whole team.
class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    final name = Get.isRegistered<EmployeeIdentity>() ? Get.find<EmployeeIdentity>().username : '';
    final scheme = context.colors;
    final avatar = CircleAvatar(
      radius: 16,
      backgroundColor: scheme.primaryContainer,
      child: name.isEmpty
          ? HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 18, color: scheme.onPrimaryContainer)
          : Text(
              name.characters.first.toUpperCase(),
              style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 13),
            ),
    );
    if (!Get.isRegistered<PresenceService>()) {
      return Tooltip(message: name, child: avatar);
    }
    final presence = Get.find<PresenceService>();
    return Obx(() {
      final current = presence.current.value;
      final color = current.color(context);
      return PopupMenuButton<EmployeePresence>(
        tooltip: '$name · ${current.label}',
        position: PopupMenuPosition.under,
        onOpened: presence.refresh,
        onSelected: presence.set,
        itemBuilder: (_) => [
          for (final p in EmployeePresence.values)
            PopupMenuItem(
              value: p,
              child: Row(
                children: [
                  HugeIcon(icon: p.icon, size: 18, color: p.color(context)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p.label)),
                  if (p == current)
                    HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle02, size: 16, color: scheme.primary),
                ],
              ),
            ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                avatar,
                PositionedDirectional(
                  end: -1,
                  bottom: -1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Text(current.label, style: context.text.labelMedium),
          ],
        ),
      );
    });
  }
}

class _GlobalSearch extends StatefulWidget {
  const _GlobalSearch();

  @override
  State<_GlobalSearch> createState() => _GlobalSearchState();
}

class _GlobalSearchState extends State<_GlobalSearch> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Ctrl+K focuses the search, unless a dialog is open on top of the page.
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.keyK ||
        !HardwareKeyboard.instance.isControlPressed) {
      return false;
    }
    if (ModalRoute.of(context)?.isCurrent != true) return false;
    _focus.requestFocus();
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: c, width: w),
    );
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: tr.globalSearchHint,
          hintMaxLines: 1,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: scheme.onSurfaceVariant, size: 18),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Center(
              widthFactor: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Ctrl K',
                  style: context.text.labelSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          fillColor: scheme.surfaceContainerLow,
          border: border(scheme.outlineVariant),
          enabledBorder: border(scheme.outlineVariant),
          focusedBorder: border(BrandColors.primary, 2),
        ),
        onSubmitted: (value) async {
          final query = value.trim();
          _controller.clear();
          // Same lookup as everywhere else: all stages, with each stage shown.
          final prospect = await showProspectSearchDialog(initialQuery: query);
          if (prospect != null) {
            AppNavigation.openRecord(id: prospect.id, isCustomer: prospect.isCustomer);
          }
        },
      ),
    );
  }
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
        tooltip.write(tr.connLastCheck(Formatters.time(service.lastCheckedAt.value)));
      }
      tooltip.write(tr.connClickToCheck);
      return Tooltip(
        message: tooltip.toString(),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: service.checkNow,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12.5),
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
