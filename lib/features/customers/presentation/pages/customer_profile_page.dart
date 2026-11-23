import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/phone_cell.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../../activities/data/models/activity.dart';
import '../../../activities/presentation/dialogs/activity_details_dialog.dart';
import '../../../interventions/data/models/intervention.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../../prospects/data/models/prospect_catalogs.dart';
import '../../../prospects/data/models/stage_history_entry.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../../../scheduling/data/models/appointment.dart';
import '../../../scheduling/presentation/dialogs/appointment_dialogs.dart';
import '../../../scheduling/presentation/dialogs/schedule_session_dialog.dart';
import '../../data/models/customer_models.dart';
import '../controllers/customers_controllers.dart';
import '../dialogs/customer_dialogs.dart';
import '../dialogs/trial_details_dialog.dart';

import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/huge_data.dart';
/// Route `/customers/:id`.
class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  late final int? _id = int.tryParse(Get.parameters['id'] ?? '');
  CustomerProfileController? _controller;

  @override
  void initState() {
    super.initState();
    if (_id != null) {
      _controller = Get.put(
        CustomerProfileController(prospectId: _id, repository: Get.find()),
        tag: 'customer-$_id',
      );
    }
  }

  @override
  void dispose() {
    if (_id != null) {
      Get.delete<CustomerProfileController>(tag: 'customer-$_id');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.customers,
    child: _controller == null
        ? ErrorView(message: tr.invalidProspectId)
        : _ProfileBody(_controller!),
  );
}

/// Index of the "Prospect archive" tab (target of the header shortcut).
const _archiveTab = 5;

/// 360° hub: header + six tabs. The prospect phase is temporary; this page is
/// the customer's lifetime record.
class _ProfileBody extends StatefulWidget {
  const _ProfileBody(this.c);

