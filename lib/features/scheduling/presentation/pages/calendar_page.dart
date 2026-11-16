import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../app/services/workflow_lookup_service.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../../prospects/presentation/dialogs/prospect_search_dialog.dart';
import '../../data/models/appointment.dart';
import '../../data/models/calendar_item.dart';
import '../../domain/scheduling_repository.dart';
import '../controllers/calendar_controller.dart';
import '../dialogs/appointment_dialogs.dart';

/// Unified calendar (month / week / day) of appointments, follow-ups,
/// interventions and completed activities.
class CalendarPage extends GetView<CalendarController> {
  const CalendarPage({super.key});

  Future<void> _open(CalendarItem item) async {
    switch (item.kind) {
      case CalendarKind.appointment:
        try {
          final appointment = await Get.find<SchedulingRepository>()
              .getAppointment(item.id);
          final changed = await showAppointmentDetailDialog(appointment);
          if (changed) await controller.load();
        } catch (e) {
          AppFeedback.error(e);
        }
      case CalendarKind.intervention:
        await Get.toNamed(Routes.afterSalesDetail(item.id));
      case CalendarKind.followUp || CalendarKind.activity:
        final id = item.prospect?.id;
        if (id != null) await AppNavigation.openProspect(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      route: Routes.calendar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: tr.navCalendar,
            subtitle: tr.wfCalendarSubtitle,
            actions: [
              Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.state.isLoading
                      ? null
                      : controller.load,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(tr.actionRefresh),
                ),
              ),
            ],
          ),
          _Toolbar(controller),
          _FilterBar(controller),
          const SizedBox(height: 8),
          Obx(() {
            final message = controller.activitiesError.value;
            if (message == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 8),
              child: ErrorBanner(message: tr.wfActivitiesNotLoaded(message)),
            );
          }),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Obx(() {
                  final view = controller.view.value;
                  return Column(
                    children: [
                      RefreshingBar(
                        visible:
                            controller.state.isLoading &&
                            controller.items.isNotEmpty,
                      ),
                      if (controller.state.hasError &&
                          controller.items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: ErrorBanner(
                            message: controller.state.errorMessage.value ?? '',
                            onRetry: controller.load,
                          ),
                        ),
                      Expanded(
                        child: LoadStateView(
                          state: controller.state,
                          // The grid itself is the content, even when empty.
                          isEmpty:
                              controller.items.isEmpty &&
                              controller.state.hasError,
                          onRetry: controller.load,
                          builder: (_) => switch (view) {
                            CalendarView.month => _MonthGrid(
                              controller,
                              onOpen: _open,
                            ),
                            CalendarView.week => _WeekView(
                              controller,
                              onOpen: _open,
                            ),
                            CalendarView.day => _DayView(
                              controller,
                              onOpen: _open,
                            ),
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _rangeTitle(CalendarController c) {
  final a = c.anchor.value;
  final locale = Formatters.locale;
  switch (c.view.value) {
    case CalendarView.month:
      final text = DateFormat('MMMM yyyy', locale).format(a);
      return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
    case CalendarView.week:
      final (from, to) = c.range;
      return '${Formatters.date(from)} → ${Formatters.date(to)}';
    case CalendarView.day:
      return Formatters.longDate(a);
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar(this.c);

  final CalendarController c;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton.outlined(
            tooltip: tr.wfPrevious,
            icon: const Icon(Icons.chevron_left),
            onPressed: c.previous,
          ),
          OutlinedButton(onPressed: c.goToday, child: Text(tr.wfToday)),
          IconButton.outlined(
            tooltip: tr.wfNext,
            icon: const Icon(Icons.chevron_right),
            onPressed: c.next,
          ),
          const SizedBox(width: 8),
          Text(_rangeTitle(c), style: context.text.titleMedium),
          const SizedBox(width: 16),
          SegmentedButton<CalendarView>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: CalendarView.month,
                label: Text(tr.wfViewMonth),
              ),
              ButtonSegment(
                value: CalendarView.week,
                label: Text(tr.wfViewWeek),
              ),
              ButtonSegment(value: CalendarView.day, label: Text(tr.wfViewDay)),
            ],
            selected: {c.view.value},
            onSelectionChanged: (s) => c.setView(s.first),
          ),
          const _Legend(),
        ],
      ),
    ),
  );
}

/// Explains the two visual styles: planned vs completed.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    Widget swatch(Color color, bool done, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: done
                ? context.colors.surfaceContainerHigh
                : color.withValues(alpha: 0.2),
            border: BorderDirectional(
              start: BorderSide(color: done ? crm.success : color, width: 3),
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: done ? Icon(Icons.check, size: 10, color: crm.success) : null,
        ),
        const SizedBox(width: 4),
        Text(label, style: context.text.bodySmall),
      ],
    );
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: Wrap(
        spacing: 12,
        children: [
          swatch(context.colors.primary, false, tr.wfLegendScheduled),
          swatch(crm.success, true, tr.wfLegendCompleted),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar(this.c);

  final CalendarController c;

  @override
  Widget build(BuildContext context) {
    final workflow = Get.find<WorkflowLookupService>();
    final lookups = Get.find<LookupService>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
      child: Obx(() {
        final f = c.filter.value;
        final types = workflow.appointmentTypes.toList();
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterDropdown<String>(
              label: tr.wfEmployee,
              width: 170,
              value: f.employee,
              items: workflow.employeeNames.toList(),
              itemLabel: (e) => e,
              onChanged: (v) => c.setFilter(f.copyWith(employee: v)),
            ),
            FilterDropdown<int>(
              label: tr.fieldProduct,
              width: 170,
              value: f.productId,
              items: lookups.activeProducts.map((p) => p.id).toList(),
              itemLabel: (id) =>
                  lookups.products.firstWhereOrNull((p) => p.id == id)?.name ??
                  '$id',
              onChanged: (v) => c.setFilter(f.copyWith(productId: v)),
            ),
            FilterDropdown<String>(
              label: tr.colType,
              width: 170,
              value: f.type,
              items: types.map((t) => t.code).toList(),
              itemLabel: (code) =>
                  types.firstWhereOrNull((t) => t.code == code)?.name ?? code,
              onChanged: (v) => c.setFilter(f.copyWith(type: v)),
            ),
            FilterDropdown<String>(
              label: tr.colStatus,
              width: 160,
              value: f.status,
              items: [
                for (final s in AppointmentStatus.values)
                  if (s != AppointmentStatus.unknown) s.apiValue,
              ],
              itemLabel: (v) => AppointmentStatus.fromApi(v).label,
              onChanged: (v) => c.setFilter(f.copyWith(status: v)),
            ),
            if (f.prospectId == null)
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showProspectSearchDialog(
                    title: tr.wfFilterCustomer,
                    excludeStageIds: const [],
                  );
                  if (picked != null) {
                    await c.setFilter(f.copyWith(prospectId: picked.id));
                  }
                },
                icon: const Icon(Icons.business_outlined, size: 18),
                label: Text(tr.wfFilterCustomer),
              )
            else
              InputChip(
                avatar: const Icon(Icons.business_outlined, size: 16),
                label: Text('#${f.prospectId}'),
                onDeleted: () => c.setFilter(f.copyWith(prospectId: null)),
              ),
            for (final k in CalendarKind.serverKinds)
              FilterChip(
                label: Text(k.label),
                selected: f.kinds.contains(k),
                onSelected: (v) => c.toggleKind(k, v),
              ),
            FilterChip(
              label: Text(tr.wfKindActivity),
              selected: c.showActivities.value,
              onSelected: c.toggleActivities,
            ),
            if (f.hasActiveFilters)
              TextButton.icon(
                onPressed: () => c.setFilter(CalendarFilter(kinds: f.kinds)),
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: Text(tr.wfClearFilters),
              ),
          ],
        );
      }),
    );
  }
}

