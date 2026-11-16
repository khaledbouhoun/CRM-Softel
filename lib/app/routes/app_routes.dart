abstract final class Routes {
  static const dashboard = '/dashboard';
  static const prospects = '/prospects';
  static const prospectDetails = '/prospects/:id';
  static const pipeline = '/pipeline';
  static const activities = '/activities';
  static const followUps = '/follow-ups';
  static const products = '/products';
  static const customers = '/customers';
  static const customerDetails = '/customers/:id';
  static const calendar = '/calendar';
  static const training = '/training';
  static const requests = '/requests';
  static const afterSales = '/after-sales';
  static const afterSalesDetails = '/after-sales/:id';
  static const employees = '/employees';
  static const workflowSettings = '/settings/workflow';
  static const settings = '/settings';
  static const stagesSettings = '/settings/stages';
  static const lossReasonsSettings = '/settings/loss-reasons';
  static const prospectListsSettings = '/settings/prospect-lists';

  static String prospect(int id) => '/prospects/$id';
  static String customer(int id) => '/customers/$id';
  static String afterSalesDetail(int id) => '/after-sales/$id';
}
