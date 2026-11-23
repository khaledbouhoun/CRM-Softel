import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/phone_cell.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../../activities/presentation/dialogs/activity_details_dialog.dart';
import '../../../customers/data/models/customer_models.dart';
import '../../../customers/presentation/dialogs/trial_details_dialog.dart';
import '../../../scheduling/presentation/dialogs/appointment_dialogs.dart';
import '../../../customers/domain/customers_repository.dart';
import '../../../activities/presentation/dialogs/activity_form_dialog.dart';
import '../../../activities/presentation/widgets/activity_widgets.dart';
import '../../../follow_ups/data/models/follow_up.dart';
import '../../../follow_ups/presentation/dialogs/follow_up_dialogs.dart';
import '../../../follow_ups/presentation/widgets/follow_up_widgets.dart';
import '../../../products/presentation/widgets/product_selector.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../../../customers/presentation/dialogs/customer_dialogs.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_catalogs.dart';
import '../controllers/prospect_details_controller.dart';
import '../dialogs/prospect_dialogs.dart';

import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/huge_data.dart';
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

/// Prospect hub: sticky header + five tabs (same pattern as the customer
/// profile).
class _DetailsBody extends StatefulWidget {
  const _DetailsBody(this.c);

  final ProspectDetailsController c;

  @override
  State<_DetailsBody> createState() => _DetailsBodyState();
}

class _DetailsBodyState extends State<_DetailsBody> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);

  ProspectDetailsController get c => widget.c;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Tab _tab(HugeData icon, String label) => Tab(
    height: 44,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [HugeIcon(icon: icon, size: 18), const SizedBox(width: 8), Text(label)],
    ),
  );

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
        _BadgesRow(prospect),
        RefreshingBar(visible: c.prospectState.isLoading),
        if (c.prospectState.hasError)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 8),
            child: ErrorBanner(
              message: tr.dataMaybeStale(c.prospectState.errorMessage.value ?? ''),
              onRetry: c.loadProspect,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              _tab(HugeIcons.strokeRoundedPackage, tr.prospectTabOverview),
              _tab(HugeIcons.strokeRoundedTimeline, tr.prospectTabPipeline),
              _tab(HugeIcons.strokeRoundedNote01, tr.prospectTabFollowUps),
              _tab(HugeIcons.strokeRoundedTime02, tr.prospectTabActivities),
              _tab(HugeIcons.strokeRoundedPlayCircle, tr.prospectTabDemos),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _TabScroll([_InfoSection(prospect), _ProductsSection(c: c, prospect: prospect)]),
              _TabScroll([_StageSection(c: c, prospect: prospect), _HistorySection(c)]),
              _TabScroll([_FollowUpsSection(c: c, prospect: prospect)]),
              _TabScroll([_TimelineSection(c: c, prospect: prospect)]),
              _TabScroll([_DemosSection(prospect)]),
            ],
          ),
        ),
      ],
    );
  });
}

class _TabScroll extends StatelessWidget {
  const _TabScroll(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsetsDirectional.fromSTEB(28, 16, 28, 28),
    children: [
      for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 16), children[i]],
    ],
  );
}

/// Current stage pill, creation date and phone with its WhatsApp shortcut.
class _BadgesRow extends StatelessWidget {
  const _BadgesRow(this.p);

  final Prospect p;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 8),
    child: Wrap(
      spacing: 10,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        StageChip(stage: p.stage),
        Text(
          tr.createdOnDate(Formatters.date(p.createdAt)),
          style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
        ),
        if (p.phone != null && p.phone!.trim().isNotEmpty) ...[
          PhoneCell(p.phone, compact: true),
        ],
      ],
    ),
  );
}

/// Demo trials (with a copy-link action) and the demo/training appointments of
/// this prospect, read from the same profile endpoint customers use.
class _DemosSection extends StatefulWidget {
  const _DemosSection(this.prospect);

  final Prospect prospect;

  @override
  State<_DemosSection> createState() => _DemosSectionState();
}

