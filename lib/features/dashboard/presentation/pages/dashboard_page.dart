import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/charts.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../activities/presentation/widgets/activity_widgets.dart';
import '../../data/models/dashboard_summary.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../app/l10n/l10n.dart';

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
                : tr.dashUpdatedAt(
                    Formatters.time(controller.lastUpdatedAt.value),
                  ),
            actions: [
              OutlinedButton.icon(
                onPressed: controller.state.isLoading ? null : controller.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ],
          ),
        ),
        Obx(
          () => RefreshingBar(
            visible:
                controller.state.isLoading && controller.summary.value != null,
          ),
        ),
        Expanded(
          child: Obx(() {
            final summary = controller.summary.value;
            return LoadStateView(
              state: controller.state,
              isEmpty: summary == null,
              onRetry: controller.load,
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
            child: ErrorBanner(
              message: tr.dashStale(c.state.errorMessage.value ?? ''),
              onRetry: c.load,
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _KpiCard(
                label: tr.navProspects,
                value: s.totalProspects,
                icon: Icons.people_alt_outlined,
                color: context.colors.primary,
                onTap: () => Get.offAllNamed(Routes.prospects),
              ),
              _KpiCard(
                label: tr.stageTypeOpen,
                value: s.openProspects,
                icon: Icons.trending_up,
                color: crm.info,
                onTap: () => Get.offAllNamed(Routes.pipeline),
              ),
              _KpiCard(
                label: tr.dashWon,
                value: s.wonProspects,
                icon: Icons.emoji_events_outlined,
                color: crm.success,
                footnote: winRate == null
                    ? null
                    : tr.dashWinRate((winRate * 100).toStringAsFixed(0)),
              ),
              _KpiCard(
                label: tr.dashLost,
                value: s.lostProspects,
                icon: Icons.do_not_disturb_on_outlined,
                color: crm.danger,
              ),
              _KpiCard(
                label: tr.dashFollowUpsToday,
                value: s.followUpsToday,
                icon: Icons.today_outlined,
                color: crm.warning,
                onTap: () => Get.offAllNamed(
                  Routes.followUps,
                  parameters: {'view': 'today'},
                ),
              ),
              _KpiCard(
                label: tr.dashFollowUpsOverdue,
                value: s.followUpsOverdue,
                icon: Icons.warning_amber_rounded,
                color: crm.danger,
                emphasize: s.followUpsOverdue > 0,
                onTap: () => Get.offAllNamed(
                  Routes.followUps,
                  parameters: {'view': 'overdue'},
                ),
              ),
              _KpiCard(
                // The server counts only the next N days; the list shows all.
                label: s.upcomingWindowDays == null
                    ? tr.dashFollowUpsUpcoming
                    : tr.dashFollowUpsUpcomingDays(s.upcomingWindowDays!),
                value: s.followUpsUpcoming,
                icon: Icons.event_outlined,
                color: context.colors.tertiary,
                onTap: () => Get.offAllNamed(
                  Routes.followUps,
                  parameters: {'view': 'upcoming'},
                ),
              ),
            ];
            final perRow = constraints.maxWidth > 1400
                ? 7
                : (constraints.maxWidth > 1000 ? 4 : 2);
            final width = (constraints.maxWidth - (perRow - 1) * 14) / perRow;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final card in cards) SizedBox(width: width, child: card),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _TwoColumns(
          left: SectionCard(
            title: tr.dashProspectsByStage,
            icon: Icons.bar_chart,
            subtitle: tr.dashClickStage,
            child: s.stages.isEmpty
                ? EmptyView(compact: true, title: tr.noStages)
                : HorizontalBarChart(
                    data: [
                      for (final st in s.stages)
                        ChartDatum(
                          label: st.name,
                          value: st.prospectsCount ?? 0,
                          color: st.color,
                        ),
                    ],
                    onTap: (i) => Get.offAllNamed(
                      Routes.prospects,
                      parameters: {'stage_id': '${s.stages[i].id}'},
                    ),
                  ),
          ),
          right: SectionCard(
            title: tr.dashOutcomes,
            icon: Icons.donut_large,
            child: DonutChart(
              centerValue: Formatters.number(s.totalProspects),
              centerLabel: tr.donutProspects,
              data: [
                ChartDatum(
                  label: tr.stageTypeOpen,
                  value: s.openProspects,
                  color: crm.info,
                ),
                ChartDatum(
                  label: tr.dashWon,
                  value: s.wonProspects,
                  color: crm.success,
                ),
                ChartDatum(
                  label: tr.dashLost,
                  value: s.lostProspects,
                  color: crm.danger,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _TwoColumns(
          left: SectionCard(
            title: tr.dashRecentActivities,
            icon: Icons.history,
            actions: [
              TextButton(
                onPressed: () => Get.offAllNamed(Routes.activities),
                child: Text(tr.actionSeeAll),
              ),
            ],
            child: s.recentActivities.isEmpty
                ? EmptyView(compact: true, title: tr.noRecentActivities)
                : Column(
                    children: [
                      for (var i = 0; i < s.recentActivities.length; i++)
                        ActivityTimelineTile(
                          activity: s.recentActivities[i],
                          showProspect: true,
                          isLast: i == s.recentActivities.length - 1,
                        ),
                    ],
                  ),
          ),
          right: s.lostByReason == null
              ? null
              : SectionCard(
                  title: tr.dashWhyLose,
                  icon: Icons.insights_outlined,
                  subtitle: tr.dashLostByReason,
                  child: s.lostByReason!.isEmpty
                      ? EmptyView(compact: true, title: tr.noLostProspects)
                      : HorizontalBarChart(
                          labelWidth: 170,
                          data: [
                            for (final r in s.lostByReason!)
                              ChartDatum(
                                label: r.label,
                                value: r.count,
                                color: crm.danger,
                              ),
                          ],
                          onTap: (i) => Get.offAllNamed(
                            Routes.prospects,
                            parameters: {
                              'loss_reason_id': '${s.lostByReason![i].id}',
                            },
                          ),
                        ),
                ),
        ),
      ],
    );
  }
}

class _TwoColumns extends StatelessWidget {
  const _TwoColumns({required this.left, this.right});

  final Widget left;
  final Widget? right;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (right == null) return left;
      if (constraints.maxWidth < 1000) {
        return Column(children: [left, const SizedBox(height: 16), right!]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: left),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: right!),
        ],
      );
    },
  );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.footnote,
    this.emphasize = false,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? footnote;
  final bool emphasize;

  @override
  Widget build(BuildContext context) => Card(
    color: emphasize ? context.crm.dangerContainer : null,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: context.colors.outline,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              Formatters.number(value),
              style: context.text.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: emphasize ? context.crm.danger : null,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (footnote != null)
              Text(
                footnote!,
                style: context.text.bodySmall?.copyWith(color: color),
              ),
          ],
        ),
      ),
    ),
  );
}
