import 'package:softel_crm/core/network/api_client.dart';
import 'package:softel_crm/features/billing/data/datasources/billing_remote_data_source.dart';
import 'package:softel_crm/features/billing/data/repositories/billing_repository_impl.dart';
import 'package:softel_crm/features/billing/domain/billing_repository.dart';

import 'fixtures.dart';
import 'mock_http_adapter.dart';

Map<String, dynamic> maintenanceJson({
  String status = 'active',
  int? days = 200,
  String? expires = '2027-06-04T00:00:00+01:00',
}) => {
  'status': status,
  'is_active': status == 'active' || status == 'expiring_soon',
  'days_remaining': days,
  'starts_at': '2026-06-04T00:00:00+01:00',
  'expires_at': expires,
};

Map<String, dynamic> billingRowJson({
  int id = 7,
  String name = 'SARL Exemple',
  Map<String, dynamic>? maintenance,
  int pending = 0,
}) => {
  'id': id,
  'name': name,
  'contact_person': 'Karim',
  'phone': '0550000000',
  'email': null,
  'city': 'Alger',
  'converted_at': '2026-05-01T09:00:00+01:00',
  'maintenance': maintenance ?? maintenanceJson(),
  'pending_renewals_count': pending,
};

Map<String, dynamic> renewalJson({
  int id = 3,
  String status = 'quoted',
  int? invoiceId = 11,
}) => {
  'id': id,
  'reference': status == 'pending_quote' ? null : 'PF-2026-0003',
  'years': 2,
  'workstations_count': 4,
  'dossiers_count': 2,
  'notes': 'Two sites',
  'amount_dzd': status == 'pending_quote' ? null : 72000,
  'status': status,
  'requested_at': '2026-11-10T10:00:00+01:00',
  'confirmed_at': status == 'paid_cash' ? '2026-11-12T10:00:00+01:00' : null,
  'confirmed_by': status == 'paid_cash' ? 'salim' : null,
  'invoice_id': invoiceId,
};

Map<String, dynamic> invoiceJson({
  int id = 11,
  String status = 'pending_cash',
  bool hasPdf = false,
  String type = 'maintenance_renewal',
}) => {
  'id': id,
  'prospect_id': 7,
  'reference': 'SOF-2026-0011',
  'type': type,
  'amount_dzd': 72000,
  'status': status,
  'issued_at': '2026-11-10T10:00:00+01:00',
  'paid_at': status == 'paid_cash' ? '2026-11-12T00:00:00+01:00' : null,
  'renewal_request_id': 3,
  'has_pdf': hasPdf,
  'pdf_name': hasPdf ? 'recu.pdf' : null,
  'receipt_url': hasPdf ? '/billing/invoices/$id/receipt' : null,
  'created_by': 'salim',
};

Map<String, dynamic> customerBillingJson({
  Map<String, dynamic>? maintenance,
  List<Map<String, dynamic>>? renewals,
  List<Map<String, dynamic>>? invoices,
}) => {
  'customer': {
    'id': 7,
    'name': 'SARL Exemple',
    'contact_person': 'Karim',
    'phone': '0550000000',
    'email': 'k@exemple.dz',
    'city': 'Alger',
    'converted_at': '2026-05-01T09:00:00+01:00',
  },
  'license': {'lifetime': true, 'since': '2026-05-01T09:00:00+01:00'},
  'maintenance': maintenance ?? maintenanceJson(),
  'renewal_requests': renewals ?? [renewalJson()],
  'invoices': invoices ?? [invoiceJson()],
};

/// Real billing repository wired to a mock HTTP adapter.
class BillingTestEnv {
  BillingTestEnv() {
    api = buildTestClient(adapter);
    repository = BillingRepositoryImpl(BillingRemoteDataSource(api));
  }

  final adapter = MockHttpAdapter();
  late final ApiClient api;
  late final BillingRepository repository;

  Object envelope(Object data) => wrap(data);
}
