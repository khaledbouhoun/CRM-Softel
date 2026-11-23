import 'package:flutter/material.dart';

import '../../../app/l10n/l10n.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/huge_data.dart';
import 'package:hugeicons/hugeicons.dart';

/// Department / role of a workstation (values match the API).
enum EmployeeRole {
  sales('sales'),
  support('support'),
  management('management'),
  training('training');

  const EmployeeRole(this.value);
  final String value;

  static EmployeeRole parse(String? value) => EmployeeRole.values.firstWhere(
    (r) => r.value == value,
    orElse: () => EmployeeRole.sales,
  );

  String get label => switch (this) {
    sales => tr.empRoleSales,
    support => tr.empRoleSupport,
    management => tr.empRoleManagement,
    training => tr.empRoleTraining,
  };

  HugeData get icon => switch (this) {
    sales => HugeIcons.strokeRoundedBriefcase01,
    support => HugeIcons.strokeRoundedCustomerService,
    management => HugeIcons.strokeRoundedUserSettings01,
    training => HugeIcons.strokeRoundedUserGroup,
  };

  /// Sales blue, support purple, management gold, training teal.
  Color get color => switch (this) {
    sales => const Color(0xFF2563EB),
    support => const Color(0xFF7C3AED),
    management => const Color(0xFFCA8A04),
    training => const Color(0xFF0D9488),
  };
}

/// Presence of an employee (values match the API).
enum EmployeePresence {
  available('available'),
  busy('busy'),
  away('away'),
  onBreak('break');

  const EmployeePresence(this.value);
  final String value;

  static EmployeePresence parse(String? value) =>
      EmployeePresence.values.firstWhere(
        (p) => p.value == value,
        orElse: () => EmployeePresence.available,
      );

  String get label => switch (this) {
    available => tr.empPresenceAvailable,
    busy => tr.empPresenceBusy,
    away => tr.empPresenceAway,
    onBreak => tr.empPresenceBreak,
  };

  HugeData get icon => switch (this) {
    available => HugeIcons.strokeRoundedCheckmarkCircle02,
    busy => HugeIcons.strokeRoundedCall,
    away => HugeIcons.strokeRoundedLocation01,
    onBreak => HugeIcons.strokeRoundedTimer02,
  };

  Color color(BuildContext context) => switch (this) {
    available => context.crm.success,
    busy => context.crm.warning,
    away => const Color(0xFFDC2626),
    onBreak => context.colors.outline,
  };
}
