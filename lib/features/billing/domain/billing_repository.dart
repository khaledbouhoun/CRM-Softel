import '../../../core/network/api_response.dart';
import '../../../core/utils/file_access.dart';
import '../data/models/billing_models.dart';

/// Staff side of the cash-only billing module: who is covered by maintenance,
/// pending renewal requests, invoices and scanned receipts.
abstract interface class BillingRepository {
  Future<Paginated<BillingCustomerRow>> getSubscriptions({
    String? status,
    String? search,
    String sort = BillingSort.name,
    bool descending = false,
    bool pendingRenewalOnly = false,
    int page = 1,
    int perPage = 25,
  });

  Future<CustomerBilling> getCustomerBilling(int prospectId);

  /// Sets the maintenance period directly (first setup / corrections).
  Future<CustomerBilling> setMaintenance(
    int prospectId, {
    required DateTime startsAt,
    required DateTime expiresAt,
  });

  /// Staff price a renewal request ("Issue Proforma"): status becomes `quoted`.
  Future<CustomerBilling> quoteRenewal(int renewalRequestId, int amountDzd);

  /// Confirms the cash of a quoted renewal request; the backend extends the period.
  Future<CustomerBilling> markRenewalPaid(
    int renewalRequestId, {
    DateTime? paidAt,
  });

  Future<BillingInvoice> markInvoicePaid(int invoiceId, {DateTime? paidAt});

  Future<BillingInvoice> createInvoice(
    int prospectId, {
    required String type,
    required int amountDzd,
    bool paid = false,
    DateTime? paidAt,
  });

  Future<BillingInvoice> uploadReceipt(int invoiceId, PickedFile file);

  Future<BillingInvoice> removeReceipt(int invoiceId);

  Future<void> downloadReceipt(int invoiceId, String savePath);
}
