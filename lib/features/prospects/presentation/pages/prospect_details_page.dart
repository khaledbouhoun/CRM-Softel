import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../activities/presentation/dialogs/activity_form_dialog.dart';
import '../../../activities/presentation/widgets/activity_widgets.dart';
import '../../../follow_ups/data/models/follow_up.dart';
import '../../../follow_ups/presentation/dialogs/follow_up_dialogs.dart';
import '../../../follow_ups/presentation/widgets/follow_up_widgets.dart';
import '../../../products/presentation/widgets/product_selector.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_catalogs.dart';
import '../controllers/prospect_details_controller.dart';
import '../dialogs/prospect_dialogs.dart';

/// Route `/prospects/:id`. Owns a controller tagged with the prospect id so
/// several detail pages can be stacked safely.
class ProspectDetailsPage extends StatefulWidget {
  const ProspectDetailsPage({super.key});

  @override
  State<ProspectDetailsPage> createState() => _ProspectDetailsPageState();
}

class _ProspectDetailsPageState extends State<ProspectDetailsPage> {
  late final int? _id = int.tryParse(Get.parameters['id'] ?? '');
  ProspectDetailsController? _controller;

  @override
  void initState() {
    super.initState();
    if (_id != null) {
      _controller = Get.put(
        ProspectDetailsController(
          prospectId: _id,
          prospectsRepository: Get.find(),
          activitiesRepository: Get.find(),
          followUpsRepository: Get.find(),
        ),
        tag: 'prospect-$_id',
      );
    }
  }

  @override
  void dispose() {
    if (_id != null) {
      Get.delete<ProspectDetailsController>(tag: 'prospect-$_id');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.prospects,
    child: _controller == null ? ErrorView(message: tr.invalidProspectId) : _DetailsBody(_controller!),
  );
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody(this.c);

  final ProspectDetailsController c;

  @override
  Widget build(BuildContext context) => Obx(() {
    final prospect = c.prospect.value;
    if (prospect == null) {
      return c.prospectState.hasError
          ? ErrorView(
              message: c.prospectState.errorMessage.value ?? '',
              isConnectionError: c.prospectState.isConnectionError,
              onRetry: c.loadAll,
            )
          : LoadingView(message: tr.loadingRecord);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(c: c, prospect: prospect),
        RefreshingBar(visible: c.prospectState.isLoading),
        if (c.prospectState.hasError)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 8),
            child: ErrorBanner(
              message: tr.dataMaybeStale(c.prospectState.errorMessage.value ?? ''),
              onRetry: c.loadProspect,
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final left = [
                _InfoSection(prospect),
                _ProductsSection(c: c, prospect: prospect),
                _StageSection(c: c, prospect: prospect),
                _HistorySection(c),
              ];
              final right = [_FollowUpsSection(c: c, prospect: prospect), _TimelineSection(c: c, prospect: prospect)];
              if (constraints.maxWidth < 1050) {
                // Spec order on narrow windows.
                return ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(28, 4, 28, 28),
                  children: _spaced([left[0], left[1], left[2], right[1], right[0], left[3]]),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 4, 28, 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: Column(children: _spaced(left))),
                    const SizedBox(width: 18),
                    Expanded(flex: 6, child: Column(children: _spaced(right))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  });

  static List<Widget> _spaced(List<Widget> children) => [
    for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 16), children[i]],
  ];
}

class _Header extends StatelessWidget {
  const _Header({required this.c, required this.prospect});

  final ProspectDetailsController c;
  final Prospect prospect;

  Future<void> _edit() async {
    final saved = await showProspectFormDialog(initial: prospect);
    if (saved == null) return;
    c.onProspectSaved(saved);
    AppFeedback.success(tr.prospectUpdated);
  }

  Future<void> _changeStage() async {
    final updated = await showStageChangeDialog(prospect);
    if (updated == null) return;
    await c.onStageChanged(updated);
    AppFeedback.success('Étape changée : « ${updated.stage?.name ?? ''} ».');
  }

  Future<void> _addActivity() async {
    final result = await showActivityFormDialog(prospect: prospect.toRef());
    if (result != null) await c.onActivityAdded();
  }

  Future<void> _scheduleFollowUp() async {
    final saved = await showFollowUpFormDialog(prospect: prospect.toRef());
    if (saved != null) await c.onFollowUpChanged();
  }

