import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/l10n.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/lookup_service.dart';
import '../../../app/services/workflow_lookup_service.dart';
import '../../../app/shell/app_shell.dart';
import '../../../app/shell/settings_nav.dart';
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
  /// [SettingsNav.scheduling] or the entity of a [ConfigSchemas.all] list.
  String _section = SettingsNav.scheduling;

  @override
  void initState() {
    super.initState();
    _apply(SettingsNav.takeRequest());
    SettingsNav.request.addListener(_onRequest);
  }

  @override
  void dispose() {
    SettingsNav.request.removeListener(_onRequest);
    super.dispose();
  }

  bool _valid(String? section) =>
      section == SettingsNav.scheduling ||
      ConfigSchemas.all.any((s) => s.entity == section);

  void _apply(String? section) {
    if (section != null && _valid(section)) _section = section;
  }

  /// A sidebar / sub-navigation entry asked for another section.
  void _onRequest() {
    final requested = SettingsNav.takeRequest();
    if (requested != null && _valid(requested) && requested != _section) {
      setState(() => _section = requested);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schema = ConfigSchemas.all
        .where((s) => s.entity == _section)
        .firstOrNull;
    final group = SettingsNav.groupOf(Routes.workflowSettings, _section);
    return AppShell(
      route: Routes.workflowSettings,
      settingsSection: _section,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: group?.label() ?? tr.navWorkflowSettings,
            subtitle: tr.wfSettingsSubtitle,
            actions: [
              SettingsHelpButton(
                key: ValueKey('help-$_section'),
                section: schema == null
                    ? 'scheduling'
                    : SettingsHelp.sectionKey(schema.entity),
              ),
            ],
          ),
          SettingsSubNav(route: Routes.workflowSettings, section: _section),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
              child: schema == null
                  ? const _SchedulingForm()
                  : _ConfigListView(key: ValueKey(schema.entity), schema: schema),
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

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Minutes since midnight of an `HH:mm` value, or null when malformed.
  static int? _minutes(String text) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text.trim());
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    return h > 23 || min > 59 ? null : h * 60 + min;
  }

  Future<void> _pickTime(TextEditingController controller, String key) async {
    final current = _minutes(controller.text) ?? 9 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      helpText: tr.hoursPickTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    controller.text = '${_two(picked.hour)}:${_two(picked.minute)}';
    c.serverErrors.remove(key);
  }

  /// Sets [controller] to [value] (clamped), clearing the server error.
  void _set(TextEditingController controller, String key, int value, int min, int max) {
    controller.text = '${value.clamp(min, max)}';
    c.serverErrors.remove(key);
  }

  String _duration(int minutes) =>
      '${minutes ~/ 60} ${tr.unitHours} ${_two(minutes % 60)}';

  Widget _timeCard(
    String label,
    TextEditingController controller,
    String key, {
    String? extraError,
  }) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final error = c.validateTime(key, controller) ?? extraError;
      final shown = controller.text.trim().isEmpty ? '--:--' : controller.text.trim();
      return _SettingTile(
        label: label,
        error: error,
        onTap: () => _pickTime(controller, key),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
              size: 22,
              color: context.colors.primary,
            ),
            const SizedBox(width: 10),
            Text(
              shown,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _hoursSection(BuildContext context) => SectionCard(
    title: tr.wfWorkingDays,
    subtitle: tr.wfCfgSchedulingHint,
    padding: const EdgeInsetsDirectional.fromSTEB(18, 4, 18, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var d = 0; d < 7; d++)
              _DayPill(
                label: _weekday(d),
                open: c.workingDays.contains(d),
                onChanged: (v) =>
                    v ? c.workingDays.add(d) : c.workingDays.remove(d),
              ),
          ],
        ),
        if (c.daysError != null && c.showValidation.value)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(c.daysError!, style: TextStyle(color: context.crm.danger)),
          ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(
              width: 220,
              child: _timeCard(tr.wfWorkStart, c.workStart, 'work_start'),
            ),
            SizedBox(
              width: 220,
              child: _timeCard(
                tr.wfWorkEnd,
                c.workEnd,
                'work_end',
                extraError: c.endError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: Listenable.merge([c.workStart, c.workEnd, c.slotMinutes]),
          builder: (context, _) {
            final start = _minutes(c.workStart.text);
            final end = _minutes(c.workEnd.text);
            final valid = start != null && end != null && end > start;
            final span = valid ? end - start : 0;
            final slot = int.tryParse(c.slotMinutes.text.trim()) ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SpanBar(
                  startMinutes: valid ? start : 0,
                  endMinutes: valid ? end : 0,
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    '${tr.hoursDailySpan} : ${valid ? _duration(span) : '—'}',
                    if (valid && slot > 0) '${span ~/ slot} ${tr.hoursSlotsPerDay}',
                  ].join('  ·  '),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );

  Widget _slotSection(BuildContext context) => SectionCard(
    title: tr.wfSlotMinutes,
    child: ListenableBuilder(
      listenable: c.slotMinutes,
      builder: (context, _) {
        final current = int.tryParse(c.slotMinutes.text.trim());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in const [15, 30, 45, 60, 90, 120])
                  ChoiceChip(
                    label: Text('$m ${tr.unitMinutes}'),
                    selected: current == m,
                    showCheckmark: false,
                    onSelected: (_) => _set(c.slotMinutes, 'slot_minutes', m, 5, 480),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: _number(tr.wfSlotMinutes, c.slotMinutes, 'slot_minutes', 5, 480),
            ),
          ],
        );
      },
    ),
  );

  Widget _stepper({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String key,
    required int min,
    required int max,
    required int step,
    required String unit,
    List<int> presets = const [],
    String Function(int value)? presetLabel,
    String Function(int value)? approx,
  }) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final value = int.tryParse(controller.text.trim());
      final error = c.validateRange(key, controller, min, max);
      final scheme = context.colors;
      return _SettingTile(
        label: label,
        error: error,
        hint: hint,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton.outlined(
                  key: ValueKey('$key-minus'),
                  tooltip: '-',
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedMinusSign,
                    size: 18,
                    color: scheme.onSurface,
                  ),
                  onPressed: () => _set(controller, key, (value ?? min) - step, min, max),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      Text(
                        value == null ? '—' : '$value',
                        style: context.text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        unit,
                        style: context.text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.outlined(
                  key: ValueKey('$key-plus'),
                  tooltip: '+',
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedPlusSign,
                    size: 18,
                    color: scheme.onSurface,
                  ),
                  onPressed: () => _set(controller, key, (value ?? min) + step, min, max),
                ),
                if (approx != null && value != null) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      approx(value),
                      style: context.text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (presets.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in presets)
                    ChoiceChip(
                      label: Text(presetLabel?.call(p) ?? '$p'),
                      selected: value == p,
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => _set(controller, key, p, min, max),
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) => LoadStateView(
    state: c.state,
    isEmpty: false,
    onRetry: c.load,
    builder: (_) => Obx(
      () => ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          _hoursSection(context),
          const SizedBox(height: 14),
          _slotSection(context),
          const SizedBox(height: 14),
          SectionCard(
            title: tr.wfBookingHorizon,
            subtitle: tr.hoursBookingHorizonHint,
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: 300,
                  child: _stepper(
                    label: tr.wfBookingHorizon,
                    hint: tr.hoursBookingHorizonHint,
                    controller: c.bookingHorizonDays,
                    key: 'booking_horizon_days',
                    min: 1,
                    max: 365,
                    step: 1,
                    unit: tr.unitDays,
                    presets: const [7, 14, 30, 60, 90],
                    presetLabel: (v) => '$v ${tr.unitDays}',
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: _stepper(
                    label: tr.wfMinNotice,
                    hint: tr.hoursMinNoticeHint,
                    controller: c.minNoticeHours,
                    key: 'min_notice_hours',
                    min: 0,
                    max: 720,
                    step: 1,
                    unit: tr.unitHours,
                    presets: const [0, 2, 6, 12, 24, 48],
                    presetLabel: (v) => '$v ${tr.unitHours}',
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: _stepper(
                    label: tr.wfHoldExpiryMinutes,
                    hint: tr.hoursHoldHint,
                    controller: c.holdExpiryMinutes,
                    key: 'hold_expiry_minutes',
                    min: 5,
                    max: 43200,
                    step: 60,
                    unit: tr.unitMinutes,
                    presets: const [60, 360, 720, 1440, 2880],
                    presetLabel: (v) => '${v ~/ 60} ${tr.unitHours}',
                    approx: (v) => v % 60 == 0
                        ? '≈ ${v ~/ 60} ${tr.unitHours}'
                        : '≈ ${_duration(v)}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionCard(
            title: tr.wfCfgScheduling,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormRow(
                  children: [
                    _number(
                      tr.wfDemoCapacity,
                      c.demoCapacity,
                      'demo_capacity',
                      1,
                      50,
                      helper: tr.wfDemoCapacityHint,
                    ),
                    _number(
                      tr.wfAccompanimentOccurrences,
                      c.accompanimentOccurrences,
                      'accompaniment_occurrences',
                      1,
                      52,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FormRow(
                  children: [
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
              ],
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
  );
}

/// A weekday toggle: card with the day name, a switch and Open / Closed.
class _DayPill extends StatelessWidget {
  const _DayPill({required this.label, required this.open, required this.onChanged});

  final String label;
  final bool open;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final crm = context.crm;
    return Semantics(
      toggled: open,
      label: label,
      child: Material(
        color: open ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => onChanged(!open),
          child: Container(
            width: 132,
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: open ? scheme.primary : scheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: open ? scheme.onPrimaryContainer : scheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        open ? tr.hoursOpen : tr.hoursClosed,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: open ? crm.success : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(value: open, onChanged: onChanged),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A bordered tile with a small label, a value area and an optional hint /
/// validation message.
class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.label,
    required this.child,
    this.error,
    this.hint,
    this.onTap,
  });

  final String label;
  final Widget child;
  final String? error;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: error != null ? context.crm.danger : scheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.text.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              child,
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(
                  error!,
                  style: context.text.bodySmall?.copyWith(color: context.crm.danger),
                ),
              ] else if (hint != null) ...[
                const SizedBox(height: 8),
                Text(
                  hint!,
                  style: context.text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 24-hour bar with the opening span highlighted.
class _SpanBar extends StatelessWidget {
  const _SpanBar({required this.startMinutes, required this.endMinutes});

  final int startMinutes;
  final int endMinutes;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;
        final start = width * startMinutes / 1440;
        final length = width * (endMinutes - startMinutes).clamp(0, 1440) / 1440;
        return SizedBox(
          height: 10,
          width: width,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              PositionedDirectional(
                start: start,
                width: length,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
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
