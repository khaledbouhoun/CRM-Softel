import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/file_access.dart';
import '../../data/models/billing_models.dart';
import '../../domain/billing_repository.dart';

/// Subscriptions overview: every customer with its maintenance status,
/// filterable by status, searchable and sortable.
class BillingListController extends GetxController {
  BillingListController({required BillingRepository repository})
    : _repository = repository;

  final BillingRepository _repository;

  final page = Rx<Paginated<BillingCustomerRow>>(const Paginated.empty());
  final state = LoadState();

  /// One of [MaintenanceStatus.values]; null = all.
  final status = RxnString();
  final search = ''.obs;
  final sort = BillingSort.name.obs;
  final descending = false.obs;
  final pendingOnly = false.obs;
  int _pageNumber = 1;

  List<BillingCustomerRow> get rows => page.value.items;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    page.value = await _repository.getSubscriptions(
      status: status.value,
      search: search.value,
      sort: sort.value,
      descending: descending.value,
      pendingRenewalOnly: pendingOnly.value,
      page: _pageNumber,
    );
  });

  Future<void> _reset() {
    _pageNumber = 1;
    return load();
  }

  Future<void> setStatus(String? value) {
    status.value = value;
    return _reset();
  }

  Future<void> setSearch(String value) {
    search.value = value;
    return _reset();
  }

  Future<void> setSort(String value) {
    sort.value = value;
    return _reset();
  }

  Future<void> toggleDirection() {
    descending.value = !descending.value;
    return _reset();
  }

  Future<void> setPendingOnly(bool value) {
    pendingOnly.value = value;
    return _reset();
  }

  Future<void> goToPage(int value) {
    _pageNumber = value;
    return load();
  }
}

/// Billing of one customer: license, maintenance, renewals and invoices.
class BillingDetailController extends GetxController {
  BillingDetailController({
    required this.prospectId,
    required BillingRepository repository,
  }) : _repository = repository;

  final int prospectId;
  final BillingRepository _repository;

  final billing = Rxn<CustomerBilling>();
  final state = LoadState();
  final busyIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    billing.value = await _repository.getCustomerBilling(prospectId);
  });

  Future<ActionResult<void>> _mutate(
    int? id,
    Future<void> Function() task,
  ) async {
    if (id != null) busyIds.add(id);
    try {
      final result = await ActionResult.guard<void>(task);
      if (result.isSuccess) {
        try {
          billing.value = await _repository.getCustomerBilling(prospectId);
        } catch (_) {
          // The action succeeded; a stale view is refreshed on next load.
        }
      }
      return result;
    } finally {
      if (id != null) busyIds.remove(id);
    }
  }

  Future<ActionResult<void>> quoteRenewal(
    RenewalRequest request,
    int amountDzd,
  ) => _mutate(
    request.id,
    () => _repository.quoteRenewal(request.id, amountDzd),
  );

  Future<ActionResult<void>> markRenewalPaid(
    RenewalRequest request,
    DateTime paidAt,
  ) => _mutate(
    request.invoiceId ?? request.id,
    () => _repository.markRenewalPaid(request.id, paidAt: paidAt),
  );

  Future<ActionResult<void>> markInvoicePaid(
    BillingInvoice invoice,
    DateTime paidAt,
  ) => _mutate(
    invoice.id,
    () => _repository.markInvoicePaid(invoice.id, paidAt: paidAt),
  );

  Future<ActionResult<void>> uploadReceipt(BillingInvoice invoice) async {
    final files = await FileAccess.pick(
      extensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      multiple: false,
    );
    if (files.isEmpty) return const ActionResult.success();
    return _mutate(
      invoice.id,
      () => _repository.uploadReceipt(invoice.id, files.first),
    );
  }

  Future<ActionResult<void>> removeReceipt(BillingInvoice invoice) =>
      _mutate(invoice.id, () => _repository.removeReceipt(invoice.id));

  Future<ActionResult<String>> saveReceipt(BillingInvoice invoice) =>
      ActionResult.guard(() async {
        final name = invoice.pdfName ?? '${invoice.reference}.pdf';
        final path = FileAccess.freePath(FileAccess.downloadsDirectory(), name);
        await _repository.downloadReceipt(invoice.id, path);
        return path;
      });
}

/// "Quote price" dialog: staff enter the amount; the backend issues the
/// proforma reference and invoice.
class QuoteController extends GetxController {
  QuoteController({required BillingDetailController detail, required this.renewal})
    : _detail = detail;

  final BillingDetailController _detail;
  final RenewalRequest renewal;

