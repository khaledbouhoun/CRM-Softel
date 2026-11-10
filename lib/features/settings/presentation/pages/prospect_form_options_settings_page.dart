import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/models/prospect_form_option.dart';
import '../controllers/prospect_form_options_settings_controllers.dart';
import '../widgets/reorderable_settings_list.dart';

class ProspectFormOptionsSettingsPage
    extends GetView<ProspectFormOptionsSettingsController> {
  const ProspectFormOptionsSettingsPage({super.key});

  static String _typeLabel(String type) => switch (type) {
    ProspectFormOption.typeSource => tr.fieldSource,
    ProspectFormOption.typePreviousSoftware => tr.fieldPreviousSoftware,
    ProspectFormOption.typeBusinessActivity => tr.fieldBusinessActivity,
    ProspectFormOption.typeProfession => switch (L10n.current.languageCode) {
      'ar' => 'المهنة',
      'fr' => 'Profession',
      _ => 'Profession',
    },
    _ => type,
  };

  Future<void> _openForm([ProspectFormOption? option]) async {
    final type = controller.selectedType.value;
    final formController = ProspectFormOptionFormController(
      repository: Get.find(),
      type: type,
      initial: option,
    );
    final saved = await showControllerDialog<
      ProspectFormOptionFormController,
      ProspectFormOption
    >(
      controller: formController,
      builder: (c) => _ProspectFormOptionFormDialog(c),
    );
    if (saved == null) {
      controller.noteUnsupported(formController.lastError);
      return;
    }
    AppFeedback.success(
      option == null
          ? 'Option "${saved.name}" added successfully.'
          : 'Option "${saved.name}" updated successfully.',
    );
    await controller.afterMutation();
  }

  Future<void> _toggle(ProspectFormOption opt) async {
    final activate = !opt.isActive;
    if (!activate) {
      final ok = await showConfirmDialog(
        title: tr.deactivateQuestion(opt.name),
        message: 'Deactivating this option will hide it from future prospect selections. Existing prospects will preserve it.',
        confirmLabel: tr.actionDeactivate,
      );
      if (!ok) return;
    }
    final result = await controller.setActive(opt, activate);
    result.isSuccess
        ? AppFeedback.success(
            activate ? 'Option reactivated.' : 'Option deactivated.',
          )
        : AppFeedback.error(result.error!);
  }

  Future<void> _delete(ProspectFormOption opt) async {
    final ok = await showConfirmDialog(
      title: tr.deleteQuestion(opt.name),
      message: 'Are you sure you want to delete "${opt.name}"? This cannot be undone.',
      confirmLabel: tr.actionDelete,
      destructive: true,
    );
    if (!ok) return;

    final result = await controller.delete(opt);
    if (result.isSuccess) {
      AppFeedback.success('Option deleted successfully.');
    } else {
      AppFeedback.error(
        result.error!,
        prefix: 'Cannot delete: ',
      );
    }
  }

  Future<void> _move(int from, int to) async {
    final result = await controller.move(from, to);
    if (!result.isSuccess) {
      AppFeedback.error(result.error!, prefix: tr.orderNotSaved);
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.prospectListsSettings,
    child: Obx(() {
      final readOnly = controller.isReadOnly.value;
      final currentType = controller.selectedType.value;
      final currentItems = controller.currentOptions;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: switch (L10n.current.languageCode) {
              'ar' => 'قوائم نماذج العملاء المحتملين',
              'fr' => 'Listes du formulaire prospect',
              _ => 'Prospect Form Lists',
            },
            subtitle: switch (L10n.current.languageCode) {
              'ar' => 'إدارة خيارات القوائم المنسدلة في نموذج العميل المحتمل وتحديد الحقول التي تتطلب تفاصيل إضافية.',
              'fr' => 'Gérer les options des listes déroulantes du formulaire prospect et configurer les précisions requises.',
              _ => 'Manage dropdown options in the prospect form and configure required detail fields.',
            },
            actions: [
              OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
              if (!readOnly)
                FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('New ${_typeLabel(currentType)}'),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  for (final t in ProspectFormOption.allTypes)
                    ButtonSegment(
                      value: t,
                      label: Text(_typeLabel(t)),
                      icon: Icon(switch (t) {
                        ProspectFormOption.typeSource => Icons.campaign_outlined,
                        ProspectFormOption.typePreviousSoftware => Icons.apps_outlined,
                        ProspectFormOption.typeBusinessActivity => Icons.storefront_outlined,
                        ProspectFormOption.typeProfession => Icons.work_outline,
                        _ => Icons.list,
                      }, size: 18),
                    ),
                ],
                selected: {currentType},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) controller.selectType(set.first);
                },
              ),
            ),
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
                child: const Text('Options management is currently read-only.'),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: LoadStateView(
                  state: controller.state,
                  isEmpty: currentItems.isEmpty,
                  onRetry: controller.load,
                  empty: EmptyView(
                    icon: Icons.list_alt,
                    title: 'No options found for ${_typeLabel(currentType)}.',
                  ),
                  builder: (_) => ReorderableSettingsList<ProspectFormOption>(
                    items: currentItems,
                    enabled: !readOnly && !controller.isSavingOrder.value,
                    keyOf: (o) => o.id,
                    onMove: _move,
                    itemBuilder: (context, opt) => Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    opt.name,
                                    style: context.text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: opt.isActive
                                          ? null
                                          : context.colors.outline,
                                    ),
                                  ),
                                  if (opt.requiresDetails) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.secondaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_note,
                                            size: 14,
                                            color: context.colors.onSecondaryContainer,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            tr.detailsRequired,
                                            style: context.text.labelSmall?.copyWith(
                                              color: context.colors.onSecondaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (!opt.isActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tr.statusInactive,
                                        style: context.text.labelSmall?.copyWith(
                                          color: context.colors.outline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: opt.isActive,
                          onChanged: readOnly ? null : (_) => _toggle(opt),
                        ),
                        if (!readOnly) ...[
                          IconButton(
                            tooltip: tr.actionEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _openForm(opt),
                          ),
                          IconButton(
                            tooltip: tr.actionDelete,
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: context.colors.error,
                            ),
                            onPressed: () => _delete(opt),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }),
  );
}

class _ProspectFormOptionFormDialog extends StatelessWidget {
  const _ProspectFormOptionFormDialog(this.c);

  final ProspectFormOptionFormController c;

  Future<void> _submit() async {
    final result = await c.submit();
    if (result != null) Get.back(result: result);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: c.isEdit
          ? 'Edit Option'
          : 'New ${ProspectFormOptionsSettingsPage._typeLabel(c.type)} Option',
      icon: Icons.list_alt,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Form(
        key: c.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: c.name,
              autofocus: true,
              decoration: InputDecoration(
                labelText: tr.validFieldName,
                errorText: c.serverErrors['name'],
                prefixIcon: const Icon(Icons.label_outline),
              ),
              validator: c.validateName,
              onChanged: (_) => c.serverErrors.remove('name'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr.detailsRequired),
              subtitle: const Text(
                'Require additional details text when this value is selected in the prospect form.',
              ),
              value: c.requiresDetails.value,
              onChanged: (v) => c.requiresDetails.value = v,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr.reasonActive),
              subtitle: const Text('Inactive options are hidden from new prospect selections.'),
              value: c.isActive.value,
              onChanged: (v) => c.isActive.value = v,
            ),
          ],
        ),
      ),
    ),
  );
}
