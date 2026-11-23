import '../../../../core/utils/json_utils.dart';

/// State of a customer's maintenance & support plan (`maintenance.status`).
abstract final class MaintenanceStatus {
  static const active = 'active';
  static const expiringSoon = 'expiring_soon';
  static const expired = 'expired';

  /// No maintenance plan has been set up for the customer yet.
  static const none = 'none';

  static const values = [active, expiringSoon, expired, none];
}

abstract final class InvoiceType {
  static const license = 'license';
  static const maintenanceRenewal = 'maintenance_renewal';
  static const values = [license, maintenanceRenewal];
}

abstract final class InvoiceStatus {
  static const paidCash = 'paid_cash';
  static const pendingCash = 'pending_cash';
}

abstract final class RenewalStatus {
  /// The customer asked for a renewal; staff have not priced it yet.
  static const pendingQuote = 'pending_quote';

  /// Staff issued a proforma; waiting for the cash payment.
  static const quoted = 'quoted';
  static const paidCash = 'paid_cash';
  static const rejected = 'rejected';
}

/// Fields the subscriptions list can be sorted by (`sort` query parameter).
abstract final class BillingSort {
  static const name = 'name';
  static const expiresAt = 'expires_at';
  static const convertedAt = 'converted_at';
  static const values = [name, expiresAt, convertedAt];
}

/// The maintenance & support plan of one customer.
class MaintenanceInfo {
  const MaintenanceInfo({
    required this.status,
    this.isActive = false,
    this.daysRemaining,
    this.startsAt,
    this.expiresAt,
  });

  final String status;
  final bool isActive;
  final int? daysRemaining;
  final DateTime? startsAt;
  final DateTime? expiresAt;

  bool get hasPlan => status != MaintenanceStatus.none;

  factory MaintenanceInfo.fromJson(JsonMap json) => MaintenanceInfo(
    status: asString(json['status'], fallback: MaintenanceStatus.none),
    isActive: asBool(json['is_active']),
    daysRemaining: asIntOrNull(json['days_remaining']),
    startsAt: asDateTimeOrNull(json['starts_at']),
    expiresAt: asDateTimeOrNull(json['expires_at']),
  );

  static MaintenanceInfo fromJsonOrNone(Object? value) {
    final json = asMapOrNull(value);
    return json == null
        ? const MaintenanceInfo(status: MaintenanceStatus.none)
        : MaintenanceInfo.fromJson(json);
  }
}

/// One row of the subscriptions overview.
class BillingCustomerRow {
  const BillingCustomerRow({
    required this.id,
    required this.name,
    required this.maintenance,
    this.contactPerson,
    this.phone,
    this.pendingRenewalsCount = 0,
  });

  final int id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final MaintenanceInfo maintenance;
  final int pendingRenewalsCount;

  factory BillingCustomerRow.fromJson(JsonMap json) => BillingCustomerRow(
    id: asInt(json['id']),
    name: asString(json['name']),
    contactPerson: asStringOrNull(json['contact_person']),
    phone: asStringOrNull(json['phone']),
    maintenance: MaintenanceInfo.fromJsonOrNone(json['maintenance']),
    pendingRenewalsCount: asInt(json['pending_renewals_count']),
  );
}

/// A customer's request to renew maintenance (proforma slip, paid in cash).
class RenewalRequest {
  const RenewalRequest({
    required this.id,
    required this.years,
    required this.status,
    this.reference,
    this.amountDzd,
    this.workstationsCount = 1,
    this.dossiersCount = 1,
    this.notes,
    this.quotedAt,
    this.quotedBy,
    this.requestedAt,
    this.confirmedAt,
    this.confirmedBy,
    this.invoiceId,
  });

  final int id;
  final int years;
  final String status;

  /// Proforma reference and price: only known once staff quoted the request.
  final String? reference;
  final int? amountDzd;
  final int workstationsCount;
  final int dossiersCount;
  final String? notes;
  final DateTime? quotedAt;
  final String? quotedBy;
  final DateTime? requestedAt;
  final DateTime? confirmedAt;
  final String? confirmedBy;
  final int? invoiceId;

