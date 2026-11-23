import 'package:flutter/material.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../data/models/billing_models.dart';

String maintenanceStatusLabel(String status) => switch (status) {
  MaintenanceStatus.active => tr.blStatusActive,
  MaintenanceStatus.expiringSoon => tr.blStatusExpiringSoon,
  MaintenanceStatus.expired => tr.blStatusExpired,
  _ => tr.blStatusNone,
};

Color maintenanceStatusColor(BuildContext context, String status) =>
    switch (status) {
      MaintenanceStatus.active => context.crm.success,
      MaintenanceStatus.expiringSoon => context.crm.warning,
      MaintenanceStatus.expired => context.crm.danger,
      _ => context.colors.onSurfaceVariant,
    };

class MaintenanceStatusBadge extends StatelessWidget {
  const MaintenanceStatusBadge(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) => StatusBadge(
    label: maintenanceStatusLabel(status),
    color: maintenanceStatusColor(context, status),
  );
}
