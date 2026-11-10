abstract final class Routes {
  static const dashboard = '/dashboard';
  static const prospects = '/prospects';
  static const prospectDetails = '/prospects/:id';
  static const pipeline = '/pipeline';
  static const activities = '/activities';
  static const followUps = '/follow-ups';
  static const products = '/products';
  static const settings = '/settings';
  static const stagesSettings = '/settings/stages';
  static const lossReasonsSettings = '/settings/loss-reasons';
  static const prospectListsSettings = '/settings/prospect-lists';

  static String prospect(int id) => '/prospects/$id';
}
