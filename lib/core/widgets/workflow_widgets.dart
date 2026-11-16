import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/l10n/l10n.dart';
import '../../app/theme/app_theme.dart';
import '../../features/scheduling/data/models/appointment.dart';
import '../../features/scheduling/data/models/calendar_item.dart';
import '../../features/workflow_settings/data/models/config_models.dart';
import '../utils/formatters.dart';
import '../utils/json_utils.dart';
import 'layout_widgets.dart';

/// Color from a configured `#RRGGBB` value, or [fallback] when missing or
/// malformed. Colors of types, statuses and priorities come from the CRM.
Color hexColor(String? hex, Color fallback) {
  final value = parseHexColor(hex);
  return value == null ? fallback : Color(value);
}

/// Pill with a colored dot and a label (status badge). The color comes from
/// configuration; the label is already localized by the caller.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: StatusPill(label: label, color: color, icon: icon),
  );
}

/// Status badge of an appointment, with theme colors per lifecycle state.
class AppointmentStatusBadge extends StatelessWidget {
  const AppointmentStatusBadge({super.key, required this.status});

  final AppointmentStatus status;

  static Color colorOf(BuildContext context, AppointmentStatus status) {
    final crm = context.crm;
    return switch (status) {
      AppointmentStatus.held => crm.warning,
      AppointmentStatus.proposed => crm.info,
      AppointmentStatus.confirmed => crm.success,
      AppointmentStatus.completed => crm.success,
      AppointmentStatus.rejected => crm.danger,
      AppointmentStatus.cancelled => context.colors.outline,
      AppointmentStatus.expired => context.colors.outline,
      AppointmentStatus.noShow => crm.danger,
      AppointmentStatus.unknown => context.colors.outline,
    };
  }

  static IconData iconOf(AppointmentStatus status) => switch (status) {
    AppointmentStatus.held => Icons.hourglass_top,
    AppointmentStatus.proposed => Icons.swap_horiz,
    AppointmentStatus.confirmed => Icons.event_available,
    AppointmentStatus.completed => Icons.check_circle_outline,
    AppointmentStatus.rejected => Icons.block,
    AppointmentStatus.cancelled => Icons.event_busy,
    AppointmentStatus.expired => Icons.timer_off_outlined,
    AppointmentStatus.noShow => Icons.person_off_outlined,
    AppointmentStatus.unknown => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) => StatusBadge(
    label: status.label,
    color: colorOf(context, status),
    icon: iconOf(status),
  );
}

/// Badge of an intervention status (configured color, internal name).
class InterventionStatusBadge extends StatelessWidget {
  const InterventionStatusBadge({super.key, required this.status});

  final InterventionStatus? status;

  @override
  Widget build(BuildContext context) {
    final s = status;
    if (s == null) {
      return StatusBadge(label: '—', color: context.colors.outline);
    }
    return StatusBadge(
      label: s.name,
      color: hexColor(s.color, context.colors.primary),
      icon: s.isClosed ? Icons.check_circle_outline : null,
    );
  }
}

/// Priority indicator: colored flag + name (priorities are configurable).
class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final InterventionPriority? priority;

  @override
  Widget build(BuildContext context) {
    final p = priority;
    if (p == null) {
      return Text(
        tr.wfNoPriority,
        style: context.text.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      );
    }
    final color = hexColor(p.color, context.colors.primary);
    return StatusBadge(label: p.name, color: color, icon: Icons.flag);
  }
}

/// Live "expires in 3h 20m" label of a slot hold. Shows the expired state
/// once the time has passed (the server releases the slot itself).
class HoldCountdown extends StatefulWidget {
  const HoldCountdown({
    super.key,
    required this.expiresAt,
    this.clock,
    this.tick = const Duration(seconds: 15),
  });

  final DateTime? expiresAt;

  /// Overridable for tests.
  final DateTime Function()? clock;
  final Duration tick;

  /// "2d 3h", "3h 20m", "12m", "45s" for the remaining [duration].
  static String format(Duration duration) {
    if (duration.inSeconds <= 0) return tr.wfStatusExpired;
    final d = duration.inDays;
    final h = duration.inHours % 24;
    final m = duration.inMinutes % 60;
    if (d > 0) return '${d}d ${h}h';
    if (duration.inHours > 0) return '${duration.inHours}h ${m}m';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m';
    return '${duration.inSeconds}s';
  }

  @override
  State<HoldCountdown> createState() => _HoldCountdownState();
}

class _HoldCountdownState extends State<HoldCountdown> {
  Timer? _timer;

  DateTime get _now => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.tick, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expiry = widget.expiresAt;
    if (expiry == null) return const SizedBox.shrink();
    final remaining = expiry.difference(_now);
    final expired = remaining.inSeconds <= 0;
    final urgent = !expired && remaining < const Duration(hours: 1);
    final crm = context.crm;
    final color = expired
        ? crm.danger
        : (urgent ? crm.warning : context.colors.onSurfaceVariant);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          expired
              ? tr.wfStatusExpired
              : tr.wfExpiresIn(HoldCountdown.format(remaining)),
          style: context.text.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Per-occurrence explanation of a refused schedule
/// (`409 APPOINTMENT_CONFLICT`): which sessions clash and why.
class ConflictList extends StatelessWidget {
  const ConflictList({super.key, required this.conflicts});

