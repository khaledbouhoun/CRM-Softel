import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../data/models/appointment.dart';
import '../controllers/appointment_action_controller.dart';
import '../controllers/scheduling_lists_controllers.dart';
import '../dialogs/appointment_dialogs.dart';
import '../dialogs/schedule_session_dialog.dart';

import 'package:hugeicons/hugeicons.dart';
/// Training sessions and accompaniment series.
class TrainingPage extends GetView<TrainingController> {
  const TrainingPage({super.key});

  Future<void> _schedule(SessionMode mode) async {
    final result = await showScheduleSessionDialog(mode: mode);
    if (result == null) return;
    AppFeedback.success(
      result.isSeries
          ? tr.wfSeriesScheduled(result.appointments.length)
          : tr.wfSessionScheduled,
    );
    await controller.load();
  }

  Future<void> _action(Appointment a, AppointmentActionKind kind) async {
    final result = await showAppointmentActionDialog(
      kind: kind,
      appointment: a,
    );
    if (result.changed) await controller.load();
  }

  Future<void> _cancelOne(Appointment a) async {
    final ok = await showConfirmDialog(
      title: tr.wfCancelSessionTitle,
      message: tr.wfCancelSessionBody,
      confirmLabel: tr.wfCancelAppointment,
      destructive: true,
    );
    if (!ok) return;
    final r = await controller.cancelSession(a);
    r.isSuccess
        ? AppFeedback.success(tr.wfSessionCancelled)
        : AppFeedback.error(r.error!);
  }

  Future<void> _cancelSeries(Appointment a) async {
    final ok = await showConfirmDialog(
      title: tr.wfCancelSeriesTitle,
      message: tr.wfCancelSeriesBody,
      confirmLabel: tr.wfCancelSeries,
      destructive: true,
    );
    if (!ok) return;
    final r = await controller.cancelRemainingSeries(a);
    r.isSuccess
        ? AppFeedback.success(tr.wfSeriesCancelled(r.value ?? 0))
        : AppFeedback.error(r.error!);
  }