  final CustomerProfileController c;

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 6, vsync: this);

  CustomerProfileController get c => widget.c;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final profile = c.profile.value;
    if (profile == null) {
      return c.state.hasError
          ? ErrorView(
              message: c.state.errorMessage.value ?? '',
              isConnectionError: c.state.isConnectionError,
              onRetry: c.load,
            )
          : LoadingView(message: tr.loadingRecord);
    }
    final p = profile.prospect;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          leading: IconButton(
            tooltip: tr.actionBack,
            icon: const MirroredHugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
            onPressed: () => Get.back(),
          ),
          title: p.companyName,
          subtitle: joinNonEmpty([
            p.contactName,
            p.city,
            tr.wfCustomerSinceDate(Formatters.date(p.convertedAt)),
          ]),
          actions: [
            IconButton(
              tooltip: tr.actionRefresh,
              onPressed: c.load,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh),
            ),
            OutlinedButton.icon(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedClock01, size: 18),
              label: Text(tr.customerViewProspectHistory),
              onPressed: () => _tabController.animateTo(_archiveTab),
            ),
            OutlinedButton.icon(
              onPressed: () => AppNavigation.openProspect(p.id),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedId, size: 18),
              label: Text(tr.wfOpenProspectRecord),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final r = await showScheduleSessionDialog(
                  mode: SessionMode.training,
                  customer: p.toRef(),
                );
                if (r != null) {
                  AppFeedback.success(tr.wfSessionScheduled);
                  await c.load();
                }
              },
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedMortarboard01, size: 18),
              label: Text(tr.wfScheduleTraining),
            ),
            FilledButton.icon(
              onPressed: () async {
                final trial = await showTrialDialog(prospectId: p.id);
                if (trial != null) {
                  AppFeedback.success(tr.wfTrialActivated);
                  await c.load();
                }
              },
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedMedicine01, size: 18),
              label: Text(tr.wfNewTrial),
            ),
          ],
        ),
        _BadgesRow(profile),
        RefreshingBar(visible: c.state.isLoading),
        if (c.state.hasError)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 8),
            child: ErrorBanner(
              message: tr.dataMaybeStale(c.state.errorMessage.value ?? ''),
              onRetry: c.load,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              _tab(HugeIcons.strokeRoundedPackage, tr.customerTabLicenses),
              _tab(HugeIcons.strokeRoundedCreditCard, tr.customerTabBilling),
              _tab(HugeIcons.strokeRoundedHeadset, tr.customerTabSupport),
              _tab(HugeIcons.strokeRoundedCalendar03, tr.customerTabAppointments),
              _tab(HugeIcons.strokeRoundedUserCheck01, tr.customerTabPortal),
              _tab(HugeIcons.strokeRoundedTime02, tr.customerTabProspectArchive),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _TabScroll([
                _InfoCard(p),
                _ProductsCard(profile.products),
                _SubscriptionsCard(
                  profile.subscriptions.where((s) => !s.isMaintenance).toList(),
                  title: tr.customerSubscriptionLifetime,
                  onOpen: () => Get.toNamed(Routes.billingCustomer(p.id)),
                ),
              ]),
              _TabScroll([
                _SubscriptionsCard(
                  profile.subscriptions.where((s) => s.isMaintenance).toList(),
                  title: tr.customerSubscriptionMaintenance,
                  onOpenBilling: () => Get.toNamed(Routes.billingCustomer(p.id)),
                  onOpen: () => Get.toNamed(Routes.billingCustomer(p.id)),
                ),
              ]),
              _TabScroll([_InterventionsCard(profile.interventions)]),
              _TabScroll([_AppointmentsCard(profile.appointments, onChanged: c.load)]),
              _TabScroll([_PortalCard(profile.portalAccounts)]),
              _TabScroll([
                _ProspectDataCard(p),
                _StageTimelineCard(profile.stageHistory),
                _ProspectActivitiesCard(profile.activities, onChanged: c.load),
                _TrialsCard(c: c, trials: profile.trials),
              ]),
            ],
          ),
        ),
      ],
    );
  });

  Tab _tab(HugeData icon, String label) => Tab(
    height: 44,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [HugeIcon(icon: icon, size: 18), const SizedBox(width: 8), Text(label)],
    ),
  );
}

/// One scrollable tab page with consistent spacing between cards.
class _TabScroll extends StatelessWidget {
  const _TabScroll(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsetsDirectional.fromSTEB(28, 16, 28, 28),
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(height: 16),
        children[i],
      ],
    ],
  );
}

/// Brand badge, maintenance status and the phone with its WhatsApp shortcut.
class _BadgesRow extends StatelessWidget {
  const _BadgesRow(this.profile);

  final CustomerProfile profile;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final m = profile.maintenance;
    final active = m != null && m.isActive;
    final until = m?.expiresAt;
    final maintenanceLabel = m == null
        ? tr.customerMaintenanceNone
        : active
            ? (until == null
                ? tr.statusActive
                : tr.customerMaintenanceActiveUntil(Formatters.date(until)))
            : tr.customerMaintenanceExpired;
    final maintenanceColor = m == null
        ? context.colors.outline
        : active
            ? (m.status == 'expiring_soon' ? crm.warning : crm.success)
            : crm.danger;
    final phone = profile.prospect.phone;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          StatusBadge(label: tr.customerSoftelClient, color: context.colors.primary),
          StatusBadge(label: maintenanceLabel, color: maintenanceColor),
          if (phone != null) PhoneCell(phone, compact: true),
        ],
      ),
    );
  }
}

class _SubscriptionsCard extends StatelessWidget {
  const _SubscriptionsCard(this.items, {required this.title, this.onOpenBilling, this.onOpen});

  final List<CustomerSubscription> items;
  final String title;
  final VoidCallback? onOpenBilling;

