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
import '../../../../core/widgets/whatsapp_button.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../../scheduling/data/models/appointment.dart';
import '../../../scheduling/presentation/dialogs/schedule_session_dialog.dart';
import '../../data/models/customer_models.dart';
import '../controllers/customers_controllers.dart';
import '../dialogs/customer_dialogs.dart';

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

class _ProfileBody extends StatelessWidget {
  const _ProfileBody(this.c);

  final CustomerProfileController c;

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
            icon: const Icon(Icons.arrow_back),
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
              icon: const Icon(Icons.refresh),
            ),
            OutlinedButton.icon(
              onPressed: () => AppNavigation.openProspect(p.id),
              icon: const Icon(Icons.badge_outlined, size: 18),
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
              icon: const Icon(Icons.school_outlined, size: 18),
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
              icon: const Icon(Icons.science_outlined, size: 18),
              label: Text(tr.wfNewTrial),
            ),
          ],
        ),
        RefreshingBar(visible: c.state.isLoading),
        if (c.state.hasError)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 8),
            child: ErrorBanner(
              message: tr.dataMaybeStale(c.state.errorMessage.value ?? ''),
              onRetry: c.load,
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final left = [
                _InfoCard(p),
                _ProductsCard(profile.products),
                _PortalCard(profile.portalAccounts),
              ];
              final right = [
                _TrialsCard(c: c, trials: profile.trials),
                _AppointmentsCard(profile.appointments),
              ];
              Widget col(List<Widget> items) => Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    items[i],
                  ],
                ],
              );
              if (constraints.maxWidth < 1050) {
                return ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(28, 4, 28, 28),
                  children: [
                    col([...left, ...right]),
                  ],
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 4, 28, 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: col(left)),
                    const SizedBox(width: 18),
                    Expanded(flex: 6, child: col(right)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  });
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(this.p);

  final Prospect p;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.sectionInformation,
    icon: Icons.badge_outlined,
    child: Column(
      children: [
        InfoRow(label: tr.fieldContact, value: p.contactName),
        InfoRow(
          label: tr.fieldPhone,
          child: Row(
            children: [
              Flexible(child: SelectableText(p.phone ?? '—')),
              if (p.phone != null) ...[
                const SizedBox(width: 8),
                WhatsAppButton(phone: p.phone, dense: true),
              ],
            ],
          ),
        ),
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
    icon: Icons.inventory_2_outlined,
    child: products.isEmpty
        ? EmptyView(compact: true, title: tr.wfNoCustomerProducts)
        : Column(
            children: [
              for (final p in products)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.inventory_2_outlined, size: 20),
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
    icon: Icons.language,
    child: accounts.isEmpty
        ? EmptyView(compact: true, title: tr.wfNoPortalAccount)
        : Column(
            children: [
              for (final a in accounts)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_circle_outlined),
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
    icon: Icons.science_outlined,
    child: trials.isEmpty
        ? EmptyView(compact: true, title: tr.wfNoTrials)
        : Column(
            children: [
              for (final t in trials)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.science_outlined),
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
                            icon: const Icon(Icons.block, size: 20),
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
  const _AppointmentsCard(this.appointments);

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.wfAppointments,
    subtitle: tr.wfAppointmentsHint,
    icon: Icons.event_outlined,
    child: appointments.isEmpty
        ? EmptyView(compact: true, title: tr.wfNoAppointments)
        : Column(
            children: [
              for (final a in appointments)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    a.status.isDone ? Icons.check_circle : Icons.event,
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
