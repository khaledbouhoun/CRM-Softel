import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../data/models/billing_models.dart';
import '../controllers/billing_controllers.dart';
import '../dialogs/billing_dialogs.dart';
import 'billing_widgets.dart';

import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/huge_data.dart';
String _money(int amount) => '${Formatters.number(amount)} ${tr.blCurrency}';

/// Route `/billing/:id`: license, maintenance, renewal requests and invoices
/// of one customer.
class BillingCustomerPage extends StatefulWidget {
  const BillingCustomerPage({super.key});

  @override
  State<BillingCustomerPage> createState() => _BillingCustomerPageState();
}

class _BillingCustomerPageState extends State<BillingCustomerPage> {
  late final int? _id = int.tryParse(Get.parameters['id'] ?? '');
  BillingDetailController? _controller;

  @override
  void initState() {
    super.initState();
    if (_id != null) {
      _controller = Get.put(
        BillingDetailController(prospectId: _id, repository: Get.find()),
        tag: 'billing-$_id',
      );
    }
  }

  @override
  void dispose() {
    if (_id != null) Get.delete<BillingDetailController>(tag: 'billing-$_id');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.billing,
    child: _controller == null
        ? ErrorView(message: tr.invalidProspectId)
        : _Body(_controller!),
  );
}

class _Body extends StatelessWidget {
  const _Body(this.c);

  final BillingDetailController c;

  Future<void> _setMaintenance(CustomerBilling b) async {
    final saved = await showMaintenanceDialog(
      prospectId: b.customerId,
      current: b.maintenance,
    );
    if (saved) {
      AppFeedback.success(tr.blSaved);
      await c.load();
    }
  }

  Future<void> _newInvoice(CustomerBilling b) async {
    if (await showInvoiceFormDialog(prospectId: b.customerId)) {
      AppFeedback.success(tr.blInvoiceCreated);
      await c.load();
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final b = c.billing.value;
    if (b == null) {
      return c.state.hasError
          ? ErrorView(
              message: c.state.errorMessage.value ?? '',
              isConnectionError: c.state.isConnectionError,
              onRetry: c.load,
            )
          : LoadingView(message: tr.loadingRecord);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          leading: IconButton(
            tooltip: tr.blBack,
            icon: const MirroredHugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
            onPressed: () => Get.back(),
          ),
          title: b.customerName,
          subtitle: joinNonEmpty([b.contactPerson, b.phone, b.email]),
          actions: [
            IconButton(
              tooltip: tr.actionRefresh,
              onPressed: c.load,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh),
            ),
            OutlinedButton.icon(
              onPressed: () => _newInvoice(b),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18),
              label: Text(tr.blNewInvoice),
            ),
            FilledButton.icon(
              onPressed: () => _setMaintenance(b),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge01, size: 18),
              label: Text(tr.blSetMaintenance),
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
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 4, 28, 28),
            children: [
              _PlanCards(b),
              const SizedBox(height: 16),
              _RenewalsCard(c: c, billing: b),
              const SizedBox(height: 16),
              _InvoicesCard(c: c, billing: b),
            ],
          ),
        ),
      ],
    );
  });
}

class _PlanCards extends StatelessWidget {
  const _PlanCards(this.b);

  final CustomerBilling b;

  @override
  Widget build(BuildContext context) {
    final m = b.maintenance;
    final license = SectionCard(
      title: tr.blLicense,
      icon: HugeIcons.strokeRoundedAward01,
      child: Column(
        children: [
          InfoRow(label: tr.blLicense, value: tr.blLicenseLifetime),
          InfoRow(label: tr.blLicenseSince, value: Formatters.date(b.licenseSince)),
        ],
      ),
    );
    final maintenance = SectionCard(
      title: tr.blMaintenance,
      icon: HugeIcons.strokeRoundedHeadset,
      child: Column(
        children: [
          InfoRow(
            label: tr.blFilterStatus,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: MaintenanceStatusBadge(m.status),
            ),
          ),
          InfoRow(label: tr.blMaintenanceStarts, value: Formatters.date(m.startsAt)),
          InfoRow(label: tr.blMaintenanceExpires, value: Formatters.date(m.expiresAt)),
          InfoRow(
            label: tr.blColDaysLeft,
            value: m.daysRemaining == null
                ? null
                : '${m.daysRemaining} ${tr.blDaysUnit}',
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 900
          ? Column(children: [license, const SizedBox(height: 16), maintenance])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: license),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: maintenance),
              ],
            ),
    );
  }
}

