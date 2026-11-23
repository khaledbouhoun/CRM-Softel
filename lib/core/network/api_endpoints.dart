/// Every API path used by the client, relative to the configured base URL
/// (`http://SERVER_IP:PORT/api/v1`). The contract is the backend's
/// `docs/API.md` (see docs/API_CONTRACT.md).
class ApiEndpoints {
  const ApiEndpoints._();

  // System
  static const health = '/health';

  // Dashboard
  static const dashboard = '/dashboard';

  // Analytics
  static const analytics = '/analytics';

  // Prospects
  static const prospects = '/prospects';
  static String prospect(int id) => '/prospects/$id';
  static String prospectChangeStage(int id) => '/prospects/$id/change-stage';
  static String prospectStageHistory(int id) => '/prospects/$id/stage-history';
  static String prospectActivities(int id) => '/prospects/$id/activities';
  static String prospectFollowUps(int id) => '/prospects/$id/follow-ups';

  // Activities
  static const activities = '/activities';
  static String activity(int id) => '/activities/$id';
  static String activityLinkProspect(int id) => '/activities/$id/link-prospect';
  static String activityLinkFollowUp(int id) => '/activities/$id/link-follow-up';

  // Follow-ups
  static const followUps = '/follow-ups';
  static String followUp(int id) => '/follow-ups/$id';
  static String followUpComplete(int id) => '/follow-ups/$id/complete';
  static String followUpCancel(int id) => '/follow-ups/$id/cancel';
  static String followUpConvert(int id) =>
      '/follow-ups/$id/convert-to-activity';

  // Products
  static const products = '/products';
  static String product(int id) => '/products/$id';
  static const uploadProductDemo = '/products/upload-demo';
  static const uploadProductImage = '/products/upload-image';

  // Packs
  static const packs = '/packs';
  static String pack(int id) => '/packs/$id';

  // Sales stages
  static const salesStages = '/sales-stages';
  static String salesStage(int id) => '/sales-stages/$id';
  static const salesStagesReorder = '/sales-stages/reorder';

  // Loss reasons
  static const lossReasons = '/loss-reasons';
  static String lossReason(int id) => '/loss-reasons/$id';
  static const lossReasonsReorder = '/loss-reasons/reorder';

  // Prospect form configurable list options
  static const prospectFormOptions = '/prospect-form-options';
  static String prospectFormOption(int id) => '/prospect-form-options/$id';
  static const prospectFormOptionsReorder = '/prospect-form-options/reorder';

  // Employees (heartbeat sessions)
  static const heartbeat = '/system/heartbeat';
  static const employees = '/system/employees';
  static const employeePresence = '/system/employees/presence';

  // Customers and conversion (docs/PORTAL_AND_WORKFLOWS.md section 3)
  static const customers = '/customers';
  static String customer(int id) => '/customers/$id';
  static String prospectConvert(int id) => '/prospects/$id/convert';
  static String prospectTrials(int id) => '/prospects/$id/trials';
  static String trialRevoke(int id) => '/trials/$id/revoke';

  // Appointments, calendar, website requests
  static const calendar = '/calendar';
  static const appointments = '/appointments';
  static String appointment(int id) => '/appointments/$id';
  static String appointmentAction(int id, String action) =>
      '/appointments/$id/$action';
  static String appointmentSeriesCancel(int id) =>
      '/appointment-series/$id/cancel';
  static const portalRequests = '/portal-requests';
  static String portalRequest(int id) => '/portal-requests/$id';

  // Interventions (after-sales)
  static const interventions = '/interventions';
  static String intervention(int id) => '/interventions/$id';
  static String interventionAction(int id, String action) =>
      '/interventions/$id/$action';
  static String interventionAttachment(int id, int attachmentId) =>
      '/interventions/$id/attachments/$attachmentId';
  static String interventionAttachmentPreview(int id, int attachmentId) =>
      '/interventions/$id/attachments/$attachmentId/preview';

  // Product releases / updates (staff management)
  static const productReleases = '/product-releases';
  static String productRelease(int id) => '/product-releases/$id';
  static String productReleaseInstaller(int id) =>
      '/product-releases/$id/installer';
  static String productReleaseDownload(int id) =>
      '/product-releases/$id/download';

  // Billing (cash only): subscriptions, renewals, invoices, scanned receipts
  static const billingSubscriptions = '/billing/subscriptions';
  static String billingCustomer(int prospectId) =>
      '/billing/customers/$prospectId';
  static String billingMaintenance(int prospectId) =>
      '/billing/customers/$prospectId/maintenance';
  static String billingCustomerInvoices(int prospectId) =>
      '/billing/customers/$prospectId/invoices';
  static String billingRenewalQuote(int id) =>
      '/billing/renewal-requests/$id/quote';
  static String billingRenewalMarkPaid(int id) =>
      '/billing/renewal-requests/$id/mark-paid';
  static String billingInvoiceMarkPaid(int id) =>
      '/billing/invoices/$id/mark-paid';
  static String billingInvoiceReceipt(int id) =>
      '/billing/invoices/$id/receipt';

  // Settings
  static String settingsHelp(String section) => '/settings/help/$section';
  static const schedulingSettings = '/settings/scheduling';
  static String config(String entity) => '/config/$entity';
  static String configRow(String entity, int id) => '/config/$entity/$id';

  /// Lightweight endpoint used to test the connection (also checks the
  /// database: it answers 503 when MySQL is down).
  static const connectionCheck = health;
}