  bool get isPendingQuote => status == RenewalStatus.pendingQuote;
  bool get isQuoted => status == RenewalStatus.quoted;

  /// Still to be handled by staff (priced or paid).
  bool get isOpen => isPendingQuote || isQuoted;

  factory RenewalRequest.fromJson(JsonMap json) => RenewalRequest(
    id: asInt(json['id']),
    reference: asStringOrNull(json['reference']),
    years: asInt(json['years']),
    amountDzd: asIntOrNull(json['amount_dzd']),
    workstationsCount: asInt(json['workstations_count'], fallback: 1),
    dossiersCount: asInt(json['dossiers_count'], fallback: 1),
    notes: asStringOrNull(json['notes']),
    quotedAt: asDateTimeOrNull(json['quoted_at']),
    quotedBy: asStringOrNull(json['quoted_by']),
    status: asString(json['status'], fallback: RenewalStatus.pendingQuote),
    requestedAt: asDateTimeOrNull(json['requested_at']),
    confirmedAt: asDateTimeOrNull(json['confirmed_at']),
    confirmedBy: asStringOrNull(json['confirmed_by']),
    invoiceId: asIntOrNull(json['invoice_id']),
  );
}

class BillingInvoice {
  const BillingInvoice({
    required this.id,
    required this.reference,
    required this.type,
    required this.amountDzd,
    required this.status,
    this.issuedAt,
    this.paidAt,
    this.renewalRequestId,
    this.hasPdf = false,
    this.pdfName,
    this.createdBy,
  });

  final int id;
  final String reference;
  final String type;
  final int amountDzd;
  final String status;
  final DateTime? issuedAt;
  final DateTime? paidAt;
  final int? renewalRequestId;
  final bool hasPdf;
  final String? pdfName;
  final String? createdBy;

  bool get isPaid => status == InvoiceStatus.paidCash;

  factory BillingInvoice.fromJson(JsonMap json) => BillingInvoice(
    id: asInt(json['id']),
    reference: asString(json['reference']),
    type: asString(json['type'], fallback: InvoiceType.license),
    amountDzd: asInt(json['amount_dzd']),
    status: asString(json['status'], fallback: InvoiceStatus.pendingCash),
    issuedAt: asDateTimeOrNull(json['issued_at']),
    paidAt: asDateTimeOrNull(json['paid_at']),
    renewalRequestId: asIntOrNull(json['renewal_request_id']),
    hasPdf: asBool(json['has_pdf']),
    pdfName: asStringOrNull(json['pdf_name']),
    createdBy: asStringOrNull(json['created_by']),
  );
}

/// Everything about one customer's billing (staff view).
class CustomerBilling {
  const CustomerBilling({
    required this.customerId,
    required this.customerName,
    required this.maintenance,
    required this.renewalRequests,
    required this.invoices,
    this.licenseSince,
    this.contactPerson,
    this.phone,
    this.email,
  });

  final int customerId;
  final String customerName;
  final String? contactPerson;
  final String? phone;
  final String? email;

  /// The lifetime license never expires; this is only when it started.
  final DateTime? licenseSince;
  final MaintenanceInfo maintenance;
  final List<RenewalRequest> renewalRequests;
  final List<BillingInvoice> invoices;

  List<RenewalRequest> get pendingRenewals =>
      renewalRequests.where((r) => r.isOpen).toList();

  factory CustomerBilling.fromJson(JsonMap json) {
    final customer = asMapOrNull(json['customer']) ?? const <String, dynamic>{};
    final license = asMapOrNull(json['license']) ?? const <String, dynamic>{};
    return CustomerBilling(
      customerId: asInt(customer['id']),
      customerName: asString(customer['name']),
      contactPerson: asStringOrNull(customer['contact_person']),
      phone: asStringOrNull(customer['phone']),
      email: asStringOrNull(customer['email']),
      licenseSince: asDateTimeOrNull(license['since']),
      maintenance: MaintenanceInfo.fromJsonOrNone(json['maintenance']),
      renewalRequests: asList(
        json['renewal_requests'],
        RenewalRequest.fromJson,
      ),
      invoices: asList(json['invoices'], BillingInvoice.fromJson),
    );
  }
}