class _RenewalsCard extends StatelessWidget {
  const _RenewalsCard({required this.c, required this.billing});

  final BillingDetailController c;
  final CustomerBilling billing;

  Future<void> _quote(RenewalRequest r) async {
    if (await showQuoteDialog(detail: c, renewal: r)) {
      AppFeedback.success(tr.blQuoted);
    }
  }

  Future<void> _markPaid(RenewalRequest r) async {
    if (await showMarkPaidDialog(detail: c, renewal: r)) {
      AppFeedback.success(tr.blMarkedPaid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = billing.renewalRequests;
    return SectionCard(
      title: tr.blRenewals,
      icon: HugeIcons.strokeRoundedRefresh,
      child: requests.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(tr.blNoRenewals),
            )
          : Column(
              children: [
                for (final r in requests)
                  _RenewalTile(
                    request: r,
                    detail: c,
                    onQuote: () => _quote(r),
                    onMarkPaid: () => _markPaid(r),
                  ),
              ],
            ),
    );
  }
}

/// One renewal request: the client's order (PCs, dossiers, years, notes) up front so staff can quote straight away.
class _RenewalTile extends StatelessWidget {
  const _RenewalTile({
    required this.request,
    required this.detail,
    required this.onQuote,
    required this.onMarkPaid,
  });

  final RenewalRequest request;
  final BillingDetailController detail;
  final VoidCallback onQuote;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final r = request;
    final notes = (r.notes ?? '').trim();
    final header = [
      if ((r.reference ?? '').isNotEmpty) r.reference!,
      if (r.amountDzd != null) _money(r.amountDzd!),
    ].join(' · ');
    final dateLine = r.isOpen
        ? '${tr.blRequestedOn} ${Formatters.date(r.requestedAt)}'
        : '${tr.blConfirmedOn} ${Formatters.date(r.confirmedAt)}';

    final Widget action;
    if (r.isPendingQuote) {
      action = Obx(
        () => FilledButton.icon(
          key: const ValueKey('renewal-quote-button'),
          onPressed: detail.busyIds.contains(r.id) ? null : onQuote,
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedInvoice01, size: 18),
          label: Text(tr.blQuotePrice),
        ),
      );
    } else if (r.isQuoted) {
      action = Obx(
        () => FilledButton.icon(
          onPressed: detail.busyIds.contains(r.invoiceId ?? r.id) ? null : onMarkPaid,
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedMoneyBag02, size: 18),
          label: Text(tr.blMarkPaid),
        ),
      );
    } else {
      action = StatusBadge(
        label: r.status == RenewalStatus.rejected ? tr.blRenewalRejected : tr.blRenewalConfirmed,
        color: r.status == RenewalStatus.rejected ? context.crm.danger : context.crm.success,
      );
    }

    final scheme = context.colors;
    final stripe = r.isPendingQuote
        ? context.crm.warning
        : r.isQuoted
        ? BrandColors.primary
        : r.status == RenewalStatus.rejected
        ? context.crm.danger
        : context.crm.success;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
        decoration: BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: stripe, width: 4)),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  header.isEmpty ? dateLine : header,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              action,
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _RenewalChip(
                key: const ValueKey('renewal-workstations'),
                icon: HugeIcons.strokeRoundedComputerDesk01,
                text: '${r.workstationsCount} ${tr.blWorkstations}',
              ),
              _RenewalChip(
                key: const ValueKey('renewal-dossiers'),
                icon: HugeIcons.strokeRoundedFolder01,
                text: '${r.dossiersCount} ${tr.blDossiers}',
              ),
              _RenewalChip(
                key: const ValueKey('renewal-years'),
                icon: HugeIcons.strokeRoundedTime02,
                text: '${r.years} ${tr.blRenewalYears}',
              ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HugeIcon(icon: HugeIcons.strokeRoundedNote01, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(notes, key: const ValueKey('renewal-notes'))),
              ],
            ),
          ],
          if (header.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(dateLine, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
        ),
      ),
    );
  }
}

