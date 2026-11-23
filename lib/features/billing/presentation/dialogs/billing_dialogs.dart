import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../data/models/billing_models.dart';
import '../controllers/billing_controllers.dart';

String invoiceTypeLabel(String type) => type == InvoiceType.maintenanceRenewal
    ? tr.blInvoiceTypeRenewal
    : tr.blInvoiceTypeLicense;

/// Date-only picker field (no time of day).
class BillingDateField extends StatelessWidget {
  const BillingDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.lastDate,
    this.enabled = true,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? errorText;
  final DateTime? lastDate;
  final bool enabled;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: !enabled
        ? null
        : () async {
            final now = DateTime.now();
            final initial = value ?? now;
            final last = lastDate ?? DateTime(now.year + 20);
            final picked = await showDatePicker(
              context: context,
              initialDate: initial.isAfter(last) ? last : initial,
              firstDate: DateTime(2000),
              lastDate: last,
            );
            if (picked != null) onChanged(picked);
          },
    child: InputDecorator(
      isEmpty: value == null,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        enabled: enabled,
        prefixIcon: const Icon(Icons.event, size: 20),
      ),
      child: Text(value == null ? '' : Formatters.date(value)),
    ),
  );
}

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// Staff price a renewal request. True when saved.
Future<bool> showQuoteDialog({
  required BillingDetailController detail,
  required RenewalRequest renewal,
}) async =>
    (await showControllerDialog<QuoteController, bool>(
      controller: QuoteController(detail: detail, renewal: renewal),
      builder: (c) => _QuoteDialog(c: c),
    )) ??
    false;

class _QuoteDialog extends StatelessWidget {
  const _QuoteDialog({required this.c});

  final QuoteController c;