  @override
  Widget build(BuildContext context) => PageHeader(
    leading: IconButton(tooltip: tr.actionBack, icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
    title: prospect.companyName,
    subtitle: [
      if (prospect.contactName != null) prospect.contactName!,
      if (prospect.city != null) prospect.city!,
      tr.createdOnDate(Formatters.date(prospect.createdAt)),
    ].join('  ·  '),
    actions: [
      IconButton(tooltip: tr.actionRefresh, onPressed: c.loadAll, icon: const Icon(Icons.refresh)),
      OutlinedButton.icon(
        onPressed: _edit,
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: Text(tr.actionEdit),
      ),
      OutlinedButton.icon(
        onPressed: _scheduleFollowUp,
        icon: const Icon(Icons.event_available_outlined, size: 18),
        label: Text(tr.scheduleFollowUp),
      ),
      OutlinedButton.icon(
        onPressed: _addActivity,
        icon: const Icon(Icons.add_comment_outlined, size: 18),
        label: Text(tr.addActivity),
      ),
      FilledButton.icon(
        onPressed: _changeStage,
        icon: const Icon(Icons.swap_horiz, size: 18),
        label: Text(tr.changeStage),
      ),
    ],
  );
}

class _InfoSection extends StatelessWidget {
  const _InfoSection(this.p);

  final Prospect p;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.sectionInformation,
    icon: Icons.badge_outlined,
    child: Column(
      children: [
        InfoRow(label: tr.fieldCompany, value: p.companyName, icon: Icons.business_outlined),
        InfoRow(label: tr.fieldContact, value: p.contactName, icon: Icons.person_outline),
        InfoRow(label: tr.fieldPhone, value: p.phone, icon: Icons.phone_outlined),
        InfoRow(label: tr.fieldEmail, value: p.email, icon: Icons.alternate_email),
        InfoRow(label: tr.fieldAddress, value: p.address, icon: Icons.place_outlined),
        InfoRow(label: tr.fieldCity, value: p.city, icon: Icons.location_city_outlined),
        InfoRow(
          label: tr.fieldBusinessActivity,
          value: ProspectCatalogs.displayWithDetails(p.businessActivity, p.businessActivityDetails),
          icon: Icons.storefront_outlined,
        ),
        InfoRow(
          label: ProspectCatalogs.professionLabel,
          value: ProspectCatalogs.displayWithDetails(p.profession, p.professionDetails),
          icon: Icons.work_outline,
        ),
        InfoRow(
          label: tr.fieldSource,
          value: ProspectCatalogs.displayWithDetails(p.source, p.sourceDetails ?? p.sourceOther),
          icon: Icons.campaign_outlined,
        ),
        InfoRow(
          label: tr.fieldPreviousSoftware,
          value: ProspectCatalogs.displayWithDetails(p.previousSoftware, p.previousSoftwareDetails),
          icon: Icons.apps_outlined,
        ),
        InfoRow(label: tr.fieldNotes, value: p.notes, icon: Icons.notes),
        InfoRow(label: tr.updatedLabel, value: Formatters.dateTime(p.updatedAt), icon: Icons.update),
      ],
    ),
  );
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection({required this.c, required this.prospect});

  final ProspectDetailsController c;
  final Prospect prospect;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.interestedProducts,
    icon: Icons.inventory_2_outlined,
    actions: [
      TextButton.icon(
        onPressed: () async {
          final updated = await showProspectProductsDialog(prospect);
          if (updated == null) return;
          c.onProspectSaved(updated);
          AppFeedback.success(tr.productsUpdated);
        },
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: Text(tr.actionEdit),
      ),
    ],
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: prospect.products.isEmpty
          ? Text(tr.noProductAssociated, style: context.text.bodyMedium)
          : ProductChips(products: prospect.products),
    ),
  );
}

class _StageSection extends StatelessWidget {
  const _StageSection({required this.c, required this.prospect});

