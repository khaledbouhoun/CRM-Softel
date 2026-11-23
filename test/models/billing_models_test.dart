import 'package:flutter_test/flutter_test.dart';
import 'package:softel_crm/features/billing/data/models/billing_models.dart';

import '../helpers/billing_fixtures.dart';

void main() {
  group('MaintenanceInfo', () {
    test('parses an active plan', () {
      final m = MaintenanceInfo.fromJson(maintenanceJson());
      expect(m.status, MaintenanceStatus.active);
      expect(m.isActive, isTrue);
      expect(m.daysRemaining, 200);
      expect(m.expiresAt, isNotNull);
      expect(m.hasPlan, isTrue);
    });

    test('a missing plan is "none"', () {
      final m = MaintenanceInfo.fromJsonOrNone(null);
      expect(m.status, MaintenanceStatus.none);
      expect(m.hasPlan, isFalse);
      expect(m.isActive, isFalse);
    });
  });

  test('BillingCustomerRow keeps maintenance and pending count', () {
    final row = BillingCustomerRow.fromJson(
      billingRowJson(
        maintenance: maintenanceJson(status: 'expired', days: null),
        pending: 2,
      ),
    );
    expect(row.name, 'SARL Exemple');
    expect(row.maintenance.status, MaintenanceStatus.expired);
    expect(row.pendingRenewalsCount, 2);
  });

  group('CustomerBilling', () {
    test('parses license, renewals and invoices', () {
      final b = CustomerBilling.fromJson(
        customerBillingJson(
          renewals: [renewalJson(), renewalJson(id: 4, status: 'paid_cash'), renewalJson(id: 5, status: 'pending_quote')],
          invoices: [invoiceJson(hasPdf: true, status: 'paid_cash')],
        ),
      );
      expect(b.customerId, 7);
      expect(b.licenseSince, isNotNull);
      expect(b.pendingRenewals.map((r) => r.id), [3, 5]);
      final quoted = b.renewalRequests.first;
      expect(quoted.isQuoted, isTrue);
      expect(quoted.workstationsCount, 4);
      expect(quoted.dossiersCount, 2);
      expect(quoted.notes, 'Two sites');
      expect(quoted.amountDzd, 72000);
      final waiting = b.renewalRequests.last;
      expect(waiting.isPendingQuote, isTrue);
      expect(waiting.amountDzd, isNull);
      expect(waiting.reference, isNull);
      final invoice = b.invoices.single;
      expect(invoice.isPaid, isTrue);
      expect(invoice.hasPdf, isTrue);
      expect(invoice.pdfName, 'recu.pdf');
    });

    test('tolerates a payload without optional sections', () {
      final b = CustomerBilling.fromJson({
        'customer': {'id': 1, 'name': 'X'},
      });
      expect(b.maintenance.status, MaintenanceStatus.none);
      expect(b.renewalRequests, isEmpty);
      expect(b.invoices, isEmpty);
    });
  });
}
