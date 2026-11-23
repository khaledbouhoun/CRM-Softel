import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../../customers/presentation/dialogs/customer_dialogs.dart';
import '../../data/models/appointment.dart';
import '../../data/models/portal_request.dart';
import '../controllers/appointment_action_controller.dart';
import '../controllers/scheduling_lists_controllers.dart';
import '../dialogs/appointment_dialogs.dart';

import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/animated_entrance.dart';
/// Website requests and slot holds waiting for an employee.
class PendingRequestsPage extends GetView<PendingRequestsController> {
  const PendingRequestsPage({super.key});

  Future<void> _decide(Appointment a, AppointmentActionKind kind) async {
    final result = await showAppointmentActionDialog(kind: kind, appointment: a);
    if (!result.changed) return;
    if (result.stale) AppFeedback.warning(tr.wfHoldExpired);
    await controller.loadAll();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.requests,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: tr.navRequests,
          subtitle: tr.wfRequestsSubtitle,
          actions: [
            Obx(
              () => OutlinedButton.icon(
                onPressed: controller.holdsState.isLoading || controller.requestsState.isLoading
                    ? null
                    : controller.loadAll,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Obx(
              () => SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 0,
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedHourglass, size: 18),
                    label: Text(tr.wfHoldsTab(controller.holds.length)),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedGlobe02, size: 18),
                    label: Text(tr.wfWebsiteRequestsTab),
                  ),
                ],
                selected: {controller.tab.value},
                onSelectionChanged: (s) => controller.tab.value = s.first,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(
            () => controller.tab.value == 0
                ? _HoldsList(controller: controller, onDecide: _decide)
                : _RequestsList(controller: controller),
          ),
        ),
      ],
    ),
  );
}

class _HoldsList extends StatelessWidget {
  const _HoldsList({required this.controller, required this.onDecide});

  final PendingRequestsController controller;
  final Future<void> Function(Appointment, AppointmentActionKind) onDecide;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
    child: Obx(() {
      final holds = controller.holds.toList();
      return Column(
        children: [
          RefreshingBar(visible: controller.holdsState.isLoading && holds.isNotEmpty),
          Expanded(
            child: LoadStateView(
              state: controller.holdsState,
              isEmpty: holds.isEmpty,
              onRetry: controller.loadHolds,
              empty: EmptyView(icon: HugeIcons.strokeRoundedCalendarCheck01, title: tr.wfNoHolds, message: tr.wfNoHoldsHint),
              builder: (_) => ListView.separated(
                itemCount: holds.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _HoldCard(holds[i], onDecide: onDecide),
              ),
            ),
          ),
        ],
      );
    }),
  );
}

class _HoldCard extends StatelessWidget {
  const _HoldCard(this.a, {required this.onDecide});

  final Appointment a;
  final Future<void> Function(Appointment, AppointmentActionKind) onDecide;

