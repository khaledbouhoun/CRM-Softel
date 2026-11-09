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
import '../../data/models/sales_stage.dart';
import '../controllers/stages_settings_controllers.dart';
import '../widgets/reorderable_settings_list.dart';
import '../widgets/stage_widgets.dart';
import '../../../../app/l10n/l10n.dart';

class StagesSettingsPage extends GetView<StagesSettingsController> {
  const StagesSettingsPage({super.key});

  Future<void> _openForm([SalesStage? stage]) async {
    final saved = await showControllerDialog<StageFormController, SalesStage>(
      controller: StageFormController(repository: Get.find(), initial: stage),
      builder: (c) => _StageFormDialog(c),
    );
    if (saved == null) return;
    AppFeedback.success(
      stage == null ? tr.stageCreated(saved.name) : tr.stageUpdated,
    );
    await controller.afterMutation();
  }

  Future<void> _toggle(SalesStage s) async {
    final activate = !s.isActive;
    if (!activate) {
      final count = s.prospectsCount ?? 0;
      final ok = await showConfirmDialog(
        title: tr.deactivateQuestion(s.name),
        message: [
          tr.deactivateStageIntro,
          if (count > 0) tr.deactivateStageProspects(count),
          tr.deactivateStageOutro,
        ].join(' '),
        confirmLabel: tr.actionDeactivate,
      );
      if (!ok) return;
    }
    final result = await controller.setActive(s, activate);
    result.isSuccess
        ? AppFeedback.success(
            activate ? tr.stageReactivated : tr.stageDeactivatedMsg,
          )
        : AppFeedback.error(result.error!);
  }

  Future<void> _delete(SalesStage s) async {
    final ok = await showConfirmDialog(
      title: tr.deleteQuestion(s.name),
      message: tr.deleteStageBody,
      confirmLabel: tr.actionDelete,
      destructive: true,
    );
    if (!ok) return;
    final result = await controller.delete(s);
    result.isSuccess
        ? AppFeedback.success(tr.stageDeleted)
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
    route: Routes.stagesSettings,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: tr.navSalesStages,
          subtitle: tr.stagesSubtitle,
          actions: [
            Obx(
              () => OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ),
            FilledButton.icon(
              onPressed: _openForm,
              icon: const Icon(Icons.add, size: 18),
              label: Text(tr.newStage),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RefreshingBar(
                      visible:
                          controller.isSavingOrder.value ||
                          (controller.state.isLoading &&
                              controller.stages.isNotEmpty),
                    ),
                    if (controller.isSavingOrder.value)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          tr.savingNewOrder,
                          style: context.text.bodySmall,
                        ),
                      ),
                    Expanded(
                      child: LoadStateView(
                        state: controller.state,
                        isEmpty: controller.stages.isEmpty,
                        onRetry: controller.load,
                        empty: EmptyView(
                          icon: Icons.linear_scale,
                          title: tr.noStages,
                          message: tr.createStagesHint,
                          action: FilledButton(
                            onPressed: _openForm,
                            child: Text(tr.createStage),
                          ),
                        ),
                        builder: (_) => ReorderableSettingsList<SalesStage>(
                          items: controller.stages.toList(),
                          keyOf: (s) => s.id,
                          enabled: !controller.isSavingOrder.value,
                          onMove: _move,
                          itemBuilder: (context, s) => _StageRow(
                            stage: s,
                            busy: controller.busyIds.contains(s.id),
                            onEdit: () => _openForm(s),
                            onToggle: () => _toggle(s),
                            onDelete: s.isUsed ? null : () => _delete(s),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.busy,
    required this.onEdit,
    required this.onToggle,
    this.onDelete,
  });

  final SalesStage stage;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: stage.color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 3,
        child: Text(
          stage.name,
          style: context.text.titleSmall?.copyWith(
            color: stage.isActive ? null : context.colors.outline,
          ),
        ),
      ),
      SizedBox(
        width: 120,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: StageTypeBadge(stage.type),
        ),
      ),
      SizedBox(
        width: 120,
        child: Text(
          stage.prospectsCount == null
              ? ''
              : tr.prospectsCountShort(stage.prospectsCount!),
          style: context.text.bodySmall,
        ),
      ),
      SizedBox(
        width: 90,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: stage.isActive
              ? StatusPill(
                  label: tr.statusActiveFem,
                  color: context.crm.success,
                )
              : StatusPill(
                  label: tr.statusInactiveFem,
                  color: context.colors.outline,
                ),
        ),
      ),
      SizedBox(
        width: 28,
        child: stage.isUsed
            ? Tooltip(
                message: tr.stageUsedNoDelete,
                child: Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: context.colors.outline,
                ),
              )
            : null,
      ),
      Tooltip(
        message: stage.isActive ? tr.actionDeactivate : tr.actionReactivate,
        child: Switch(
          value: stage.isActive,
          onChanged: busy ? null : (_) => onToggle(),
        ),
      ),
      IconButton(
        tooltip: tr.actionEdit,
        icon: const Icon(Icons.edit_outlined, size: 20),
        onPressed: busy ? null : onEdit,
      ),
      IconButton(
        tooltip: onDelete == null ? tr.deleteImpossibleUsed : tr.actionDelete,
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: busy ? null : onDelete,
      ),
    ],
  );
}

class _StageFormDialog extends StatelessWidget {
  const _StageFormDialog(this.c);

  final StageFormController c;

  Future<void> _submit() async {
    final saved = await c.submit();
    if (saved != null) Get.back(result: saved);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: c.isEdit ? tr.editStage : tr.newStage,
      icon: Icons.linear_scale,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: c.name,
              autofocus: true,
              decoration: InputDecoration(labelText: tr.fieldNameRequired),
              validator: c.validateName,
              onChanged: (_) => c.serverErrors.remove('name'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<StageType>(
              initialValue: c.type.value,
              decoration: InputDecoration(
                labelText: tr.fieldTypeRequired,
                errorText: c.typeError,
                helperText: c.isTypeLocked
                    ? tr.stageTypeLocked
                    : tr.lostRequiresReasonHint,
                helperMaxLines: 2,
              ),
              items: [
                for (final t in StageType.values)
                  DropdownMenuItem(value: t, child: StageTypeBadge(t)),
              ],
              onChanged: c.isTypeLocked
                  ? null
                  : (t) => c.type.value = t ?? StageType.open,
            ),
            const SizedBox(height: 14),
            ColorPickerField(
              value: c.colorHex.value,
              onChanged: (v) => c.colorHex.value = v,
            ),
            if (c.colorError != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 4, start: 12),
                child: Text(
                  c.colorError!,
                  style: TextStyle(color: context.colors.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr.stageActive),
              value: c.isActive.value,
              onChanged: (v) => c.isActive.value = v,
            ),
          ],
        ),
      ),
    ),
  );
}
