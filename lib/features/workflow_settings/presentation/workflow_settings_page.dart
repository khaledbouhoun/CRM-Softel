import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/l10n.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/lookup_service.dart';
import '../../../app/services/workflow_lookup_service.dart';
import '../../../app/shell/app_shell.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/crm_data_table.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/layout_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/workflow_widgets.dart';
import '../data/models/config_models.dart';
import '../domain/workflow_config_repository.dart';
import '../data/models/settings_help.dart';
import 'settings_help_button.dart';
import 'config_schema.dart';
import 'workflow_settings_controllers.dart';

/// "Scheduling, appointments and after-sales" settings: everything the
/// workflows need is configured here and served by the CRM.
class WorkflowSettingsPage extends StatefulWidget {
  const WorkflowSettingsPage({super.key});

  @override
  State<WorkflowSettingsPage> createState() => _WorkflowSettingsPageState();
}

class _WorkflowSettingsPageState extends State<WorkflowSettingsPage> {
  /// -1 = scheduling policy, otherwise index into [ConfigSchemas.all].
  int _section = -1;

  @override
  Widget build(BuildContext context) {
    final schemas = ConfigSchemas.all;
    return AppShell(
      route: Routes.workflowSettings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: tr.navWorkflowSettings,
            subtitle: tr.wfSettingsSubtitle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(tr.wfCfgScheduling),
                  selected: _section == -1,
                  onSelected: (_) => setState(() => _section = -1),
                ),
                for (var i = 0; i < schemas.length; i++)
                  ChoiceChip(
                    label: Text(schemas[i].title()),
                    selected: _section == i,
                    onSelected: (_) => setState(() => _section = i),
                  ),
                SettingsHelpButton(
                  key: ValueKey('help-$_section'),
                  section: _section == -1
                      ? 'scheduling'
                      : SettingsHelp.sectionKey(schemas[_section].entity),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
              child: _section == -1
                  ? const _SchedulingForm()
                  : _ConfigListView(
                      key: ValueKey(schemas[_section].entity),
                      schema: schemas[_section],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scheduling policy
// ---------------------------------------------------------------------------

class _SchedulingForm extends StatefulWidget {
  const _SchedulingForm();

  @override
  State<_SchedulingForm> createState() => _SchedulingFormState();
}

class _SchedulingFormState extends State<_SchedulingForm> {
  late final SchedulingSettingsController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(
      SchedulingSettingsController(
        repository: Get.find(),
        workflow: Get.find<WorkflowLookupService>(),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SchedulingSettingsController>();
    super.dispose();
  }

  Widget _number(
    String label,
    TextEditingController controller,
    String key,
    int min,
    int max, {
    String? helper,
  }) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label, helperText: helper),
    autovalidateMode: AutovalidateMode.always,
    validator: (_) => c.validateRange(key, controller, min, max),
    onChanged: (_) => c.serverErrors.remove(key),
  );

  String _weekday(int index) {
    // 0 = Sunday ... 6 = Saturday; 2023-01-01 was a Sunday.
    final day = DateTime(2023, 1, 1 + index);
    final text = DateFormat.EEEE(Formatters.locale).format(day);
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) => LoadStateView(
    state: c.state,
    isEmpty: false,
    onRetry: c.load,
    builder: (_) => Obx(
      () => Card(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(tr.wfCfgSchedulingHint, style: context.text.bodyMedium),
            const SizedBox(height: 16),
            FormSectionLabel(tr.wfWorkingDays),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var d = 0; d < 7; d++)
                  FilterChip(
                    label: Text(_weekday(d)),
                    selected: c.workingDays.contains(d),
                    onSelected: (v) =>
                        v ? c.workingDays.add(d) : c.workingDays.remove(d),
                  ),
              ],
            ),
            if (c.daysError != null && c.showValidation.value)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  c.daysError!,
                  style: TextStyle(color: context.crm.danger),
                ),
              ),
            const SizedBox(height: 16),
            FormRow(
              children: [
                TextFormField(
                  controller: c.workStart,
                  decoration: InputDecoration(
                    labelText: tr.wfWorkStart,
                    hintText: 'HH:mm',
                  ),
                  autovalidateMode: AutovalidateMode.always,
                  validator: (_) => c.validateTime('work_start', c.workStart),
                ),
                TextFormField(
                  controller: c.workEnd,
                  decoration: InputDecoration(
                    labelText: tr.wfWorkEnd,
                    hintText: 'HH:mm',
                  ),
                  autovalidateMode: AutovalidateMode.always,
                  validator: (_) =>
                      c.validateTime('work_end', c.workEnd) ?? c.endError,
                ),
              ],
            ),
            const SizedBox(height: 14),
            FormRow(
              children: [
                _number(
                  tr.wfSlotMinutes,
                  c.slotMinutes,
                  'slot_minutes',
                  5,
                  480,
                ),
                _number(
                  tr.wfHoldExpiryMinutes,
                  c.holdExpiryMinutes,
                  'hold_expiry_minutes',
                  5,
                  43200,
                  helper: tr.wfHoldExpiryHint,
                ),
              ],
            ),
            const SizedBox(height: 14),
            FormRow(
              children: [
                _number(
                  tr.wfBookingHorizon,
                  c.bookingHorizonDays,
                  'booking_horizon_days',
                  1,
                  365,
                ),
                _number(
                  tr.wfMinNotice,
                  c.minNoticeHours,
                  'min_notice_hours',
                  0,
                  720,
                ),
                _number(
                  tr.wfDemoCapacity,
                  c.demoCapacity,
                  'demo_capacity',
                  1,
                  50,
                  helper: tr.wfDemoCapacityHint,
                ),
              ],
            ),
            const SizedBox(height: 14),
            FormRow(
              children: [
                _number(
                  tr.wfAccompanimentOccurrences,
                  c.accompanimentOccurrences,
                  'accompaniment_occurrences',
                  1,
                  52,
                ),
                _number(
                  tr.wfAccompanimentInterval,
                  c.accompanimentIntervalDays,
                  'accompaniment_interval_days',
                  1,
                  365,
                ),
                _number(
                  tr.wfTrialDays,
                  c.trialDefaultDays,
                  'trial_default_days',
                  1,
                  365,
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 260,
              child: TextFormField(
                controller: c.whatsappCountryCode,
                decoration: InputDecoration(
                  labelText: tr.wfWhatsappCountryCode,
                  helperText: tr.wfWhatsappCountryCodeHint,
                  helperMaxLines: 2,
                ),
                autovalidateMode: AutovalidateMode.always,
                validator: c.validateCountryCode,
              ),
            ),
            if (c.errorMessage.value != null) ...[
              const SizedBox(height: 14),
              ErrorBanner(message: c.errorMessage.value!),
            ],
            const SizedBox(height: 18),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                onPressed: c.isSaving.value
                    ? null
                    : () async {
                        if (await c.save()) {
                          AppFeedback.success(tr.wfSettingsSaved);
                        }
                      },
                icon: c.isSaving.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(c.isSaving.value ? tr.actionSaving : tr.actionSave),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Generic configuration list
// ---------------------------------------------------------------------------

class _ConfigListView extends StatefulWidget {
  const _ConfigListView({super.key, required this.schema});

  final ConfigSchema schema;

  @override
  State<_ConfigListView> createState() => _ConfigListViewState();
}

class _ConfigListViewState extends State<_ConfigListView> {
  late final ConfigEntityController c;

  String get _tag => 'config-${widget.schema.entity}';

  @override
  void initState() {
    super.initState();
    c = Get.put(
      ConfigEntityController(
        schema: widget.schema,
        repository: Get.find(),
        workflow: Get.find<WorkflowLookupService>(),
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<ConfigEntityController>(tag: _tag);
    super.dispose();
  }

  Future<void> _edit([ConfigRow? row]) async {
    final saved = await showControllerDialog<ConfigFormController, ConfigRow>(
      controller: ConfigFormController(
        schema: widget.schema,
        list: c,
        existing: row,
      ),
      builder: (f) => ConfigFormDialog(f),
    );
    if (saved != null) AppFeedback.success(tr.wfSaved);
  }

  Future<void> _toggle(ConfigRow row) async {
    if (row.isActive) {
      final ok = await showConfirmDialog(
        title: tr.wfDeactivateTitle,
        message: tr.wfDeactivateBody,
        confirmLabel: tr.actionDeactivate,
      );
      if (!ok) return;
    }
    final result = await c.toggleActive(row);
    result.isSuccess
        ? AppFeedback.success(
            row.isActive ? tr.wfDeactivated : tr.wfReactivated,
          )
        : AppFeedback.error(result.error!);
  }

  String _cell(ConfigField f, ConfigRow row) {
    final value = row.data[f.key];
    switch (f.kind) {
      case ConfigFieldKind.boolean:
        return row.boolValue(f.key) ? tr.wfYes : tr.wfNo;
      case ConfigFieldKind.choice:
        final v = row.str(f.key);
        return f.options.where((o) => o.value == v).firstOrNull?.label() ??
            (v ?? '');
      case ConfigFieldKind.status:
        final id = row.intValue(f.key);
        return Get.find<WorkflowLookupService>().statusById(id)?.name ??
            '${id ?? ''}';
      case ConfigFieldKind.product:
        final id = row.intValue(f.key);
        final products = Get.find<LookupService>().products;
        return products.firstWhereOrNull((p) => p.id == id)?.name ??
            '${id ?? ''}';
      case ConfigFieldKind.date:
        return Formatters.date(DateTime.tryParse('${value ?? ''}'));
      default:
        return value == null ? '' : '$value';
    }
  }

  @override
  Widget build(BuildContext context) {
    final schema = widget.schema;
    // The four appointment types (Demo, Meeting, Training, Accompaniment) are
    // fixed: no creation and no deactivation, only duration/colour/booking.
    final fixed = schema.entity == ConfigEntities.appointmentTypes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                fixed ? '${schema.hint()}\n${tr.wfFixedTypesNote}' : schema.hint(),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            Obx(
              () => FilterChip(
                label: Text(tr.showInactiveProducts),
                selected: c.showInactive.value,
                onSelected: (v) => c.showInactive.value = v,
              ),
            ),
            const SizedBox(width: 8),
            if (!fixed)
              FilledButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.add, size: 18),
                label: Text(tr.actionAdd),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Obx(() {
              final rows = c.visibleRows;
              return Column(
                children: [
                  RefreshingBar(visible: c.state.isLoading && rows.isNotEmpty),
                  Expanded(
                    child: LoadStateView(
                      state: c.state,
                      isEmpty: rows.isEmpty,
                      onRetry: c.load,
                      empty: EmptyView(
                        icon: Icons.tune,
                        title: tr.wfNoConfigRows,
                        message: tr.wfNoConfigRowsHint,
                      ),
                      builder: (_) => CrmDataTable<ConfigRow>(
                        rows: rows,
                        onRowTap: _edit,
                        columns: [
                          for (final f in schema.tableFields)
                            if (f.kind == ConfigFieldKind.color)
                              CrmColumn<ConfigRow>(
                                label: f.label(),
                                width: 80,
                                cell: (r) => Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: hexColor(
                                      r.str(f.key),
                                      context.colors.outline,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            else
                              CrmColumn<ConfigRow>(
                                label: f.label(),
                                flex: f.kind == ConfigFieldKind.multiline
                                    ? 4
                                    : 2,
                                cell: (r) => CellText(
                                  _cell(f, r),
                                  bold: f == schema.tableFields.first,
                                  color: r.isActive
                                      ? null
                                      : context.colors.outline,
                                ),
                              ),
                          CrmColumn<ConfigRow>(
                            label: tr.colStatus,
                            width: 100,
                            cell: (r) => StatusBadge(
                              label: r.isActive
                                  ? tr.statusActive
                                  : tr.statusInactive,
                              color: r.isActive
                                  ? context.crm.success
                                  : context.colors.outline,
                            ),
                          ),
                          CrmColumn<ConfigRow>(
                            label: '',
                            width: 130,
                            alignment: AlignmentDirectional.centerEnd,
                            cell: (r) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!fixed)
                                  Obx(
                                    () => Switch(
                                      value: r.isActive,
                                      onChanged: c.busyIds.contains(r.id)
                                          ? null
                                          : (_) => _toggle(r),
                                    ),
                                  ),
                                IconButton(
                                  tooltip: tr.actionEdit,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => _edit(r),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Create / edit dialog of one configuration row (also used by the product
/// resources dialog).
class ConfigFormDialog extends StatelessWidget {
  const ConfigFormDialog(this.f, {super.key});

  final ConfigFormController f;

  Future<void> _submit() async {
    final saved = await f.submit();
    if (saved != null) Get.back(result: saved);
  }

  Widget _field(BuildContext context, ConfigField field) {
    final enabled = !(f.isEdit && field.immutable);
    switch (field.kind) {
      case ConfigFieldKind.text:
      case ConfigFieldKind.multiline:
      case ConfigFieldKind.url:
      case ConfigFieldKind.integer:
        return TextFormField(
          controller: f.texts[field.key],
          enabled: enabled,
          minLines: field.kind == ConfigFieldKind.multiline ? 4 : 1,
          maxLines: field.kind == ConfigFieldKind.multiline ? 10 : 1,
          keyboardType: field.kind == ConfigFieldKind.integer
              ? TextInputType.number
              : (field.kind == ConfigFieldKind.url ? TextInputType.url : null),
          decoration: InputDecoration(
            labelText: field.required ? '${field.label()} *' : field.label(),
            helperText: field.hint?.call(),
            helperMaxLines: 3,
            alignLabelWithHint: field.kind == ConfigFieldKind.multiline,
          ),
          autovalidateMode: f.showValidation.value
              ? AutovalidateMode.always
              : AutovalidateMode.onUserInteraction,
          validator: (_) => f.validate(field),
          onChanged: (_) => f.serverErrors.remove(field.key),
        );
      case ConfigFieldKind.boolean:
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(field.label()),
          value: f.bools[field.key] ?? false,
          onChanged: (v) => f.bools[field.key] = v,
        );
      case ConfigFieldKind.color:
        return ColorPickerField(
          label: field.label(),
          value: f.choices[field.key] ?? '#64748B',
          onChanged: (v) => f.choices[field.key] = v,
        );
      case ConfigFieldKind.choice:
        return DropdownButtonFormField<String>(
          initialValue: f.choices[field.key],
          isExpanded: true,
          decoration: InputDecoration(
            labelText: field.label(),
            errorText: f.showValidation.value ? f.validate(field) : null,
          ),
          items: [
            for (final o in field.options)
              DropdownMenuItem(value: o.value, child: Text(o.label())),
          ],
          onChanged: enabled ? (v) => f.choices[field.key] = v : null,
        );
      case ConfigFieldKind.date:
        final current = DateTime.tryParse(f.choices[field.key] ?? '');
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: current ?? now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 10),
            );
            if (picked != null) {
              f.choices[field.key] = toApiDate(picked);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: field.label(),
              prefixIcon: const Icon(Icons.event, size: 20),
              errorText: f.showValidation.value ? f.validate(field) : null,
            ),
            child: Text(current == null ? '' : Formatters.date(current)),
          ),
        );
      case ConfigFieldKind.status:
        final workflow = Get.find<WorkflowLookupService>();
        return DropdownButtonFormField<int>(
          initialValue: f.ids[field.key],
          isExpanded: true,
          decoration: InputDecoration(
            labelText: field.label(),
            errorText: f.showValidation.value ? f.validate(field) : null,
          ),
          items: [
            for (final s in workflow.interventionStatuses.where(
              (s) => s.isActive,
            ))
              DropdownMenuItem(value: s.id, child: Text(s.name)),
          ],
          onChanged: enabled ? (v) => f.ids[field.key] = v : null,
        );
      case ConfigFieldKind.product:
        final lookups = Get.find<LookupService>();
        return DropdownButtonFormField<int>(
          initialValue: f.ids[field.key],
          isExpanded: true,
          decoration: InputDecoration(
            labelText: field.label(),
            errorText: f.showValidation.value ? f.validate(field) : null,
          ),
          items: [
            for (final p in lookups.activeProducts)
              DropdownMenuItem(value: p.id, child: Text(p.name)),
          ],
          onChanged: enabled ? (v) => f.ids[field.key] = v : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: '${f.isEdit ? tr.actionEdit : tr.actionAdd} · ${f.schema.title()}',
      icon: Icons.tune,
      busy: f.isSubmitting.value,
      errorMessage: f.errorMessage.value,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final field in f.schema.fields) ...[
            _field(context, field),
            const SizedBox(height: 12),
          ],
        ],
      ),
    ),
  );
}