  final List<ScheduleConflict> conflicts;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: crm.warningContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: crm.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: crm.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr.wfConflictsTitle,
                  style: context.text.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final c in conflicts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                tr.wfConflictLine(
                  c.occurrence,
                  Formatters.dateTime(c.startsAt),
                  c.reasonLabel,
                ),
                style: context.text.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact card for a calendar entry. Scheduled items use a solid accent bar;
/// **completed** work (recorded activities, finished appointments) is drawn
/// muted with a check mark, so plans and history are never confused.
class CalendarEventCard extends StatelessWidget {
  const CalendarEventCard({
    super.key,
    required this.item,
    this.onTap,
    this.compact = false,
  });

  final CalendarItem item;
  final VoidCallback? onTap;

  /// One-line variant for month cells.
  final bool compact;

  static IconData kindIcon(CalendarKind kind) => switch (kind) {
    CalendarKind.appointment => Icons.event,
    CalendarKind.followUp => Icons.notifications_active_outlined,
    CalendarKind.intervention => Icons.build_circle_outlined,
    CalendarKind.activity => Icons.task_alt,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final crm = context.crm;
    final accent = hexColor(item.color, scheme.primary);
    final done = item.isCompleted;
    final dim = done || item.isCancelledLike;
    final time = item.endsAt.isAfter(item.startsAt)
        ? '${Formatters.time(item.startsAt)} – ${Formatters.time(item.endsAt)}'
        : Formatters.time(item.startsAt);
    final background = done
        ? scheme.surfaceContainerHigh.withValues(alpha: 0.6)
        : accent.withValues(alpha: item.isTentative ? 0.06 : 0.12);
    final textColor = dim ? scheme.onSurfaceVariant : scheme.onSurface;

    final title = Text(
      item.title,
      maxLines: compact ? 1 : 2,
      overflow: TextOverflow.ellipsis,
      style: (compact ? context.text.bodySmall : context.text.bodyMedium)
          ?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            decoration: item.isCancelledLike
                ? TextDecoration.lineThrough
                : null,
          ),
    );

    final leadingIcon = Icon(
      done ? Icons.check_circle : kindIcon(item.kind),
      size: compact ? 13 : 16,
      color: done ? crm.success : accent,
    );

    final child = compact
        ? Row(
            children: [
              leadingIcon,
              const SizedBox(width: 4),
              Expanded(child: title),
              if (item.hasConflict)
                Icon(Icons.warning_amber_rounded, size: 13, color: crm.warning),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  leadingIcon,
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      time,
                      style: context.text.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (item.hasConflict)
                    Tooltip(
                      message: item.conflicts
                          .map((c) => c.reasonLabel)
                          .toSet()
                          .join(' · '),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: crm.warning,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              title,
              if (item.prospect != null || item.product != null)
                Text(
                  [
                    item.prospect?.name,
                    item.product?.name,
                  ].whereType<String>().join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              if (item.hasConflict)
                Text(
                  tr.wfConflictExplain(
                    item.conflicts
                        .map((c) => c.reasonLabel)
                        .toSet()
                        .join(' · '),
                  ),
                  style: context.text.bodySmall?.copyWith(color: crm.warning),
                ),
              if (item.assignedEmployee != null)
                Text(
                  item.assignedEmployee!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (item.kind == CalendarKind.appointment)
                    AppointmentStatusBadge(status: item.appointmentStatus)
                  else
                    StatusBadge(
                      label: item.kind.label,
                      color: done ? crm.success : accent,
                    ),
                ],
              ),
            ],
          );

    return Semantics(
      button: onTap != null,
      label: '${item.kind.label}: ${item.title}, $time',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(
              compact ? 6 : 10,
              compact ? 3 : 8,
              compact ? 6 : 10,
              compact ? 3 : 8,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
              border: BorderDirectional(
                start: BorderSide(
                  color: done ? crm.success : accent,
                  width: item.isTentative ? 2 : 4,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Employee picker fed by the CRM's employee list. Keeps an unknown current
/// value selectable so an assignment is never silently dropped.
class EmployeeDropdown extends StatelessWidget {
  const EmployeeDropdown({
    super.key,
    required this.value,
    required this.names,
    required this.onChanged,
    this.label,
    this.width,
  });

  final String? value;
  final List<String> names;
  final ValueChanged<String?> onChanged;
  final String? label;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final options = {
      ...names,
      if (value != null && value!.isNotEmpty) value!,
    }.toList();
    final field = DropdownButtonFormField<String?>(
      initialValue: (value == null || value!.isEmpty) ? null : value,
      key: ValueKey('emp-${value ?? ''}-${options.length}'),
      isExpanded: true,
      decoration: InputDecoration(labelText: label ?? tr.wfAssignedTo),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(tr.wfUnassigned)),
        for (final n in options)
          DropdownMenuItem<String?>(value: n, child: Text(n)),
      ],
      onChanged: onChanged,
    );
    return width == null ? field : SizedBox(width: width, child: field);
  }
}

/// Internal / customer-visible indicator of a message (never mixed up).
class VisibilityBadge extends StatelessWidget {
  const VisibilityBadge({super.key, required this.internal});

  final bool internal;

  @override
  Widget build(BuildContext context) => StatusBadge(
    label: internal ? tr.wfInternalNote : tr.wfCustomerReply,
    color: internal ? context.crm.warning : context.crm.info,
    icon: internal ? Icons.lock_outline : Icons.visibility_outlined,
  );
}

/// Shorthand to show a labelled value in dialogs and cards.
String joinNonEmpty(Iterable<String?> parts, [String separator = ' · ']) =>
    parts.whereType<String>().where((p) => p.trim().isNotEmpty).join(separator);