  Future<void> _noShow(Appointment a) async {
    final r = await controller.markNoShow(a);
    if (!r.isSuccess) AppFeedback.error(r.error!);
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.training,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: tr.navTraining,
          subtitle: tr.wfTrainingSubtitle,
          actions: [
            Obx(
              () => OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _schedule(SessionMode.accompaniment),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendarSync, size: 18),
              label: Text(tr.wfNewAccompaniment),
            ),
            FilledButton.icon(
              onPressed: () => _schedule(SessionMode.training),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18),
              label: Text(tr.wfNewTraining),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterDropdown<String>(
                  label: tr.colType,
                  width: 200,
                  value: controller.group.value,
                  items: const ['training', 'accompaniment'],
                  itemLabel: (g) => g == 'training'
                      ? tr.wfGroupTraining
                      : tr.wfGroupAccompaniment,
                  onChanged: controller.setGroup,
                ),
                FilterDropdown<AppointmentStatus>(
                  label: tr.colStatus,
                  width: 180,
                  value: controller.status.value,
                  items: [
                    for (final s in AppointmentStatus.values)
                      if (s != AppointmentStatus.unknown) s,
                  ],
                  itemLabel: (s) => s.label,
                  onChanged: controller.setStatus,
                ),
                FilterChip(
                  label: Text(tr.wfShowPast),
                  selected: controller.showPast.value,
                  onSelected: controller.setShowPast,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Obx(() {
                final items = controller.sessions.toList();
                return Column(
                  children: [
                    RefreshingBar(
                      visible: controller.state.isLoading && items.isNotEmpty,
                    ),
                    Expanded(
                      child: LoadStateView(
                        state: controller.state,
                        isEmpty: items.isEmpty,
                        onRetry: controller.load,
                        empty: EmptyView(
                          icon: HugeIcons.strokeRoundedMortarboard01,
                          title: tr.wfNoSessions,
                          message: tr.wfNoSessionsHint,
                        ),
                        builder: (context) => CrmDataTable<Appointment>(
                          rows: items,
                          rowHeight: 60,
                          onRowTap: (a) async {
                            if (await showAppointmentDetailDialog(a)) {
                              await controller.load();
                            }
                          },
                          columns: [
                            CrmColumn(
                              label: tr.wfWhen,
                              width: 170,
                              cell: (a) => CellText(
                                Formatters.dateTime(a.startsAt),
                                bold: true,
                                secondary: '→ ${Formatters.time(a.endsAt)}',
                              ),
                            ),
                            CrmColumn(
                              label: tr.navCustomers,
                              flex: 3,
                              cell: (a) => CellText(
                                a.prospect.name,
                                secondary: a.prospect.contactPerson,
                              ),
                            ),
                            CrmColumn(
                              label: tr.colType,
                              flex: 2,
                              cell: (a) => CellText(
                                a.type.name,
                                secondary: a.seriesId == null
                                    ? null
                                    : tr.wfPartOfSeries,
                              ),
                            ),
                            CrmColumn(
                              label: tr.fieldProduct,
                              flex: 2,
                              cell: (a) => CellText(a.product?.name ?? ''),
                            ),
                            CrmColumn(
                              label: tr.wfTrainer,
                              flex: 2,
                              cell: (a) => CellText(a.assignedEmployee ?? ''),
                            ),
                            CrmColumn(
                              label: tr.colStatus,
                              width: 130,
                              cell: (a) =>
                                  AppointmentStatusBadge(status: a.status),
                            ),
                            CrmColumn(
                              label: '',
                              width: 96,
                              alignment: AlignmentDirectional.centerEnd,
                              cell: (a) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (a.whatsapp != null)
                                    OpenWhatsAppButton(
                                      link: a.whatsapp!,
                                      compact: true,
                                    ),
                                  _RowMenu(
                                    appointment: a,
                                    onAction: (k) => _action(a, k),
                                    onCancelOne: () => _cancelOne(a),
                                    onCancelSeries: () => _cancelSeries(a),
                                    onNoShow: () => _noShow(a),
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
        ),
      ],
    ),
  );
}

class _RowMenu extends StatelessWidget {
  const _RowMenu({
    required this.appointment,
    required this.onAction,
    required this.onCancelOne,
    required this.onCancelSeries,
    required this.onNoShow,
  });

  final Appointment appointment;
  final ValueChanged<AppointmentActionKind> onAction;
  final VoidCallback onCancelOne;
  final VoidCallback onCancelSeries;
  final VoidCallback onNoShow;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final confirmed = a.status == AppointmentStatus.confirmed;
    final future = a.startsAt?.isAfter(DateTime.now()) ?? false;
    final entries = <PopupMenuEntry<void>>[
      if (a.canComplete)
        PopupMenuItem(
          onTap: () => onAction(AppointmentActionKind.complete),
          child: Text(tr.wfRecordOutcome),
        ),
      if (a.canComplete)
        PopupMenuItem(onTap: onNoShow, child: Text(tr.wfMarkNoShow)),
      if (confirmed && future)
        PopupMenuItem(
          onTap: () => onAction(AppointmentActionKind.reschedule),
          child: Text(tr.wfReschedule),
        ),
      if (confirmed && future)
        PopupMenuItem(onTap: onCancelOne, child: Text(tr.wfCancelThisSession)),
      if (confirmed && future && a.seriesId != null)
        PopupMenuItem(
          onTap: onCancelSeries,
          child: Text(tr.wfCancelRemainingSeries),
        ),
    ];
    if (entries.isEmpty) return const SizedBox(width: 40);
    return PopupMenuButton<void>(
      tooltip: tr.wfMoreActions,
      itemBuilder: (_) => entries,
    );
  }
}