  @override
  Widget build(BuildContext context) {
    final expired = a.isHoldExpired || (a.holdExpiresAt != null && a.holdExpiresAt!.isBefore(DateTime.now()));
    final waitingForCustomer = a.status == AppointmentStatus.proposed;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 64,
              decoration: BoxDecoration(
                color: hexColor(a.type.color, context.colors.primary),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(a.prospect.name, style: context.text.titleMedium),
                      AppointmentStatusBadge(status: a.status),
                      if (!a.prospect.isCustomer) StatusBadge(label: tr.wfNewProspect, color: context.crm.info),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    joinNonEmpty([a.type.name, a.product?.name, a.prospect.contactPerson, a.prospect.phone]),
                    style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${Formatters.dateTime(a.startsAt)} – ${Formatters.time(a.endsAt)}',
                        style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      HoldCountdown(expiresAt: a.holdExpiresAt),
                    ],
                  ),
                  if (waitingForCustomer)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(tr.wfWaitingForCustomer, style: context.text.bodySmall),
                    ),
                  if (expired && !waitingForCustomer)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(tr.wfHoldExpired, style: context.text.bodySmall?.copyWith(color: context.crm.danger)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                if (!waitingForCustomer)
                  FilledButton.icon(
                    onPressed: () => onDecide(a, AppointmentActionKind.confirm),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedTick02, size: 18),
                    label: Text(tr.actionConfirm),
                  ),
                if (!waitingForCustomer)
                  OutlinedButton.icon(
                    onPressed: () => onDecide(a, AppointmentActionKind.propose),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeftRight, size: 18),
                    label: Text(tr.wfProposeOther),
                  ),
                OutlinedButton.icon(
                  onPressed: () =>
                      onDecide(a, waitingForCustomer ? AppointmentActionKind.cancel : AppointmentActionKind.reject),
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel02, size: 18),
                  label: Text(waitingForCustomer ? tr.wfCancelProposal : tr.wfReject),
                ),
                if (a.prospect.id != 0)
                  IconButton(
                    tooltip: tr.wfOpenProspectRecord,
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedLinkSquare02, size: 18),
                    onPressed: () => AppNavigation.openProspect(a.prospect.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.controller});

  final PendingRequestsController controller;

  Future<void> _confirm(PortalRequest r) async {
    if (r.type == 'trial' && r.prospectId != null) {
      final trial = await showTrialDialog(
        prospectId: r.prospectId!,
        productId: r.product?.id,
        notes: r.notes,
      );
      if (trial != null) {
        AppFeedback.success(tr.wfTrialActivated);
        await controller.loadRequests();
      }
    } else {
      await _close(r, 'handled');
    }
  }

  Future<void> _close(PortalRequest r, String status) async {
    final message = await _askMessage(status == 'handled' ? tr.wfMarkHandled : tr.wfReject);
    if (message == null) return;
    final result = await controller.updateRequest(r, status, customerMessage: message);
    result.isSuccess ? AppFeedback.success(tr.wfRequestUpdated) : AppFeedback.error(result.error!);
  }

  /// Asks for an optional customer-visible message. Null = cancelled.
  Future<String?> _askMessage(String title) {
    final text = TextEditingController();
    return showAppDialog<String>(
      Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Get.textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: text,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: tr.wfMessageVisible,
                    helperText: tr.wfCustomerVisibleHint,
                    helperMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: Text(tr.actionCancel)),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Get.back(result: text.text),
                      child: Text(tr.actionConfirm),
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

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilterDropdown<String>(
                label: tr.colType,
                width: 190,
                value: controller.requestType.value,
                items: const ['demo', 'quotation', 'trial'],
                itemLabel: (t) => switch (t) {
                  'demo' => tr.wfRequestDemo,
                  'quotation' => tr.wfRequestQuotation,
                  _ => tr.wfRequestTrial,
                },
                onChanged: controller.setRequestType,
              ),
              FilterDropdown<String>(
                label: tr.colStatus,
                width: 190,
                value: controller.requestStatus.value,
                items: const ['pending', 'scheduled', 'handled', 'rejected', 'cancelled', 'expired'],
                itemLabel: (s) => PortalRequest(id: 0, type: '', status: s, company: '', contactName: '').statusLabel,
                onChanged: controller.setRequestStatus,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Obx(() {
              final page = controller.requests.value;
              return Column(
                children: [
                  RefreshingBar(visible: controller.requestsState.isLoading && page.items.isNotEmpty),
                  Expanded(
                    child: LoadStateView(
                      state: controller.requestsState,
                      isEmpty: page.items.isEmpty,
                      onRetry: controller.loadRequests,
                      empty: EmptyView(icon: HugeIcons.strokeRoundedInbox, title: tr.wfNoRequests),
                      builder: (_) => CrmDataTable<PortalRequest>(
                        rows: page.items,
                        rowHeight: 60,
                        columns: [
                          CrmColumn(
                            label: tr.wfReceived,
                            width: 150,
                            cell: (r) => CellText(Formatters.dateTime(r.createdAt)),
                          ),
                          CrmColumn(
                            label: tr.colType,
                            width: 130,
                            cell: (r) => StatusBadge(label: r.typeLabel, color: context.colors.primary),
                          ),
                          CrmColumn(
                            label: tr.fieldCompany,
                            flex: 3,
                            cell: (r) => CellText(r.company, bold: true, secondary: r.contactName),
                          ),
                          CrmColumn(
                            label: tr.fieldPhone,
                            flex: 2,
                            cell: (r) => CellText(r.phone ?? '', secondary: r.email),
                          ),
                          CrmColumn(label: tr.fieldProduct, flex: 2, cell: (r) => CellText(r.product?.name ?? '')),
                          CrmColumn(
                            label: tr.colStatus,
                            width: 120,
                            cell: (r) => StatusBadge(
                              label: r.statusLabel,
                              color: r.status == 'pending' ? context.crm.warning : context.colors.outline,
                            ),
                          ),
                          CrmColumn(
                            label: '',
                            width: 200,
                            alignment: AlignmentDirectional.centerEnd,
                            cell: (r) => r.isActionable
                                ? Obx(
                                    () => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FilledButton.tonalIcon(
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          icon: const HugeIcon(icon: HugeIcons.strokeRoundedTick02, size: 16),
                                          label: Text(tr.actionConfirm),
                                          onPressed: controller.busyRequestIds.contains(r.id)
                                              ? null
                                              : () => _confirm(r),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            visualDensity: VisualDensity.compact,
                                            foregroundColor: context.crm.danger,
                                          ),
                                          icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 16),
                                          label: Text(tr.wfReject),
                                          onPressed: controller.busyRequestIds.contains(r.id)
                                              ? null
                                              : () => _close(r, 'rejected'),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (page.items.isNotEmpty)
                    PaginationBar(
                      page: page,
                      onPageChanged: controller.goToPage,
                      onPerPageChanged: controller.setPerPage,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    ),
  );
}