  final formKey = GlobalKey<FormState>();
  final amount = TextEditingController();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  String? validateAmount(String? value) {
    final n = int.tryParse((value ?? '').trim());
    return (n == null || n <= 0) ? tr.blAmountInvalid : null;
  }

  Future<bool> submit() async {
    if (isSubmitting.value) return false;
    if (!(formKey.currentState?.validate() ?? false)) return false;
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final result = await _detail.quoteRenewal(
        renewal,
        int.parse(amount.text.trim()),
      );
      if (!result.isSuccess) errorMessage.value = result.error!.message;
      return result.isSuccess;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    amount.dispose();
    super.onClose();
  }
}

/// "Mark as paid" dialog: confirms the cash and picks the payment date.
/// For a renewal request the backend extends the maintenance period.
class MarkPaidController extends GetxController {
  MarkPaidController({
    required BillingDetailController detail,
    this.renewal,
    this.invoice,
    DateTime Function()? clock,
  }) : assert(
         (renewal == null) != (invoice == null),
         'exactly one of renewal / invoice',
       ),
       _detail = detail {
    final now = (clock ?? DateTime.now)();
    paidAt.value = DateTime(now.year, now.month, now.day);
  }

  final BillingDetailController _detail;
  final RenewalRequest? renewal;
  final BillingInvoice? invoice;

  final paidAt = Rxn<DateTime>();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  Future<bool> submit() async {
    final date = paidAt.value;
    if (date == null || isSubmitting.value) return false;
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final result = renewal != null
          ? await _detail.markRenewalPaid(renewal!, date)
          : await _detail.markInvoicePaid(invoice!, date);
      if (!result.isSuccess) errorMessage.value = result.error!.message;
      return result.isSuccess;
    } finally {
      isSubmitting.value = false;
    }
  }
}

/// Sets / corrects the maintenance period of a customer.
class MaintenanceFormController extends GetxController {
  MaintenanceFormController({
    required this.prospectId,
    required BillingRepository repository,
    MaintenanceInfo? current,
    DateTime Function()? clock,
  }) : _repository = repository {
    final now = (clock ?? DateTime.now)();
    final today = DateTime(now.year, now.month, now.day);
    startsAt.value = current?.startsAt ?? today;
    // Maintenance is co-termed: it always ends on 31 December.
    expiresAt.value = current?.expiresAt ?? DateTime(today.year, 12, 31);
  }

  final int prospectId;
  final BillingRepository _repository;

  final startsAt = Rxn<DateTime>();
  final expiresAt = Rxn<DateTime>();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  /// Null when valid.
  String? get periodError {
    final s = startsAt.value;
    final e = expiresAt.value;
    if (s == null || e == null || !e.isAfter(s)) return tr.blPeriodInvalid;
    return null;
  }

  Future<CustomerBilling?> submit() async {
    if (periodError != null || isSubmitting.value) return null;
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final result = await ActionResult.guard(
        () => _repository.setMaintenance(
          prospectId,
          startsAt: startsAt.value!,
          expiresAt: expiresAt.value!,
        ),
      );
      if (!result.isSuccess) {
        errorMessage.value = result.error!.message;
        return null;
      }
      return result.value;
    } finally {
      isSubmitting.value = false;
    }
  }
}

/// Manually records an invoice (license or maintenance renewal).
class InvoiceFormController extends GetxController {
  InvoiceFormController({
    required this.prospectId,
    required BillingRepository repository,
    DateTime Function()? clock,
  }) : _repository = repository {
    final now = (clock ?? DateTime.now)();
    paidAt.value = DateTime(now.year, now.month, now.day);
  }

  final int prospectId;
  final BillingRepository _repository;

  final formKey = GlobalKey<FormState>();
  final amount = TextEditingController();
  final type = InvoiceType.maintenanceRenewal.obs;
  final alreadyPaid = false.obs;
  final paidAt = Rxn<DateTime>();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  String? validateAmount(String? value) {
    final n = int.tryParse((value ?? '').trim());
    return (n == null || n < 0) ? tr.blAmountInvalid : null;
  }

  Future<BillingInvoice?> submit() async {
    if (isSubmitting.value) return null;
    if (!(formKey.currentState?.validate() ?? false)) return null;
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final result = await ActionResult.guard(
        () => _repository.createInvoice(
          prospectId,
          type: type.value,
          amountDzd: int.parse(amount.text.trim()),
          paid: alreadyPaid.value,
          paidAt: paidAt.value,
        ),
      );
      if (!result.isSuccess) {
        errorMessage.value = result.error!.message;
        return null;
      }
      return result.value;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    amount.dispose();
    super.onClose();
  }
}
