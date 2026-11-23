import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/file_access.dart';
import '../../../../core/utils/json_utils.dart';
import '../models/billing_models.dart';

class BillingRemoteDataSource {
  const BillingRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<BillingCustomerRow>> fetchSubscriptions({
    String? status,
    String? search,
    required String sort,
    required bool descending,
    required bool pendingRenewalOnly,
    required int page,
    required int perPage,
  }) async => ApiResponse.paginated(
    await _api.get(
      ApiEndpoints.billingSubscriptions,
      query: {
        'status': status,
        'search': (search == null || search.trim().isEmpty)
            ? null
            : search.trim(),
        'sort': sort,
        'direction': descending ? 'desc' : 'asc',
        'has_pending_renewal': pendingRenewalOnly ? 1 : null,
        'page': page,
        'per_page': perPage,
      },
    ),
    BillingCustomerRow.fromJson,
  );

  Future<CustomerBilling> fetchCustomer(int prospectId) async =>
      CustomerBilling.fromJson(
        ApiResponse.object(
          await _api.get(ApiEndpoints.billingCustomer(prospectId)),
        ),
      );

  Future<CustomerBilling> setMaintenance(
    int prospectId, {
    required DateTime startsAt,
    required DateTime expiresAt,
  }) async => CustomerBilling.fromJson(
    ApiResponse.object(
      await _api.put(
        ApiEndpoints.billingMaintenance(prospectId),
        data: {
          'starts_at': toApiDate(startsAt),
          'expires_at': toApiDate(expiresAt),
        },
      ),
    ),
  );

  Future<CustomerBilling> quoteRenewal(int id, int amountDzd) async =>
      CustomerBilling.fromJson(
        ApiResponse.object(
          await _api.post(
            ApiEndpoints.billingRenewalQuote(id),
            data: {'amount_dzd': amountDzd},
          ),
        ),
      );

  Future<CustomerBilling> markRenewalPaid(int id, DateTime? paidAt) async =>
      CustomerBilling.fromJson(
        ApiResponse.object(
          await _api.post(
            ApiEndpoints.billingRenewalMarkPaid(id),
            data: {if (paidAt != null) 'paid_at': toApiDate(paidAt)},
          ),
        ),
      );

  Future<BillingInvoice> markInvoicePaid(int id, DateTime? paidAt) async =>
      BillingInvoice.fromJson(
        ApiResponse.object(
          await _api.post(
            ApiEndpoints.billingInvoiceMarkPaid(id),
            data: {if (paidAt != null) 'paid_at': toApiDate(paidAt)},
          ),
        ),
      );

  Future<BillingInvoice> createInvoice(
    int prospectId, {
    required String type,
    required int amountDzd,
    required bool paid,
    DateTime? paidAt,
  }) async => BillingInvoice.fromJson(
    ApiResponse.object(
      await _api.post(
        ApiEndpoints.billingCustomerInvoices(prospectId),
        data: {
          'type': type,
          'amount_dzd': amountDzd,
          'status': paid ? InvoiceStatus.paidCash : InvoiceStatus.pendingCash,
          if (paid && paidAt != null) 'paid_at': toApiDate(paidAt),
        },
      ),
    ),
  );

  Future<BillingInvoice> uploadReceipt(int id, PickedFile file) async {
    final form = FormData();
    form.files.add(
      MapEntry(
        'receipt',
        await MultipartFile.fromFile(file.path, filename: file.name),
      ),
    );
    return BillingInvoice.fromJson(
      ApiResponse.object(
        await _api.postForm(ApiEndpoints.billingInvoiceReceipt(id), data: form),
      ),
    );
  }

  Future<BillingInvoice> removeReceipt(int id) async => BillingInvoice.fromJson(
    ApiResponse.object(
      await _api.delete(ApiEndpoints.billingInvoiceReceipt(id)),
    ),
  );

  Future<void> downloadReceipt(int id, String savePath) =>
      _api.downloadTo(ApiEndpoints.billingInvoiceReceipt(id), savePath);
}
