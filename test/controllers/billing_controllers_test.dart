import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/core/state/load_state.dart';
import 'package:softel_crm/features/billing/data/models/billing_models.dart';
import 'package:softel_crm/features/billing/presentation/controllers/billing_controllers.dart';

import '../helpers/billing_fixtures.dart';
import '../helpers/fixtures.dart';
import '../helpers/mock_http_adapter.dart';

void main() {
  late BillingTestEnv env;

  setUp(() {
    Get.testMode = true;
    env = BillingTestEnv();
  });

  tearDown(Get.reset);

  group('BillingListController', () {
    test('loads on init and reloads with the chosen status', () async {
      env.adapter.reply(
        'GET',
        '/billing/subscriptions',
        paginated([billingRowJson()]),
      );
      final c = Get.put(BillingListController(repository: env.repository));
      await pumpEventQueue();
      expect(c.state.isSuccess, isTrue);
      expect(c.rows, hasLength(1));

      await c.setStatus(MaintenanceStatus.expiringSoon);
      expect(
        env.adapter.lastTo('GET', '/billing/subscriptions').query['status'],
        'expiring_soon',
      );
    });

    test('toggleDirection flips asc/desc and restarts at page 1', () async {
      env.adapter.reply('GET', '/billing/subscriptions', paginated([]));
      final c = Get.put(BillingListController(repository: env.repository));
      await pumpEventQueue();
      await c.goToPage(3);
      await c.toggleDirection();
      final q = env.adapter.lastTo('GET', '/billing/subscriptions').query;
      expect(q['direction'], 'desc');
      expect(q['page'], '1');
    });

    test('a failing request leaves an error state', () async {
      env.adapter.fail(
        'GET',
        '/billing/subscriptions',
        DioExceptionType.connectionError,
      );
      final c = Get.put(BillingListController(repository: env.repository));
      await pumpEventQueue();
      expect(c.state.status.value, LoadStatus.error);
    });
  });

  group('BillingDetailController', () {
    test('markRenewalPaid posts the date then refreshes the billing', () async {
      var confirmed = false;
      env.adapter
        ..on('GET', '/billing/customers/7', (_) {
          return MockResponse(
            200,
            wrap(
              customerBillingJson(
                renewals: [
                  renewalJson(status: confirmed ? 'paid_cash' : 'quoted'),
                ],
              ),
            ),
          );
        })
        ..on('POST', '/billing/renewal-requests/3/mark-paid', (_) {
          confirmed = true;
          return MockResponse(200, wrap(customerBillingJson()));
        });
      final c = Get.put(
        BillingDetailController(prospectId: 7, repository: env.repository),
      );
      await pumpEventQueue();
      expect(c.billing.value!.pendingRenewals, hasLength(1));

      final result = await c.markRenewalPaid(
        c.billing.value!.pendingRenewals.single,
        DateTime(2026, 11, 12),
      );
      expect(result.isSuccess, isTrue);
      expect(c.billing.value!.pendingRenewals, isEmpty);
      expect(c.busyIds, isEmpty);
    });

    test('quoteRenewal posts the amount then refreshes the billing', () async {
      var quoted = false;
      env.adapter
        ..on('GET', '/billing/customers/7', (_) {
          return MockResponse(
            200,
            wrap(
              customerBillingJson(
                renewals: [renewalJson(status: quoted ? 'quoted' : 'pending_quote')],
              ),
            ),
          );
        })
        ..on('POST', '/billing/renewal-requests/3/quote', (_) {
          quoted = true;
          return MockResponse(200, wrap(customerBillingJson()));
        });
      final c = Get.put(
        BillingDetailController(prospectId: 7, repository: env.repository),
      );
      await pumpEventQueue();
      expect(c.billing.value!.renewalRequests.single.isPendingQuote, isTrue);

      final result = await c.quoteRenewal(c.billing.value!.renewalRequests.single, 72000);
      expect(result.isSuccess, isTrue);
      expect(env.adapter.lastTo('POST', '/billing/renewal-requests/3/quote').json['amount_dzd'], 72000);
      expect(c.billing.value!.renewalRequests.single.isQuoted, isTrue);
    });

    test('a failed mark-paid reports the error and keeps the data', () async {
      env.adapter
        ..reply('GET', '/billing/customers/7', wrap(customerBillingJson()))
        ..reply(
          'POST',
          '/billing/renewal-requests/3/mark-paid',
          {'success': false, 'message': 'Already confirmed.', 'error_code': 'ALREADY_CONFIRMED'},
          status: 422,
        );
      final c = Get.put(
        BillingDetailController(prospectId: 7, repository: env.repository),
      );
      await pumpEventQueue();
      final result = await c.markRenewalPaid(
        c.billing.value!.pendingRenewals.single,
        DateTime(2026, 11, 12),
      );
      expect(result.isSuccess, isFalse);
      expect(c.billing.value!.pendingRenewals, hasLength(1));
      expect(c.busyIds, isEmpty);
    });

    test('removeReceipt calls DELETE and reloads', () async {
      env.adapter
        ..reply(
          'GET',
          '/billing/customers/7',
          wrap(customerBillingJson(invoices: [invoiceJson(hasPdf: true)])),
        )
        ..reply('DELETE', '/billing/invoices/11/receipt', wrap(invoiceJson()));
      final c = Get.put(
        BillingDetailController(prospectId: 7, repository: env.repository),
      );
      await pumpEventQueue();
      final result = await c.removeReceipt(c.billing.value!.invoices.single);
      expect(result.isSuccess, isTrue);
      expect(env.adapter.requestsTo('DELETE', '/billing/invoices/11/receipt'), hasLength(1));
      expect(env.adapter.requestsTo('GET', '/billing/customers/7'), hasLength(2));
    });
  });

  group('MarkPaidController', () {
    test('defaults the date to today and confirms the renewal', () async {
      env.adapter
        ..reply('GET', '/billing/customers/7', wrap(customerBillingJson()))
        ..reply(
          'POST',
          '/billing/renewal-requests/3/mark-paid',
          wrap(customerBillingJson()),
        );
      final detail = Get.put(
        BillingDetailController(prospectId: 7, repository: env.repository),
      );
      await pumpEventQueue();
      final c = MarkPaidController(
        detail: detail,
        renewal: detail.billing.value!.renewalRequests.single,
        clock: () => DateTime(2026, 11, 16, 8),
      );
      expect(c.paidAt.value, DateTime(2026, 11, 16));
      expect(await c.submit(), isTrue);
      expect(
        env.adapter.lastTo('POST', '/billing/renewal-requests/3/mark-paid').json['paid_at'],
        '2026-11-16',
      );
    });
  });

  group('MaintenanceFormController', () {
    test('rejects an end date that is not after the start', () {
      final c = MaintenanceFormController(
        prospectId: 7,
        repository: env.repository,
        clock: () => DateTime(2026, 11, 16),
      );
      expect(c.periodError, isNull);
      c.expiresAt.value = c.startsAt.value;
      expect(c.periodError, isNotNull);
    });

    test('submit sends the period', () async {
      env.adapter.reply(
        'PUT',
        '/billing/customers/7/maintenance',
        wrap(customerBillingJson()),
      );
      final c = MaintenanceFormController(
        prospectId: 7,
        repository: env.repository,
        clock: () => DateTime(2026, 11, 16),
      );
      expect(await c.submit(), isNotNull);
      final body = env.adapter.lastTo('PUT', '/billing/customers/7/maintenance').json;
      expect(body['starts_at'], '2026-11-16');
      expect(body['expires_at'], '2026-12-31');
    });
  });

  group('InvoiceFormController', () {
    test('validates the amount before sending', () async {
      final c = InvoiceFormController(prospectId: 7, repository: env.repository);
      expect(c.validateAmount('abc'), isNotNull);
      expect(c.validateAmount('-5'), isNotNull);
      expect(c.validateAmount('36000'), isNull);
    });
  });
}