  /// Tapping a plan opens the customer's billing page (quotes, invoices).
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: title,
    icon: HugeIcons.strokeRoundedCreditCard,
    actions: [
      if (onOpenBilling != null)
        TextButton.icon(
          onPressed: onOpenBilling,
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedCreditCard, size: 18),
          label: Text(tr.customerOpenBilling),
        ),
    ],
    child: items.isEmpty
        ? EmptyView(compact: true, title: tr.customerNoSubscriptions)
        : Column(
            children: [
              for (final s in items)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: onOpen,
                  leading: const HugeIcon(icon: HugeIcons.strokeRoundedCreditCard, size: 20),
                  title: Text(
                    s.isMaintenance
                        ? tr.customerSubscriptionMaintenance
                        : tr.customerSubscriptionLifetime,
                  ),
                  subtitle: Text(
                    s.expiresAt == null
                        ? Formatters.date(s.startsAt)
                        : tr.customerSubscriptionPeriod(
                            Formatters.date(s.startsAt),
                            Formatters.date(s.expiresAt),
                          ),
                  ),
                  trailing: StatusBadge(
                    label: s.isActive
                        ? (s.status == 'expiring_soon' && s.daysRemaining != null
                            ? '${s.daysRemaining} d'
                            : tr.statusActive)
                        : tr.wfStatusExpired,
                    color: !s.isActive
                        ? context.crm.danger
                        : s.status == 'expiring_soon'
                            ? context.crm.warning
                            : context.crm.success,
                  ),
                ),
            ],
          ),
  );
}

class _InterventionsCard extends StatelessWidget {
  const _InterventionsCard(this.items);

  final List<Intervention> items;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.customerTabSupport,
    icon: HugeIcons.strokeRoundedHeadset,
    child: items.isEmpty
        ? EmptyView(compact: true, title: tr.customerNoInterventions)
        : Column(
            children: [
              for (final i in items)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  mouseCursor: SystemMouseCursors.click,
                  hoverColor: context.colors.primary.withValues(alpha: 0.06),
                  onTap: () => Get.toNamed(Routes.afterSalesDetail(i.id)),
                  leading: const HugeIcon(icon: HugeIcons.strokeRoundedHeadset, size: 20),
                  title: Text(joinNonEmpty([i.reference, i.title])),
                  subtitle: Text(
                    joinNonEmpty([
                      i.type?.name,
                      i.priority?.name,
                      i.assignedEmployee,
                      Formatters.dateTime(i.createdAt),
                    ]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (i.status != null)
                        StatusBadge(
                          label: i.status!.name,
                          color: i.status!.isClosed
                              ? context.colors.outline
                              : context.colors.primary,
                        ),
                      const SizedBox(width: 6),
                      const MirroredHugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 16),
                    ],
                  ),
                ),
            ],
          ),
  );
}

/// Original prospect data: where the customer came from.
class _ProspectDataCard extends StatelessWidget {
  const _ProspectDataCard(this.p);

  final Prospect p;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.prospectInitialData,
    icon: HugeIcons.strokeRoundedId,
    child: Column(
      children: [
        InfoRow(
          label: tr.fieldSource,
          value: ProspectCatalogs.displayWithDetails(p.source, p.sourceDetails ?? p.sourceOther),
        ),
        InfoRow(
          label: tr.fieldBusinessActivity,
          value: ProspectCatalogs.displayWithDetails(p.businessActivity, p.businessActivityDetails),
        ),
        InfoRow(
          label: tr.fieldPreviousSoftware,
          value: ProspectCatalogs.displayWithDetails(p.previousSoftware, p.previousSoftwareDetails),
        ),
        InfoRow(label: tr.customerInitialInquiryDate, value: Formatters.date(p.createdAt)),
        if (p.notes != null && p.notes!.trim().isNotEmpty)
          InfoRow(label: tr.customerProspectNotes, value: p.notes),
      ],
    ),
  );
}

/// Visual timeline of the stages the customer went through as a prospect.
class _StageTimelineCard extends StatelessWidget {
  const _StageTimelineCard(this.entries);

