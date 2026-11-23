import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../features/workflow_settings/domain/workflow_config_repository.dart';
import '../l10n/l10n.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import 'navigation.dart';

/// Hugeicons icon data.
typedef HugeData = List<List<dynamic>>;

/// One settings page (or one section of the "workflow" page).
class SettingsEntry {
  const SettingsEntry(this.route, this.label, {this.section});

  final String route;

  /// Section of [Routes.workflowSettings] (`scheduling` or a config entity).
  final String? section;
  final String Function() label;

  bool matches(String currentRoute, String? currentSection) =>
      route == currentRoute && (section == null || section == currentSection);
}

/// A group of related settings shown as one tab.
class SettingsGroup {
  const SettingsGroup(this.label, this.icon, this.entries);

  final String Function() label;
  final HugeData icon;
  final List<SettingsEntry> entries;
}

/// The five settings groups. Every entry opens an existing page; nothing is
/// duplicated.
abstract final class SettingsNav {
  /// Section of the workflow page to show (set before navigating, consumed by
  /// the page).
  static final request = ValueNotifier<String?>(null);

  static const scheduling = 'scheduling';

  static List<SettingsGroup> get groups => [
    SettingsGroup(() => tr.settingsGroupGeneral, HugeIcons.strokeRoundedSettings02, [
      SettingsEntry(Routes.settings, () => tr.navServerDisplay),
    ]),
    SettingsGroup(() => tr.settingsGroupSales, HugeIcons.strokeRoundedUserGroup, [
      SettingsEntry(Routes.stagesSettings, () => tr.navSalesStages),
      SettingsEntry(Routes.lossReasonsSettings, () => tr.navLossReasons),
      SettingsEntry(
        Routes.prospectListsSettings,
        () => switch (L10n.current.languageCode) {
          'ar' => 'قوائم النماذج',
          'fr' => 'Listes prospect',
          _ => 'Prospect Lists',
        },
      ),
    ]),
    SettingsGroup(() => tr.settingsGroupSchedule, HugeIcons.strokeRoundedCalendar03, [
      SettingsEntry(Routes.workflowSettings, () => tr.wfCfgScheduling, section: scheduling),
      SettingsEntry(Routes.workflowSettings, () => tr.wfCfgHolidays, section: ConfigEntities.holidays),
      SettingsEntry(Routes.workflowSettings, () => tr.wfCfgTemplates, section: ConfigEntities.messageTemplates),
    ]),
    SettingsGroup(() => tr.settingsGroupCatalog, HugeIcons.strokeRoundedPackage, [
      SettingsEntry(Routes.workflowSettings, () => tr.wfCfgProductResources, section: ConfigEntities.productResources),
      SettingsEntry(Routes.products, () => tr.navProducts),
    ]),
    SettingsGroup(() => tr.settingsGroupAfterSales, HugeIcons.strokeRoundedHeadset, [
      SettingsEntry(Routes.workflowSettings, () => tr.wfCfgInterventionTypes, section: ConfigEntities.interventionTypes),
      SettingsEntry(Routes.workflowSettings, () => tr.wfCfgInterventionStatuses, section: ConfigEntities.interventionStatuses),
      SettingsEntry(Routes.workflowSettings, () => tr.wfCfgTransitions, section: ConfigEntities.interventionTransitions),
      SettingsEntry(Routes.workflowSettings, () => tr.wfCfgPriorities, section: ConfigEntities.interventionPriorities),
      SettingsEntry(Routes.workflowSettings, () => tr.wfCfgAppointmentTypes, section: ConfigEntities.appointmentTypes),
    ]),
  ];

  /// Group that holds the page/section, or null when it is not a settings page.
  /// The products page is a main page, not a settings page.
  static SettingsGroup? groupOf(String route, String? section) {
    if (route == Routes.products) return null;
    for (final g in groups) {
      if (g.entries.any((e) => e.matches(route, section))) return g;
    }
    return null;
  }

  static bool isSettingsRoute(String route) =>
      route != Routes.products &&
      groups.any((g) => g.entries.any((e) => e.route == route));

  /// `Settings › Group › Entry` for the breadcrumb, or null.
  static String? trail(String route, String? section) {
    final g = groupOf(route, section);
    if (g == null) return null;
    final e = g.entries.firstWhere((e) => e.matches(route, section));
    return [tr.navSettingsSection, g.label(), e.label()].join('  ›  ');
  }

  static void open(SettingsEntry entry) {
    request.value = entry.section;
    AppNavigation.goTo(entry.route);
  }

  /// Reads (and clears) a pending section request. Called by the page when
  /// it is created.
  static String? takeRequest() {
    final v = request.value;
    request.value = null;
    return v;
  }
}

/// Group tabs + the entries of the selected group, shown under the title of
/// every settings page.
class SettingsSubNav extends StatelessWidget {
  const SettingsSubNav({super.key, required this.route, this.section});

  final String route;
  final String? section;

  @override
  Widget build(BuildContext context) {
    final groups = SettingsNav.groups;
    final index = groups.indexWhere(
      (g) => g.entries.any((e) => e.matches(route, section)),
    );
    if (route == Routes.products || index < 0) return const SizedBox.shrink();
    final group = groups[index];
    final scheme = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < groups.length; i++)
                _GroupTab(group: groups[i], selected: groups[i] == group),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in group.entries)
                ChoiceChip(
                  label: Text(e.label()),
                  selected: e.matches(route, section),
                  showCheckmark: false,
                  selectedColor: scheme.primaryContainer,
                  onSelected: (_) => SettingsNav.open(e),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupTab extends StatelessWidget {
  const _GroupTab({required this.group, required this.selected});

  final SettingsGroup group;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Material(
      color: selected ? scheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => SettingsNav.open(group.entries.first),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(icon: group.icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                group.label(),
                style: TextStyle(
                  color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