List<String> _weekdayNames(CalendarController c) {
  final base = DateTime(2024, 1, 1); // a Monday
  final start = c.weekStartsOn;
  return [
    for (var i = 0; i < 7; i++)
      DateFormat.E(Formatters.locale)
          .format(base.add(Duration(days: (start - DateTime.monday + i) % 7))),
  ];
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid(this.c, {required this.onOpen});

  final CalendarController c;
  final ValueChanged<CalendarItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final days = c.days;
    final names = _weekdayNames(c);
    final month = c.anchor.value.month;
    final today = c.today;
    return Column(
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHigh.withValues(alpha: 0.6),
            border: Border(
              bottom: BorderSide(color: context.colors.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              for (final n in names)
                Expanded(
                  child: Center(
                    child: Text(n, style: context.text.labelMedium),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              for (var w = 0; w < days.length ~/ 7; w++)
                Expanded(
                  child: Row(
                    children: [
                      for (var d = 0; d < 7; d++)
                        Expanded(
                          child: _DayCell(
                            controller: c,
                            day: days[w * 7 + d],
                            inMonth: days[w * 7 + d].month == month,
                            isToday: days[w * 7 + d] == today,
                            onOpen: onOpen,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.controller,
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.onOpen,
  });

  final CalendarController controller;
  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final ValueChanged<CalendarItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = controller.itemsOn(day);
    const maxShown = 3;
    final scheme = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: inMonth
            ? null
            : scheme.surfaceContainerHigh.withValues(alpha: 0.25),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => controller.openDay(day),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: isToday
                    ? BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: Text(
                  '${day.day}',
                  style: context.text.labelMedium?.copyWith(
                    color: isToday
                        ? scheme.onPrimary
                        : (inMonth ? null : scheme.onSurfaceVariant),
                    fontWeight: isToday ? FontWeight.w700 : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          for (final item in items.take(maxShown))
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: CalendarEventCard(
                item: item,
                compact: true,
                onTap: () => onOpen(item),
              ),
            ),
          if (items.length > maxShown)
            InkWell(
              onTap: () => controller.openDay(day),
              child: Text(
                tr.wfMoreItems(items.length - maxShown),
                style: context.text.labelSmall?.copyWith(color: scheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView(this.c, {required this.onOpen});

  final CalendarController c;
  final ValueChanged<CalendarItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final days = c.days;
    final today = c.today;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final day in days)
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: BorderSide(
                    color: context.colors.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () => c.openDay(day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: day == today
                          ? context.colors.primary.withValues(alpha: 0.12)
                          : context.colors.surfaceContainerHigh.withValues(
                              alpha: 0.6,
                            ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat.E(Formatters.locale).format(day),
                            style: context.text.labelMedium,
                          ),
                          Text('${day.day}', style: context.text.titleSmall),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(4),
                      children: [
                        for (final item in c.itemsOn(day))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: CalendarEventCard(
                              item: item,
                              onTap: () => onOpen(item),
                            ),
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
  }
}

class _DayView extends StatelessWidget {
  const _DayView(this.c, {required this.onOpen});

  final CalendarController c;
  final ValueChanged<CalendarItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = c.itemsOn(c.anchor.value);
    if (items.isEmpty) {
      return EmptyView(
        icon: Icons.event_available_outlined,
        title: tr.wfNothingScheduled,
        message: tr.wfNothingScheduledHint,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CalendarEventCard(
            item: items[i],
            onTap: () => onOpen(items[i]),
          ),
        ),
      ),
    );
  }
}
