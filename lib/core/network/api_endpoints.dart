/// Every API path used by the client, relative to the configured base URL
/// (`http://SERVER_IP:PORT/api/v1`). The contract is the backend's
/// `docs/API.md` (see docs/API_CONTRACT.md).
class ApiEndpoints {
  const ApiEndpoints._();

  // System
  static const health = '/health';

  // Dashboard
  static const dashboard = '/dashboard';

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

  // Sales stages
  static const salesStages = '/sales-stages';
  static String salesStage(int id) => '/sales-stages/$id';
  static const salesStagesReorder = '/sales-stages/reorder';

  // Loss reasons
  static const lossReasons = '/loss-reasons';
  static String lossReason(int id) => '/loss-reasons/$id';
  static const lossReasonsReorder = '/loss-reasons/reorder';

  /// Lightweight endpoint used to test the connection (also checks the
  /// database: it answers 503 when MySQL is down).
  static const connectionCheck = health;
}