  final ProspectDetailsController c;
  final Prospect prospect;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    return SectionCard(
      title: tr.sectionCommercialStage,
      icon: Icons.linear_scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StageChip(stage: prospect.stage),
              const SizedBox(width: 8),
              if (prospect.stage != null) StageTypeBadge(prospect.stage!.type),
            ],
          ),
          if (prospect.isLost) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: crm.dangerContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: crm.danger.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr.opportunityLost, style: context.text.titleSmall?.copyWith(color: crm.danger)),
                  const SizedBox(height: 6),
                  InfoRow(label: tr.reason, value: prospect.lossReason?.label, labelWidth: 90),
                  InfoRow(label: tr.details, value: prospect.lossDetails, labelWidth: 90),
                ],
              ),
            ),
          ],
          if (prospect.isWon) ...[
            const SizedBox(height: 12),
            StatusPill(label: tr.saleWon, color: crm.success, icon: Icons.emoji_events_outlined),
          ],
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection(this.c);

  final ProspectDetailsController c;

  @override
  Widget build(BuildContext context) => Obx(
    () => SectionCard(
      title: tr.stageHistory,
      icon: Icons.timeline,
      child: _SectionState(
        state: c.historyState,
        isEmpty: c.history.isEmpty,
        onRetry: c.loadHistory,
        emptyText: tr.noStageChanges,
        child: Column(
          children: [
            for (final h in c.history)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 112,
                      child: Text(
                        Formatters.dateTime(h.changedAt),
                        style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (h.fromStage != null) ...[
                                StageChip(stage: h.fromStage, dense: true),
                                const Icon(Icons.arrow_forward, size: 14),
                              ] else
                                Text(tr.creationArrow, style: context.text.bodySmall),
                              StageChip(stage: h.toStage, dense: true),
                            ],
                          ),
                          if (h.lossReason != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                tr.lossReasonLine(h.lossReason!.label) +
                                    (h.lossDetails != null ? ' — ${h.lossDetails}' : ''),
                                style: context.text.bodySmall?.copyWith(color: context.crm.danger),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _FollowUpsSection extends StatelessWidget {
  const _FollowUpsSection({required this.c, required this.prospect});

  final ProspectDetailsController c;
  final Prospect prospect;

  Future<void> _after(Future<FollowUp?> action) async {
    if (await action != null) await c.onFollowUpChanged();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final pending = c.pendingFollowUps;
    final closed = c.closedFollowUps;
    return SectionCard(
      title: tr.navFollowUps,
      subtitle: tr.pendingCount(pending.length),
      icon: Icons.event_note_outlined,
      actions: [
        TextButton.icon(
          onPressed: () => _after(showFollowUpFormDialog(prospect: prospect.toRef())),
          icon: const Icon(Icons.add, size: 18),
          label: Text(tr.actionSchedule),
        ),
      ],
      child: _SectionState(
        state: c.followUpsState,
        isEmpty: c.followUps.isEmpty,
        onRetry: c.loadFollowUps,
        emptyText: tr.noFollowUpScheduled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final f in pending)
              FollowUpTile(
                followUp: f,
                onComplete: () => _after(showCompleteFollowUpDialog(f)),
                onEdit: () => _after(showFollowUpFormDialog(existing: f)),
                onCancel: () => _after(showCancelFollowUpDialog(f)),
              ),
            if (closed.isNotEmpty)
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(tr.closedFollowUps(closed.length), style: context.text.bodyMedium),
                  children: [for (final f in closed) FollowUpTile(followUp: f)],
                ),
              ),
          ],
        ),
      ),
    );
  });
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.c, required this.prospect});

  final ProspectDetailsController c;
  final Prospect prospect;

  @override
  Widget build(BuildContext context) => Obx(
    () => SectionCard(
      title: tr.activityHistory,
      subtitle: tr.countActivities(c.activitiesTotal.value),
      icon: Icons.history,
      actions: [
        TextButton.icon(
          onPressed: () async {
            final result = await showActivityFormDialog(prospect: prospect.toRef());
            if (result != null) await c.onActivityAdded();
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(tr.actionAdd),
        ),
      ],
      child: _SectionState(
        state: c.activitiesState,
        isEmpty: c.activities.isEmpty,
        onRetry: c.loadActivities,
        emptyText: tr.noActivitiesForProspect,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < c.activities.length; i++)
              ActivityTimelineTile(activity: c.activities[i], isLast: i == c.activities.length - 1),
            if (c.hasMoreActivities.value)
              Center(
                child: OutlinedButton(
                  onPressed: c.isLoadingMoreActivities.value ? null : c.loadMoreActivities,
                  child: Text(c.isLoadingMoreActivities.value ? tr.loading : tr.showOlderActivities),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Loading / error / empty handling inside a section card.
class _SectionState extends StatelessWidget {
  const _SectionState({
    required this.state,
    required this.isEmpty,
    required this.onRetry,
    required this.emptyText,
    required this.child,
  });

  final LoadState state;
  final bool isEmpty;
  final VoidCallback onRetry;
  final String emptyText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (state.hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ErrorBanner(message: state.errorMessage.value ?? '', onRetry: onRetry),
          if (!isEmpty) ...[const SizedBox(height: 10), child],
        ],
      );
    }
    if (isEmpty) {
      return state.isLoading
          ? const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(emptyText, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
            );
    }
    return child;
  }
}
