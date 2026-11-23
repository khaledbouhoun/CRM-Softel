import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/employee_identity.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/charts.dart';
import '../../../../core/widgets/huge_data.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/phone_cell.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../follow_ups/presentation/dialogs/follow_up_dialogs.dart';
import '../../../interventions/presentation/dialogs/intervention_dialogs.dart';
import '../../../prospects/presentation/dialogs/prospect_dialogs.dart';
import '../../../scheduling/presentation/dialogs/schedule_session_dialog.dart';
import '../../../settings/data/models/sales_stage.dart';
import '../../data/models/dashboard_summary.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.dashboard,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => PageHeader(
            title: tr.navDashboard,
            subtitle: controller.lastUpdatedAt.value == null
                ? tr.dashSubtitle
                : tr.dashUpdatedAt(Formatters.time(controller.lastUpdatedAt.value)),
            actions: [
              OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ],
          ),
        ),
        Obx(() => RefreshingBar(visible: controller.state.isLoading && controller.summary.value != null)),
        Expanded(
          child: Obx(() {
            final summary = controller.summary.value;
            return LoadStateView(
              state: controller.state,
              isEmpty: summary == null,
              onRetry: controller.load,
              skeleton: SkeletonKind.cards,
              builder: (_) => _DashboardContent(summary!, controller),
            );
          }),
        ),
      ],
    ),
  );
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent(this.s, this.c);

  final DashboardSummary s;
  final DashboardController c;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final winRate = s.winRate;
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 28),
      children: [
        if (c.state.hasError)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ErrorBanner(message: tr.dashStale(c.state.errorMessage.value ?? ''), onRetry: c.load),
          ),
        FadeSlideIn(child: _WelcomeBanner(s, c)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _KpiCard(
                label: tr.dashActiveClients,
                value: s.customers.total,
                icon: HugeIcons.strokeRoundedBuilding02,
                color: crm.success,
                footnote: tr.dashMaintenanceActive(s.customers.activeMaintenance),
                extra: s.customers.expiringSoon > 0 ? tr.dashMaintenanceExpiring(s.customers.expiringSoon) : null,
                extraColor: crm.warning,
                onTap: () => Get.offAllNamed(Routes.customers),
              ),
              _KpiCard(
                label: tr.dashPipelineDeals,
                value: s.openProspects,
                icon: HugeIcons.strokeRoundedUserGroup,
                color: crm.info,
                footnote: winRate != null
                    ? tr.dashWinRate((winRate * 100).toStringAsFixed(0))
                    : tr.dashNewThisMonthCount(s.thisMonth.newProspects),
                onTap: () => Get.offAllNamed(Routes.pipeline),
              ),
              _KpiCard(
                label: tr.dashOpenSupport,
                value: s.support.openTickets,
                icon: HugeIcons.strokeRoundedHeadset,
                color: s.support.urgentTickets > 0 ? crm.danger : crm.warning,
                footnote: s.support.urgentTickets > 0 ? tr.dashUrgentAlert(s.support.urgentTickets) : tr.dashAllClear,
                emphasize: s.support.urgentTickets > 0,
                onTap: () => Get.offAllNamed(Routes.afterSales),
              ),
              _KpiCard(
                label: tr.dashAppointmentsToday,
                value: s.operations.appointmentsToday,
                icon: HugeIcons.strokeRoundedCalendar03,
                color: context.colors.tertiary,
                footnote: tr.dashPendingRequests(s.support.pendingRequests),
                onTap: () => Get.offAllNamed(Routes.calendar),
              ),
            ];
            final perRow = constraints.maxWidth > 900 ? 4 : 2;
            final width = (constraints.maxWidth - (perRow - 1) * 14) / perRow;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (var i = 0; i < cards.length; i++)
                  SizedBox(
                    width: width,
                    // Cards rise one after another, 60 ms apart.
                    child: FadeSlideIn.staggered(
                      index: i,
                      step: const Duration(milliseconds: 60),
                      start: const Duration(milliseconds: 80),
                      child: cards[i],
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            const panelStart = Duration(milliseconds: 340);
            final stages = FadeSlideIn(delay: panelStart, child: _StageDonutCard(s));
            final actions = FadeSlideIn(delay: panelStart + AppMotion.stagger * 2, child: _TodayActionsCard(s, c));
            if (constraints.maxWidth < 900) {
              return Column(children: [stages, const SizedBox(height: 16), actions]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: stages),
                const SizedBox(width: 16),
                Expanded(child: actions),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Active (open) prospects per stage as a donut with a tappable legend.
class _StageDonutCard extends StatelessWidget {
  const _StageDonutCard(this.s);

  final DashboardSummary s;

  @override
  Widget build(BuildContext context) {
    final stages = [
      for (final st in s.stages)
        if (st.type == StageType.open && (st.prospectsCount ?? 0) > 0) st,
    ];
    final total = stages.fold<int>(0, (sum, st) => sum + (st.prospectsCount ?? 0));
    return SectionCard(
      title: tr.dashProspectsByStage,
      icon: HugeIcons.strokeRoundedPieChart,
      child: stages.isEmpty
          ? EmptyView(compact: true, title: tr.noStages)
          : DonutChart(
              size: 190,
              centerValue: Formatters.number(total),
              centerLabel: tr.stageTypeOpen,
              data: [
                for (final st in stages) ChartDatum(label: st.name, value: st.prospectsCount ?? 0, color: st.color),
              ],
              onTap: (i) => Get.offAllNamed(Routes.prospects, parameters: {'stage_id': '${stages[i].id}'}),
            ),
    );
  }
}

/// Today's pending follow-ups with call/WhatsApp and a one-click "done".
class _TodayActionsCard extends StatelessWidget {
  const _TodayActionsCard(this.s, this.c);

  final DashboardSummary s;
  final DashboardController c;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    return SectionCard(
      title: tr.dashTodayActions,
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
      actions: [
        if (s.followUpsOverdue > 0)
          ActionChip(
            avatar: Icon(Icons.circle, size: 8, color: crm.danger),
            label: Text(tr.dashOverdueCount(s.followUpsOverdue)),
            onPressed: () => Get.offAllNamed(Routes.followUps, parameters: {'view': 'overdue'}),
          ),
        TextButton(
          onPressed: () => Get.offAllNamed(Routes.followUps, parameters: {'view': 'today'}),
          child: Text(tr.actionSeeAll),
        ),
      ],
      child: Obx(() {
        final items = c.todayFollowUps;
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                tr.dashAllCaughtUp,
                style: context.text.titleMedium?.copyWith(color: crm.success, fontWeight: FontWeight.w700),
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final f in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  f.prospect?.companyName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  [
                    if (f.dueAt != null) Formatters.time(f.dueAt),
                    if ((f.description ?? '').trim().isNotEmpty) f.description!.trim().split('\n').first,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f.prospect?.phone != null) PhoneCell(f.prospect!.phone, compact: true),
                    IconButton(
                      tooltip: tr.dashMarkDone,
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle02, color: crm.success, size: 22),
                      onPressed: () async {
                        if (await showCompleteFollowUpDialog(f) != null) {
                          await c.load();
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.footnote,
    this.extra,
    this.extraColor,
    this.emphasize = false,
  });

  final String label;
  final int value;
  final HugeData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? footnote;
  final String? extra;
  final Color? extraColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) => HoverLift(
    enabled: onTap != null,
    child: Card(
      color: emphasize ? context.crm.dangerContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.lg - 2),
                    ),
                    child: HugeIcon(icon: icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    MirroredHugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 16,
                      color: context.colors.outline,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedCount(
                targetValue: value,
                style: context.text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: emphasize ? context.crm.danger : null,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              if (footnote != null) Text(footnote!, style: context.text.bodySmall?.copyWith(color: color)),
              if (extra != null)
                Text(
                  extra!,
                  style: context.text.bodySmall?.copyWith(color: extraColor ?? color, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Greeting, one-line business summary and the three quick actions.
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner(this.s, this.c);

  final DashboardSummary s;
  final DashboardController c;

  String get _name {
    if (!Get.isRegistered<EmployeeIdentity>()) return '';
    return Get.find<EmployeeIdentity>().username;
  }

  @override
  Widget build(BuildContext context) {
    final name = _name;
    final actions = [
      FilledButton.icon(
        onPressed: () async {
          if (await showProspectFormDialog() != null) await c.load();
        },
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedUserAdd01, size: 18),
        label: Text(tr.dashNewLead),
      ),
      OutlinedButton.icon(
        onPressed: () async {
          if (await showInterventionFormDialog() != null) await c.load();
        },
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedHeadset, size: 18),
        label: Text(tr.dashNewTicket),
      ),
      OutlinedButton.icon(
        onPressed: () async {
          if (await showScheduleSessionDialog(mode: SessionMode.training) != null) {
            await c.load();
          }
        },
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendarAdd01, size: 18),
        label: Text(tr.dashNewMeeting),
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 24,
          runSpacing: 14,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr.dashWelcome(name.isEmpty ? 'Softel' : name),
                  style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Formatters.longDate(DateTime.now())} · '
                  '${tr.dashSummaryLine(s.operations.appointmentsToday, s.support.urgentTickets, s.openProspects)}',
                  style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ),
      ),
    );
  }
}
