import 'package:get/get.dart';

import '../../features/activities/presentation/bindings/activities_binding.dart';
import '../../features/activities/presentation/pages/activities_page.dart';
import '../../features/dashboard/presentation/bindings/dashboard_binding.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/follow_ups/presentation/bindings/follow_ups_binding.dart';
import '../../features/follow_ups/presentation/pages/follow_ups_page.dart';
import '../../features/pipeline/presentation/bindings/pipeline_binding.dart';
import '../../features/pipeline/presentation/pages/pipeline_page.dart';
import '../../features/products/presentation/bindings/products_binding.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/prospects/presentation/bindings/prospects_binding.dart';
import '../../features/prospects/presentation/pages/prospect_details_page.dart';
import '../../features/prospects/presentation/pages/prospects_page.dart';
import '../../features/settings/presentation/bindings/settings_bindings.dart';
import '../../features/settings/presentation/pages/connection_settings_page.dart';
import '../../features/settings/presentation/pages/loss_reasons_settings_page.dart';
import '../../features/settings/presentation/pages/prospect_form_options_settings_page.dart';
import '../../features/settings/presentation/pages/stages_settings_page.dart';
import '../../features/customers/presentation/bindings/customers_binding.dart';
import '../../features/customers/presentation/pages/customer_profile_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/employees/presentation/employees_page.dart';
import '../../features/interventions/presentation/bindings/interventions_binding.dart';
import '../../features/interventions/presentation/pages/intervention_detail_page.dart';
import '../../features/interventions/presentation/pages/interventions_page.dart';
import '../../features/scheduling/presentation/bindings/scheduling_bindings.dart';
import '../../features/scheduling/presentation/pages/calendar_page.dart';
import '../../features/scheduling/presentation/pages/pending_requests_page.dart';
import '../../features/scheduling/presentation/pages/training_page.dart';
import '../../features/workflow_settings/presentation/workflow_settings_page.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static const _transition = Transition.fadeIn;
  static const _duration = Duration(milliseconds: 120);

  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.prospects,
      page: () => const ProspectsPage(),
      binding: ProspectsBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.prospectDetails,
      page: () => const ProspectDetailsPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 180),
    ),
    GetPage(
      name: Routes.pipeline,
      page: () => const PipelinePage(),
      binding: PipelineBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.activities,
      page: () => const ActivitiesPage(),
      binding: ActivitiesBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.followUps,
      page: () => const FollowUpsPage(),
      binding: FollowUpsBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.products,
      page: () => const ProductsPage(),
      binding: ProductsBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.customers,
      page: () => const CustomersPage(),
      binding: CustomersBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.customerDetails,
      page: () => const CustomerProfilePage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 180),
    ),
    GetPage(
      name: Routes.calendar,
      page: () => const CalendarPage(),
      binding: CalendarBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.training,
      page: () => const TrainingPage(),
      binding: TrainingBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.requests,
      page: () => const PendingRequestsPage(),
      binding: PendingRequestsBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.afterSales,
      page: () => const InterventionsPage(),
      binding: InterventionsBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.afterSalesDetails,
      page: () => const InterventionDetailPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 180),
    ),
    GetPage(
      name: Routes.employees,
      page: () => const EmployeesPage(),
      binding: EmployeesBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.workflowSettings,
      page: () => const WorkflowSettingsPage(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const ConnectionSettingsPage(),
      binding: ConnectionSettingsBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.stagesSettings,
      page: () => const StagesSettingsPage(),
      binding: StagesSettingsBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.lossReasonsSettings,
      page: () => const LossReasonsSettingsPage(),
      binding: LossReasonsSettingsBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
    GetPage(
      name: Routes.prospectListsSettings,
      page: () => const ProspectFormOptionsSettingsPage(),
      binding: ProspectFormOptionsSettingsBinding(),
      transition: _transition,
      transitionDuration: _duration,
    ),
  ];
}