class _DemosSectionState extends State<_DemosSection> {
  CustomerProfile? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await Get.find<CustomersRepository>().getCustomer(widget.prospect.id);
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _newTrial() async {
    final trial = await showTrialDialog(prospectId: widget.prospect.id);
    if (trial == null) return;
    AppFeedback.success(tr.wfTrialActivated);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) ErrorBanner(message: _error!, onRetry: _load),
        const SizedBox(height: 8),
        SectionCard(
          title: tr.wfTrials,
          icon: HugeIcons.strokeRoundedPlayCircle,
          actions: [
            TextButton.icon(
              onPressed: _newTrial,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18),
              label: Text(tr.wfNewTrial),
            ),
          ],
          child: profile == null || profile.trials.isEmpty
              ? EmptyView(compact: true, title: tr.wfNoTrials)
              : Column(
                  children: [
                    for (final t in profile.trials)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onTap: () async {
                          if (await showTrialDetailsDialog(t)) await _load();
                        },
                        leading: const HugeIcon(icon: HugeIcons.strokeRoundedPlayCircle, size: 20),
                        title: Text(t.product.name),
                        subtitle: Text(
                          joinNonEmpty(['${Formatters.date(t.startsAt)} → ${Formatters.date(t.endsAt)}', t.url]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (t.url != null && t.url!.isNotEmpty)
                              IconButton(
                                tooltip: tr.copyDemoLink,
                                icon: const HugeIcon(icon: HugeIcons.strokeRoundedLink01, size: 18),
                                onPressed: () => copyDemoLink(t.url!),
                              ),
                            StatusBadge(
                              label: t.stateLabel,
                              color: t.isActive ? context.crm.success : context.colors.outline,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: tr.wfAppointments,
          icon: HugeIcons.strokeRoundedCalendar03,
          child: profile == null || profile.appointments.isEmpty
              ? EmptyView(compact: true, title: tr.wfNoAppointments)
              : Column(
                  children: [
                    for (final a in profile.appointments)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onTap: () async {
                          if (await showAppointmentDetailDialog(a)) await _load();
                        },
                        leading: const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, size: 20),
                        title: Text(a.displayTitle),
                        subtitle: Text(
                          joinNonEmpty([Formatters.dateTime(a.startsAt), a.product?.name, a.assignedEmployee]),
                        ),
                        trailing: AppointmentStatusBadge(status: a.status),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
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

  /// Explicit, audited prospect -> customer transition. The record, its
  /// history and its product interests are kept.
  Future<void> _convert() async {
    final converted = await showConvertProspectDialog(prospect);
    if (converted == null) return;
    await c.loadAll();
    AppFeedback.success(tr.wfConverted(prospect.companyName));
  }
  Future<void> _scheduleFollowUp() async {
    final saved = await showFollowUpFormDialog(prospect: prospect.toRef());
    if (saved != null) await c.onFollowUpChanged();
  }

  @override
  Widget build(BuildContext context) => PageHeader(
    leading: IconButton(tooltip: tr.actionBack, icon: const MirroredHugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01), onPressed: () => Get.back()),
    title: prospect.companyName,
    subtitle: [
      if (prospect.contactName != null) prospect.contactName!,
      if (prospect.city != null) prospect.city!,
      tr.createdOnDate(Formatters.date(prospect.createdAt)),
      if (prospect.isCustomer) tr.wfCustomerBadge,
    ].join('  ·  '),
    actions: [
      IconButton(tooltip: tr.actionRefresh, onPressed: c.loadAll, icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh)),
      OutlinedButton.icon(
        onPressed: _edit,
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedEdit02, size: 18),
        label: Text(tr.actionEdit),
      ),
      OutlinedButton.icon(
        onPressed: _scheduleFollowUp,
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendarCheck01, size: 18),
        label: Text(tr.scheduleFollowUp),
      ),
      OutlinedButton.icon(
        onPressed: _addActivity,
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedMessageAdd01, size: 18),
        label: Text(tr.addActivity),
      ),
      if (prospect.isCustomer)
        OutlinedButton.icon(
          onPressed: () => Get.toNamed(Routes.customer(prospect.id)),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedBuilding02, size: 18),
          label: Text(tr.wfOpenCustomerProfile),
        )
      else
        OutlinedButton.icon(
          onPressed: _convert,
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge01, size: 18),
          label: Text(tr.wfConvertAction),
        ),      FilledButton.icon(
        onPressed: _changeStage,
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeftRight, size: 18),
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
    icon: HugeIcons.strokeRoundedId,
    child: Column(
      children: [
        InfoRow(label: tr.fieldCompany, value: p.companyName, icon: HugeIcons.strokeRoundedBuilding03),
        InfoRow(label: tr.fieldContact, value: p.contactName, icon: HugeIcons.strokeRoundedUser),
        InfoRow(
          label: tr.fieldPhone,
          icon: HugeIcons.strokeRoundedCall,
          child: PhoneCell(p.phone),
        ),
        InfoRow(label: tr.fieldEmail, value: p.email, icon: HugeIcons.strokeRoundedAt),
        InfoRow(label: tr.fieldAddress, value: p.address, icon: HugeIcons.strokeRoundedLocation01),
        InfoRow(label: tr.fieldCity, value: p.city, icon: HugeIcons.strokeRoundedCity01),
        InfoRow(
          label: tr.fieldBusinessActivity,
          value: ProspectCatalogs.displayWithDetails(p.businessActivity, p.businessActivityDetails),
          icon: HugeIcons.strokeRoundedStore01,
        ),
        InfoRow(
          label: ProspectCatalogs.professionLabel,
          value: ProspectCatalogs.displayWithDetails(p.profession, p.professionDetails),
          icon: HugeIcons.strokeRoundedBriefcase01,
        ),
        InfoRow(
          label: tr.fieldSource,
          value: ProspectCatalogs.displayWithDetails(p.source, p.sourceDetails ?? p.sourceOther),
          icon: HugeIcons.strokeRoundedMegaphone01,
        ),
        InfoRow(
          label: tr.fieldPreviousSoftware,
          value: ProspectCatalogs.displayWithDetails(p.previousSoftware, p.previousSoftwareDetails),
          icon: HugeIcons.strokeRoundedGridView,
        ),
        InfoRow(label: tr.fieldNotes, value: p.notes, icon: HugeIcons.strokeRoundedNote01),
        InfoRow(label: tr.updatedLabel, value: Formatters.dateTime(p.updatedAt), icon: HugeIcons.strokeRoundedRefresh),
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
    icon: HugeIcons.strokeRoundedPackageOpen,
    actions: [
      TextButton.icon(
        onPressed: () async {
          final updated = await showProspectProductsDialog(prospect);
          if (updated == null) return;
          c.onProspectSaved(updated);
          AppFeedback.success(tr.productsUpdated);
        },
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedEdit02, size: 18),
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
      icon: HugeIcons.strokeRoundedMenu01,
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
            StatusPill(label: tr.saleWon, color: crm.success, icon: HugeIcons.strokeRoundedAward01),
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
      icon: HugeIcons.strokeRoundedTimeline,
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
                                const MirroredHugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 14),
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
      icon: HugeIcons.strokeRoundedCalendar02,
      actions: [
        TextButton.icon(
          onPressed: () => _after(showFollowUpFormDialog(prospect: prospect.toRef())),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18),
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
                phone: prospect.phone,
                onTap: () => _after(showFollowUpFormDialog(existing: f)),
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
      icon: HugeIcons.strokeRoundedHistory,
      actions: [
        TextButton.icon(
          onPressed: () async {
            final result = await showActivityFormDialog(prospect: prospect.toRef());
            if (result != null) await c.onActivityAdded();
          },
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18),
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
              ActivityTimelineTile(
                activity: c.activities[i],
                isLast: i == c.activities.length - 1,
                onTap: () async {
                  final updated = await showActivityDetailsDialog(c.activities[i]);
                  if (updated != null) await c.onActivityAdded();
                },
              ),
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