  final List<StageHistoryEntry> entries;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.prospectStageTimeline,
    icon: HugeIcons.strokeRoundedTimeline,
    child: entries.isEmpty
        ? EmptyView(compact: true, title: tr.customerNoStageHistory)
        : Column(
            children: [
              for (final e in entries)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: e.toStage == null
                      ? const HugeIcon(icon: HugeIcons.strokeRoundedTime02, size: 20)
                      : StageDot(e.toStage!),
                  title: Text(
                    e.fromStage == null
                        ? (e.toStage?.name ?? '')
                        : '${e.fromStage!.name}  →  ${e.toStage?.name ?? ''}',
                  ),
                  subtitle: Text(
                    joinNonEmpty([
                      Formatters.dateTime(e.changedAt),
                      e.lossReason?.label,
                      e.lossDetails,
                    ]),
                  ),
                ),
            ],
          ),
  );
}

/// Calls, meetings and messages logged before the conversion.
class _ProspectActivitiesCard extends StatelessWidget {
  const _ProspectActivitiesCard(this.activities, {required this.onChanged});

  final List<Activity> activities;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.customerProspectActivities,
    icon: HugeIcons.strokeRoundedNote01,
    child: activities.isEmpty
        ? EmptyView(compact: true, title: tr.customerNoProspectActivities)
        : Column(
            children: [
              for (final a in activities)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    final updated = await showActivityDetailsDialog(a);
                    if (updated != null) await onChanged();
                  },
                  leading: const HugeIcon(icon: HugeIcons.strokeRoundedNote01, size: 20),
                  title: Text(a.headline, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    joinNonEmpty([
                      a.type.label,
                      Formatters.dateTime(a.occurredAt),
                      a.outcome,
                    ]),
                  ),
                ),
            ],
          ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(this.p);

  final Prospect p;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.sectionInformation,
    icon: HugeIcons.strokeRoundedId,
    child: Column(
      children: [
        InfoRow(label: tr.fieldContact, value: p.contactName),
        InfoRow(label: tr.fieldPhone, child: PhoneCell(p.phone)),
        InfoRow(label: tr.fieldEmail, value: p.email),
        InfoRow(label: tr.fieldCity, value: p.city),
        InfoRow(
          label: tr.wfConvertedBy,
          value: joinNonEmpty([
            Formatters.dateTime(p.convertedAt),
            p.convertedBy,
          ]),
        ),
        if (p.conversionNote != null)
          InfoRow(label: tr.wfConversionNote, value: p.conversionNote),
      ],
    ),
  );
}

class _ProductsCard extends StatelessWidget {
  const _ProductsCard(this.products);

  final List<CustomerProduct> products;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.wfCustomerProducts,
    icon: HugeIcons.strokeRoundedPackageOpen,
    child: products.isEmpty
        ? EmptyView(compact: true, title: tr.wfNoCustomerProducts)
        : Column(
            children: [
              for (final p in products)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const HugeIcon(icon: HugeIcons.strokeRoundedPackageOpen, size: 20),
                  title: Text(p.name),
                  subtitle: Text(
                    tr.wfPurchasedOn(Formatters.date(p.purchasedAt)),
                  ),
                ),
            ],
          ),
  );
}

class _PortalCard extends StatelessWidget {
  const _PortalCard(this.accounts);

  final List<PortalAccount> accounts;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.wfPortalAccounts,
    subtitle: tr.wfPortalAccountsHint,
    icon: HugeIcons.strokeRoundedGlobe02,
    child: accounts.isEmpty
        ? EmptyView(compact: true, title: tr.wfNoPortalAccount)
        : Column(
            children: [
              for (final a in accounts)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const HugeIcon(icon: HugeIcons.strokeRoundedUserCircle),
                  title: Text(a.name),
                  subtitle: Text(
                    joinNonEmpty([
                      a.email,
                      tr.wfLastLogin(Formatters.dateTime(a.lastLoginAt)),
                    ]),
                  ),
                  trailing: StatusBadge(
                    label: a.isActive ? tr.statusActive : tr.statusInactive,
                    color: a.isActive
                        ? context.crm.success
                        : context.colors.outline,
                  ),
                ),
            ],
          ),
  );
}

