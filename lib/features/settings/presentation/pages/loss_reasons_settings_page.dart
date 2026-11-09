import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/models/loss_reason.dart';
import '../controllers/loss_reasons_settings_controllers.dart';
import '../widgets/reorderable_settings_list.dart';
import '../../../../app/l10n/l10n.dart';

class LossReasonsSettingsPage extends GetView<LossReasonsSettingsController> {
  const LossReasonsSettingsPage({super.key});

  Future<void> _openForm([LossReason? reason]) async {
    final formController = LossReasonFormController(
      repository: Get.find(),
      initial: reason,
    );
    final saved =
        await showControllerDialog<LossReasonFormController, LossReason>(
          controller: formController,
          builder: (c) => _LossReasonFormDialog(c),
        );
    if (saved == null) {
      controller.noteUnsupported(formController.lastError);
      return;
    }
    AppFeedback.success(reason == null ? tr.reasonAdded : tr.reasonUpdated);
    await controller.afterMutation();
  }

  Future<void> _toggle(LossReason r) async {
    final activate = !r.isActive;
    if (!activate) {
      final ok = await showConfirmDialog(
        title: tr.deactivateQuestion(r.label),
        message: tr.deactivateReasonBody,
        confirmLabel: tr.actionDeactivate,
      );
      if (!ok) return;
    }
    final result = await controller.setActive(r, activate);
    result.isSuccess
        ? AppFeedback.success(
            activate ? tr.reasonReactivated : tr.reasonDeactivated,
          )
        : AppFeedback.error(result.error!);
  }

  Future<void> _move(int from, int to) async {
    final result = await controller.move(from, to);
    if (!result.isSuccess) {
      AppFeedback.error(result.error!, prefix: tr.orderNotSaved);
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.lossReasonsSettings,
    child: Obx(() {
      final readOnly = controller.isReadOnly.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: tr.navLossReasons,
            subtitle: tr.lossReasonsSubtitle,
            actions: [
              OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
              if (!readOnly)
                FilledButton.icon(
                  onPressed: _openForm,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(tr.newReason),
                ),
            ],
          ),
          if (readOnly)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.crm.warningContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tr.lossReasonsReadOnly),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RefreshingBar(
                      visible:
                          controller.isSavingOrder.value ||
                          (controller.state.isLoading &&
                              controller.reasons.isNotEmpty),
                    ),
                    Expanded(
                      child: LoadStateView(
                        state: controller.state,
                        isEmpty: controller.reasons.isEmpty,
                        onRetry: controller.load,
                        empty: EmptyView(
                          icon: Icons.report_gmailerrorred_outlined,
                          title: tr.noLossReasons,
                          message: tr.noActiveReasonWarning,
                        ),
                        builder: (_) => ReorderableSettingsList<LossReason>(
                          items: controller.reasons.toList(),
                          keyOf: (r) => r.id,
                          enabled: !readOnly && !controller.isSavingOrder.value,
                          onMove: _move,
                          itemBuilder: (context, r) => _ReasonRow(
                            reason: r,
                            readOnly: readOnly,
                            busy: controller.busyIds.contains(r.id),
                            onEdit: () => _openForm(r),
                            onToggle: () => _toggle(r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }),
  );
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({
    required this.reason,
    required this.readOnly,
    required this.busy,
    required this.onEdit,
    required this.onToggle,
  });

  final LossReason reason;
  final bool readOnly;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          reason.label,
          style: context.text.titleSmall?.copyWith(
            color: reason.isActive ? null : context.colors.outline,
          ),
        ),
      ),
      SizedBox(
        width: 170,
        child: reason.requiresDetails
            ? StatusPill(
                label: tr.detailsRequired,
                color: context.crm.info,
                icon: Icons.edit_note,
              )
            : null,
      ),
      SizedBox(
        width: 90,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: reason.isActive
              ? StatusPill(label: tr.statusActive, color: context.crm.success)
              : StatusPill(
                  label: tr.statusInactive,
                  color: context.colors.outline,
                ),
        ),
      ),
      if (!readOnly) ...[
        Tooltip(
          message: reason.isActive ? tr.actionDeactivate : tr.actionReactivate,
          child: Switch(
            value: reason.isActive,
            onChanged: busy ? null : (_) => onToggle(),
          ),
        ),
        IconButton(
          tooltip: tr.actionEdit,
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: busy ? null : onEdit,
        ),
      ],
    ],
  );
}

class _LossReasonFormDialog extends StatelessWidget {
  const _LossReasonFormDialog(this.c);

  final LossReasonFormController c;

  Future<void> _submit() async {
    final saved = await c.submit();
    if (saved != null) Get.back(result: saved);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: c.isEdit ? tr.editReason : tr.newLossReason,
      icon: Icons.report_gmailerrorred_outlined,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Form(
        key: c.formKey,
        child: Column(
          children: [
            TextFormField(
              controller: c.label,
              autofocus: true,
              decoration: InputDecoration(
                labelText: tr.fieldLabelRequired,
                hintText: tr.reasonLabelHint,
              ),
              validator: c.validateLabel,
              onChanged: (_) => c.serverErrors.remove('label'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr.detailsMandatory),
              subtitle: Text(tr.detailsMandatoryHint),
              value: c.requiresDetails.value,
              onChanged: (v) => c.requiresDetails.value = v,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr.reasonActive),
              value: c.isActive.value,
              onChanged: (v) => c.isActive.value = v,
            ),
          ],
        ),
      ),
    ),
  );
}
