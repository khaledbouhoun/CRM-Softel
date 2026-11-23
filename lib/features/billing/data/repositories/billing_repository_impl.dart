import '../../../../core/network/api_response.dart';
import '../../../../core/utils/file_access.dart';
import '../../domain/billing_repository.dart';
import '../datasources/billing_remote_data_source.dart';
import '../models/billing_models.dart';

class BillingRepositoryImpl implements BillingRepository {
  const BillingRepositoryImpl(this._remote);

  final BillingRemoteDataSource _remote;

  @override
  Future<Paginated<BillingCustomerRow>> getSubscriptions({
    String? status,
    String? search,
    String sort = BillingSort.name,
    bool descending = false,
    bool pendingRenewalOnly = false,
    int page = 1,
    int perPage = 25,
  }) => _remote.fetchSubscriptions(
    status: status,
    search: search,
    sort: sort,
    descending: descending,
    pendingRenewalOnly: pendingRenewalOnly,
    page: page,
    perPage: perPage,
  );

  @override
  Future<CustomerBilling> getCustomerBilling(int prospectId) =>
      _remote.fetchCustomer(prospectId);

  @override
  Future<CustomerBilling> setMaintenance(
    int prospectId, {
    required DateTime startsAt,
    required DateTime expiresAt,
  }) => _remote.setMaintenance(
    prospectId,
    startsAt: startsAt,
    expiresAt: expiresAt,
  );

  @override
  Future<CustomerBilling> quoteRenewal(int renewalRequestId, int amountDzd) =>
      _remote.quoteRenewal(renewalRequestId, amountDzd);

  @override
  Future<CustomerBilling> markRenewalPaid(
    int renewalRequestId, {
    DateTime? paidAt,
  }) => _remote.markRenewalPaid(renewalRequestId, paidAt);

  @override
  Future<BillingInvoice> markInvoicePaid(int invoiceId, {DateTime? paidAt}) =>
      _remote.markInvoicePaid(invoiceId, paidAt);

  @override
  Future<BillingInvoice> createInvoice(
    int prospectId, {
    required String type,
    required int amountDzd,
    bool paid = false,
    DateTime? paidAt,
  }) => _remote.createInvoice(
    prospectId,
    type: type,
    amountDzd: amountDzd,
    paid: paid,
    paidAt: paidAt,
  );

  @override
  Future<BillingInvoice> uploadReceipt(int invoiceId, PickedFile file) =>
      _remote.uploadReceipt(invoiceId, file);

  @override
  Future<BillingInvoice> removeReceipt(int invoiceId) =>
      _remote.removeReceipt(invoiceId);

  @override
  Future<void> downloadReceipt(int invoiceId, String savePath) =>
      _remote.downloadReceipt(invoiceId, savePath);
}
