import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../data/models/customer_models.dart';
import '../../domain/customers_repository.dart';
import '../../../../core/widgets/animated_entrance.dart';

/// Copies a demo link to the clipboard.
Future<void> copyDemoLink(String url) async {
  await Clipboard.setData(ClipboardData(text: url));
  AppFeedback.success(tr.demoLinkCopied);
}

/// Opens a demo link in the default browser.
Future<void> launchDemoLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    AppFeedback.error(url);
  }
}

/// Details of one trial with copy / open actions and, while it can still be
/// revoked, the revoke action. Resolves with true when the trial changed.
Future<bool> showTrialDetailsDialog(Trial trial) async =>
    await showAppDialog<bool>(_TrialDetailsDialog(trial)) ?? false;

class _TrialDetailsDialog extends StatefulWidget {
  const _TrialDetailsDialog(this.trial);

  final Trial trial;

  @override
  State<_TrialDetailsDialog> createState() => _TrialDetailsDialogState();
}

class _TrialDetailsDialogState extends State<_TrialDetailsDialog> {
  bool _busy = false;

  Future<void> _revoke() async {
    final t = widget.trial;
    final ok = await showConfirmDialog(
      title: tr.wfRevokeTrialTitle,
      message: tr.wfRevokeTrialBody(t.product.name),
      confirmLabel: tr.wfRevoke,
      destructive: true,
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await Get.find<CustomersRepository>().revokeTrial(t.id);
      AppFeedback.success(tr.wfTrialRevokedDone);
      Get.back(result: true);
    } catch (e) {
      AppFeedback.error(ApiException.from(e).message);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trial;
    final url = t.url;
    final hasUrl = url != null && url.isNotEmpty;
    return AlertDialog(
      title: Text(t.product.name),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoRow(
              label: tr.wfTrials,
              child: StatusBadge(
                label: t.stateLabel,
                color: t.isActive ? context.crm.success : context.colors.outline,
              ),
            ),
            InfoRow(label: tr.trialFieldPeriod, value: '${Formatters.date(t.startsAt)} → ${Formatters.date(t.endsAt)}'),
            InfoRow(label: tr.trialFieldCreatedBy, value: t.createdBy),
            InfoRow(label: tr.fieldNotes, value: t.internalNotes),
            if (hasUrl)
              InfoRow(
                label: tr.trialFieldLink,
                child: Row(
                  children: [
                    Flexible(child: SelectableText(url)),
                    IconButton(
                      tooltip: tr.copyDemoLink,
                      icon: const HugeIcon(icon: HugeIcons.strokeRoundedLink01, size: 18),
                      onPressed: () => copyDemoLink(url),
                    ),
                    IconButton(
                      tooltip: tr.openDemoLink,
                      icon: const HugeIcon(icon: HugeIcons.strokeRoundedLinkSquare02, size: 18),
                      onPressed: () => launchDemoLink(url),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (t.canRevoke)
          TextButton(
            onPressed: _busy ? null : _revoke,
            child: Text(tr.wfRevoke, style: TextStyle(color: context.crm.danger)),
          ),
        TextButton(onPressed: () => Get.back(result: false), child: Text(tr.actionClose)),
      ],
    );
  }
}