  @override
  Widget build(BuildContext context) {
    final r = c.renewal;
    return Obx(
      () => FormDialog(
        title: tr.blQuoteTitle,
        icon: Icons.request_quote_outlined,
        width: 480,
        submitLabel: tr.blQuoteIssue,
        busy: c.isSubmitting.value,
        errorMessage: c.errorMessage.value,
        onCancel: () => Get.back(result: false),
        onSubmit: () async {
          if (await c.submit()) Get.back(result: true);
        },
        child: Form(
          key: c.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(tr.blQuoteHint),
              const SizedBox(height: 12),
              Text(
                '${r.years} ${tr.blRenewalYears} · ${r.workstationsCount} ${tr.blWorkstations} · ${r.dossiersCount} ${tr.blDossiers}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if ((r.notes ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${tr.blNotesLabel}: ${r.notes}'),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: c.amount,
                enabled: !c.isSubmitting.value,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: tr.blQuoteAmount),
                validator: c.validateAmount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirms the cash of a renewal request or invoice. True when saved.
Future<bool> showMarkPaidDialog({
  required BillingDetailController detail,
  RenewalRequest? renewal,
  BillingInvoice? invoice,
}) async =>
    (await showControllerDialog<MarkPaidController, bool>(
      controller: MarkPaidController(
        detail: detail,
        renewal: renewal,
        invoice: invoice,
      ),
      builder: (c) => _MarkPaidDialog(c: c),
    )) ??
    false;

class _MarkPaidDialog extends StatelessWidget {
  const _MarkPaidDialog({required this.c});

  final MarkPaidController c;

  @override
  Widget build(BuildContext context) {
    final reference = c.renewal?.reference ?? c.invoice?.reference ?? '';
    final amount = c.renewal?.amountDzd ?? c.invoice?.amountDzd ?? 0;
    return Obx(
      () => FormDialog(
        title: tr.blMarkPaidTitle,
        icon: Icons.payments_outlined,
        width: 480,
        submitLabel: tr.blMarkPaid,
        busy: c.isSubmitting.value,
        errorMessage: c.errorMessage.value,
        onCancel: () => Get.back(result: false),
        onSubmit: () async {
          if (await c.submit()) Get.back(result: true);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tr.blMarkPaidHint),
            const SizedBox(height: 12),
            Text(
              '$reference · ${Formatters.number(amount)} ${tr.blCurrency}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            BillingDateField(
              label: tr.blPaidAt,
              value: c.paidAt.value,
              lastDate: _today(),
              enabled: !c.isSubmitting.value,
              onChanged: (v) => c.paidAt.value = v,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sets / corrects the maintenance period. True when saved.
Future<bool> showMaintenanceDialog({
  required int prospectId,
  required MaintenanceInfo current,
}) async =>
    (await showControllerDialog<MaintenanceFormController, bool>(
      controller: MaintenanceFormController(
        prospectId: prospectId,
        repository: Get.find(),
        current: current.hasPlan ? current : null,
      ),
      builder: (c) => _MaintenanceDialog(c: c),
    )) ??
    false;

class _MaintenanceDialog extends StatelessWidget {
  const _MaintenanceDialog({required this.c});

  final MaintenanceFormController c;

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: tr.blSetMaintenanceTitle,
      icon: Icons.verified_outlined,
      width: 480,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      submitEnabled: c.periodError == null,
      onCancel: () => Get.back(result: false),
      onSubmit: () async {
        if (await c.submit() != null) Get.back(result: true);
      },
      child: FormRow(
        children: [
          BillingDateField(
            label: tr.blMaintenanceStarts,
            value: c.startsAt.value,
            enabled: !c.isSubmitting.value,
            onChanged: (v) => c.startsAt.value = v,
          ),
          BillingDateField(
            label: tr.blMaintenanceExpires,
            value: c.expiresAt.value,
            errorText: c.periodError,
            enabled: !c.isSubmitting.value,
            onChanged: (v) => c.expiresAt.value = v,
          ),
        ],
      ),
    ),
  );
}

/// Records an invoice by hand. True when saved.
Future<bool> showInvoiceFormDialog({required int prospectId}) async =>
    (await showControllerDialog<InvoiceFormController, bool>(
      controller: InvoiceFormController(
        prospectId: prospectId,
        repository: Get.find(),
      ),
      builder: (c) => _InvoiceDialog(c: c),
    )) ??
    false;

class _InvoiceDialog extends StatelessWidget {
  const _InvoiceDialog({required this.c});

  final InvoiceFormController c;

  @override
  Widget build(BuildContext context) => Obx(
    () => FormDialog(
      title: tr.blNewInvoice,
      icon: Icons.receipt_long_outlined,
      width: 480,
      busy: c.isSubmitting.value,
      errorMessage: c.errorMessage.value,
      onCancel: () => Get.back(result: false),
      onSubmit: () async {
        if (await c.submit() != null) Get.back(result: true);
      },
      child: Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: c.type.value,
              isExpanded: true,
              decoration: InputDecoration(labelText: tr.blInvoiceType),
              items: [
                for (final t in InvoiceType.values)
                  DropdownMenuItem(value: t, child: Text(invoiceTypeLabel(t))),
              ],
              onChanged: c.isSubmitting.value
                  ? null
                  : (v) => c.type.value = v ?? c.type.value,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: c.amount,
              enabled: !c.isSubmitting.value,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: tr.blInvoiceAmount),
              validator: c.validateAmount,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: c.alreadyPaid.value,
              title: Text(tr.blInvoiceAlreadyPaid),
              onChanged: c.isSubmitting.value
                  ? null
                  : (v) => c.alreadyPaid.value = v ?? false,
            ),
            if (c.alreadyPaid.value)
              BillingDateField(
                label: tr.blPaidAt,
                value: c.paidAt.value,
                lastDate: _today(),
                enabled: !c.isSubmitting.value,
                onChanged: (v) => c.paidAt.value = v,
              ),
          ],
        ),
      ),
    ),
  );
}
