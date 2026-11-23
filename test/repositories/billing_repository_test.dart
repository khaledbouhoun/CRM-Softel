import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/features/billing/data/models/billing_models.dart';

import '../helpers/billing_fixtures.dart';
import '../helpers/fixtures.dart';

void main() {
  late BillingTestEnv env;

  setUp(() => env = BillingTestEnv());

  group('getSubscriptions', () {
    test('sends filters, sort and paging and parses rows', () async {
      env.adapter.reply(
        'GET',
        '/billing/subscriptions',
        paginated([billingRowJson(pending: 1)], total: 1),
      );
      final page = await env.repository.getSubscriptions(
        status: MaintenanceStatus.expired,
        search: ' exemple ',
        sort: BillingSort.expiresAt,
        descending: true,
        pendingRenewalOnly: true,
      );
      expect(page.items.single.pendingRenewalsCount, 1);
      final q = env.adapter.lastTo('GET', '/billing/subscriptions').query;
      expect(q['status'], 'expired');
      expect(q['search'], 'exemple');
      expect(q['sort'], 'expires_at');
      expect(q['direction'], 'desc');
      expect(q['has_pending_renewal'], '1');
    });

    test('omits empty filters', () async {
      env.adapter.reply('GET', '/billing/subscriptions', paginated([]));
      await env.repository.getSubscriptions(search: '  ');
      final q = env.adapter.lastTo('GET', '/billing/subscriptions').query;
      expect(q.containsKey('status'), isFalse);
      expect(q.containsKey('search'), isFalse);
      expect(q.containsKey('has_pending_renewal'), isFalse);
      expect(q['direction'], 'asc');
    });
  });

  test('getCustomerBilling parses the detail', () async {
    env.adapter.reply('GET', '/billing/customers/7', wrap(customerBillingJson()));
    final b = await env.repository.getCustomerBilling(7);
    expect(b.customerName, 'SARL Exemple');
    expect(b.invoices, hasLength(1));
  });

  test('setMaintenance sends API dates', () async {
    env.adapter.reply(
      'PUT',
      '/billing/customers/7/maintenance',
      wrap(customerBillingJson()),
    );
    await env.repository.setMaintenance(
      7,
      startsAt: DateTime(2026, 11, 1),
      expiresAt: DateTime(2027, 11, 1),
    );
    final body = env.adapter.lastTo('PUT', '/billing/customers/7/maintenance').json;
    expect(body['starts_at'], '2026-11-01');
    expect(body['expires_at'], '2027-11-01');
  });

  test('markRenewalPaid posts the payment date and returns the refreshed billing',
      () async {
    env.adapter.reply(
      'POST',
      '/billing/renewal-requests/3/mark-paid',
      wrap(customerBillingJson(renewals: [renewalJson(status: 'paid_cash')])),
    );
    final b = await env.repository.markRenewalPaid(3, paidAt: DateTime(2026, 11, 12));
    expect(
      env.adapter.lastTo('POST', '/billing/renewal-requests/3/mark-paid').json['paid_at'],
      '2026-11-12',
    );
    expect(b.pendingRenewals, isEmpty);
  });

  test('quoteRenewal posts the amount and returns the refreshed billing', () async {
    env.adapter.reply(
      'POST',
      '/billing/renewal-requests/3/quote',
      wrap(customerBillingJson(renewals: [renewalJson(status: 'quoted')])),
    );
    final b = await env.repository.quoteRenewal(3, 72000);
    expect(
      env.adapter.lastTo('POST', '/billing/renewal-requests/3/quote').json['amount_dzd'],
      72000,
    );
    expect(b.renewalRequests.single.isQuoted, isTrue);
  });

  test('markInvoicePaid returns the paid invoice', () async {
    env.adapter.reply(
      'POST',
      '/billing/invoices/11/mark-paid',
      wrap(invoiceJson(status: 'paid_cash')),
    );
    final i = await env.repository.markInvoicePaid(11, paidAt: DateTime(2026, 11, 12));
    expect(i.isPaid, isTrue);
  });

  test('createInvoice sends type, amount and paid status', () async {
    env.adapter.reply(
      'POST',
      '/billing/customers/7/invoices',
      wrap(invoiceJson(status: 'paid_cash', type: 'license')),
      status: 201,
    );
    final i = await env.repository.createInvoice(
      7,
      type: InvoiceType.license,
      amountDzd: 150000,
      paid: true,
      paidAt: DateTime(2026, 11, 12),
    );
    final body = env.adapter.lastTo('POST', '/billing/customers/7/invoices').json;
    expect(body['type'], 'license');
    expect(body['amount_dzd'], 150000);
    expect(body['status'], 'paid_cash');
    expect(body['paid_at'], '2026-11-12');
    expect(i.type, InvoiceType.license);
  });

  test('removeReceipt returns the invoice without a receipt', () async {
    env.adapter.reply('DELETE', '/billing/invoices/11/receipt', wrap(invoiceJson()));
    final i = await env.repository.removeReceipt(11);
    expect(i.hasPdf, isFalse);
  });
}
