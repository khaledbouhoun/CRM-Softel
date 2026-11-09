import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/json_utils.dart';
import 'state_views.dart';
import '../../app/l10n/l10n.dart';

/// Standard dialog for forms: title, scrollable body, error banner and
/// Cancel / Save buttons. The save button is disabled while [busy] to prevent
/// duplicate submissions.
class FormDialog extends StatelessWidget {
  const FormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.onSubmit,
    required this.onCancel,
    this.busy = false,
    this.errorMessage,
    this.submitLabel,
    this.width = 560,
    this.icon,
    this.submitEnabled = true,
  });

  final String title;
  final IconData? icon;
  final Widget child;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final bool busy;
  final String? errorMessage;
  final String? submitLabel;
  final double width;
  final bool submitEnabled;

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 12, 8),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: context.colors.primary),
                  const SizedBox(width: 10),
                ],
                Expanded(child: Text(title, style: context.text.titleLarge)),
                IconButton(
                  tooltip: tr.actionClose,
                  onPressed: busy ? null : onCancel,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 8),
              child: child,
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 0),
              child: ErrorBanner(message: errorMessage!),
            ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 20),
            // Wraps instead of overflowing with long labels / large fonts.
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              overflowAlignment: OverflowBarAlignment.end,
              spacing: 8,
              overflowSpacing: 8,
              children: [
                TextButton(
                  onPressed: busy ? null : onCancel,
                  child: Text(tr.actionCancel),
                ),
                FilledButton.icon(
                  onPressed: busy || !submitEnabled ? null : onSubmit,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: Text(
                    busy ? tr.actionSaving : (submitLabel ?? tr.actionSave),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Two fields side by side, stacked when narrow.
class FormRow extends StatelessWidget {
  const FormRow({super.key, required this.children, this.spacing = 14});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 420) {
        return Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              children[i],
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(child: children[i]),
          ],
        ],
      );
    },
  );
}

/// Opens date then time pickers. Returns null if cancelled.
Future<DateTime?> pickDateTime(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final now = DateTime.now();
  final start = initial ?? now;
  final date = await showDatePicker(
    context: context,
    initialDate: start,
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? DateTime(now.year + 10),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(start),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Read-only field that opens a date/time picker.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.clearable = false,
    this.enabled = true,
    this.helperText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? errorText;
  final bool clearable;
  final bool enabled;
  final String? helperText;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: !enabled
        ? null
        : () async {
            final picked = await pickDateTime(context, initial: value);
            if (picked != null) onChanged(picked);
          },
    child: InputDecorator(
      isEmpty: value == null,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        helperText: helperText,
        enabled: enabled,
        prefixIcon: const Icon(Icons.event, size: 20),
        suffixIcon: clearable && value != null && enabled
            ? IconButton(
                tooltip: tr.actionClear,
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onChanged(null),
              )
            : null,
      ),
      child: Text(value == null ? '' : Formatters.dateTime(value)),
    ),
  );
}

/// Palette + hex preview for choosing a stage color.
class ColorPickerField extends StatelessWidget {
  const ColorPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  static const palette = [
    '#64748B',
    '#3B82F6',
    '#0EA5E9',
    '#06B6D4',
    '#14B8A6',
    '#10B981',
    '#22C55E',
    '#84CC16',
    '#EAB308',
    '#F59E0B',
    '#F97316',
    '#EF4444',
    '#EC4899',
    '#A855F7',
    '#8B5CF6',
    '#6366F1',
    '#1E3A8A',
    '#0F766E',
  ];

  final String value;
  final ValueChanged<String> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final current = value.toUpperCase();
    return InputDecorator(
      decoration: InputDecoration(labelText: label ?? tr.color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final hex in palette)
                Tooltip(
                  message: hex,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onChanged(hex),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Color(parseHexColor(hex)!),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: current == hex
                              ? context.colors.onSurface
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: current == hex
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Color(parseHexColor(current) ?? 0xFF64748B),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(current, style: context.text.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section title inside forms.
class FormSectionLabel extends StatelessWidget {
  const FormSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 8),
    child: Text(
      text,
      style: context.text.labelLarge?.copyWith(
        color: context.colors.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