class _RenewalChip extends StatelessWidget {
  const _RenewalChip({super.key, required this.icon, required this.text});

  final HugeData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: BrandColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InvoicesCard extends StatelessWidget {
  const _InvoicesCard({required this.c, required this.billing});

  final BillingDetailController c;
  final CustomerBilling billing;

  Future<void> _markPaid(BillingInvoice i) async {
    if (await showMarkPaidDialog(detail: c, invoice: i)) {
      AppFeedback.success(tr.blMarkedPaid);
    }
  }

  Future<void> _upload(BillingInvoice i) async {
    final r = await c.uploadReceipt(i);
    if (!r.isSuccess) {
      AppFeedback.error(r.error!.message);
    } else if (c.billing.value?.invoices.firstWhereOrNull((x) => x.id == i.id)?.hasPdf ==
        true) {
      AppFeedback.success(tr.blReceiptUploaded);
    }
  }

  Future<void> _remove(BillingInvoice i) async {
    final ok = await showConfirmDialog(
      title: tr.blRemoveReceipt,
      message: i.pdfName ?? i.reference,
      destructive: true,
    );
    if (!ok) return;
    final r = await c.removeReceipt(i);
    r.isSuccess
        ? AppFeedback.success(tr.blReceiptRemoved)
        : AppFeedback.error(r.error!.message);
  }

  Future<void> _download(BillingInvoice i) async {
    final r = await c.saveReceipt(i);
    r.isSuccess
        ? AppFeedback.success(tr.ivFileSaved(r.value ?? ''))
        : AppFeedback.error(r.error!.message);
  }

  @override
  Widget build(BuildContext context) {
    final invoices = billing.invoices;
    return SectionCard(
      title: tr.blInvoices,
      icon: HugeIcons.strokeRoundedInvoice03,
      child: invoices.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(tr.blNoInvoices),
            )
          : Column(
              children: [
                for (final i in invoices)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Obx(() {
                      final busy = c.busyIds.contains(i.id);
                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: CellText(
                              i.reference,
                              bold: true,
                              secondary: invoiceTypeLabel(i.type),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: CellText(
                              _money(i.amountDzd),
                              secondary: i.isPaid
                                  ? '${tr.blColPaid} ${Formatters.date(i.paidAt)}'
                                  : '${tr.blColIssued} ${Formatters.date(i.issuedAt)}',
                            ),
                          ),
                          StatusBadge(
                            label: i.isPaid
                                ? tr.blInvoicePaid
                                : tr.blInvoicePending,
                            color: i.isPaid
                                ? context.crm.success
                                : context.crm.warning,
                          ),
                          const SizedBox(width: 8),
                          if (!i.isPaid)
                            TextButton(
                              onPressed: busy ? null : () => _markPaid(i),
                              child: Text(tr.blMarkPaid),
                            ),
                          if (i.hasPdf)
                            IconButton(
                              tooltip: tr.blViewReceipt,
                              icon: const HugeIcon(icon: HugeIcons.strokeRoundedDownload04, size: 20),
                              onPressed: busy ? null : () => _download(i),
                            ),
                          IconButton(
                            tooltip: i.hasPdf
                                ? tr.blReplaceReceipt
                                : tr.blUploadReceipt,
                            icon: const HugeIcon(icon: HugeIcons.strokeRoundedFileUpload, size: 20),
                            onPressed: busy ? null : () => _upload(i),
                          ),
                          if (i.hasPdf)
                            IconButton(
                              tooltip: tr.blRemoveReceipt,
                              icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, size: 20),
                              onPressed: busy ? null : () => _remove(i),
                            ),
                        ],
                      );
                    }),
                  ),
              ],
            ),
    );
  }
}