class _TrialsCard extends StatelessWidget {
  const _TrialsCard({required this.c, required this.trials});

  final CustomerProfileController c;
  final List<Trial> trials;

  Future<void> _revoke(Trial t) async {
    final ok = await showConfirmDialog(
      title: tr.wfRevokeTrialTitle,
      message: tr.wfRevokeTrialBody(t.product.name),
      confirmLabel: tr.wfRevoke,
      destructive: true,
    );
    if (!ok) return;
    final result = await c.revokeTrial(t);
    if (result.isSuccess) {
      AppFeedback.success(tr.wfTrialRevokedDone);
    } else {
      AppFeedback.error(result.error!);
    }
  }

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.wfTrials,
    icon: HugeIcons.strokeRoundedMedicine01,
    child: trials.isEmpty
        ? EmptyView(compact: true, title: tr.wfNoTrials)
        : Column(
            children: [
              for (final t in trials)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    if (await showTrialDetailsDialog(t)) await c.load();
                  },
                  leading: const HugeIcon(icon: HugeIcons.strokeRoundedMedicine01, size: 20),
                  title: Text(t.product.name),
                  subtitle: Text(
                    joinNonEmpty([
                      '${Formatters.date(t.startsAt)} → ${Formatters.date(t.endsAt)}',
                      t.url,
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (t.url != null && t.url!.isNotEmpty) ...[
                        IconButton(
                          tooltip: tr.copyDemoLink,
                          icon: const HugeIcon(icon: HugeIcons.strokeRoundedLink01, size: 18),
                          onPressed: () => copyDemoLink(t.url!),
                        ),
                        IconButton(
                          tooltip: tr.openDemoLink,
                          icon: const HugeIcon(icon: HugeIcons.strokeRoundedLinkSquare02, size: 18),
                          onPressed: () => launchDemoLink(t.url!),
                        ),
                      ],
                      StatusBadge(
                        label: t.stateLabel,
                        color: t.isActive
                            ? context.crm.success
                            : context.colors.outline,
                      ),
                      if (t.canRevoke)
                        Obx(
                          () => IconButton(
                            tooltip: tr.wfRevoke,
                            icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel02, size: 20),
                            onPressed: c.busyTrialIds.contains(t.id)
                                ? null
                                : () => _revoke(t),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
  );
}

class _AppointmentsCard extends StatelessWidget {
  const _AppointmentsCard(this.appointments, {required this.onChanged});

  final List<Appointment> appointments;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.wfAppointments,
    subtitle: tr.wfAppointmentsHint,
    icon: HugeIcons.strokeRoundedCalendar01,
    child: appointments.isEmpty
        ? EmptyView(compact: true, title: tr.wfNoAppointments)
        : Column(
            children: [
              for (final a in appointments)
 ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    if (await showAppointmentDetailDialog(a)) await onChanged();
                  },
                  leading: HugeIcon(icon: 
                    a.status.isDone ? HugeIcons.strokeRoundedCheckmarkCircle02 : HugeIcons.strokeRoundedCalendar03,
                    color: a.status.isDone
                        ? context.crm.success
                        : context.colors.primary,
                  ),
                  title: Text(a.displayTitle),
                  subtitle: Text(
                    joinNonEmpty([
                      Formatters.dateTime(a.startsAt),
                      a.product?.name,
                      a.assignedEmployee,
                    ]),
                  ),
                  trailing: AppointmentStatusBadge(status: a.status),
                ),
            ],
          ),
  );
}
