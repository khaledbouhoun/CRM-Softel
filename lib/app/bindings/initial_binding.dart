import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../features/activities/data/datasources/activities_remote_data_source.dart';
import '../../features/activities/data/repositories/activities_repository_impl.dart';
import '../../features/activities/domain/activities_repository.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/dashboard_repository.dart';
import '../../features/follow_ups/data/datasources/follow_ups_remote_data_source.dart';
import '../../features/follow_ups/data/repositories/follow_ups_repository_impl.dart';
import '../../features/follow_ups/domain/follow_ups_repository.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/products_repository.dart';
import '../../features/prospects/data/datasources/prospects_remote_data_source.dart';
import '../../features/prospects/data/repositories/prospects_repository_impl.dart';
import '../../features/prospects/domain/prospects_repository.dart';
import '../../features/settings/data/datasources/loss_reasons_remote_data_source.dart';
import '../../features/settings/data/datasources/prospect_form_options_remote_data_source.dart';
import '../../features/settings/data/datasources/sales_stages_remote_data_source.dart';
import '../../features/settings/data/repositories/settings_repositories_impl.dart';
import '../../features/settings/domain/settings_repositories.dart';
import '../../features/customers/data/datasources/customers_remote_data_source.dart';
import '../../features/customers/data/repositories/customers_repository_impl.dart';
import '../../features/customers/domain/customers_repository.dart';
import '../../features/employees/data/employees_repository.dart';
import '../../features/interventions/data/datasources/interventions_remote_data_source.dart';
import '../../features/interventions/data/repositories/interventions_repository_impl.dart';
import '../../features/interventions/domain/interventions_repository.dart';
import '../../features/billing/data/datasources/billing_remote_data_source.dart';
import '../../features/billing/data/repositories/billing_repository_impl.dart';
import '../../features/billing/domain/billing_repository.dart';
import '../../features/releases/data/datasources/releases_remote_data_source.dart';
import '../../features/releases/data/repositories/releases_repository_impl.dart';
import '../../features/releases/domain/releases_repository.dart';
import '../../features/scheduling/data/datasources/scheduling_remote_data_source.dart';
import '../../features/scheduling/data/repositories/scheduling_repository_impl.dart';
import '../../features/scheduling/domain/scheduling_repository.dart';
import '../../features/workflow_settings/data/datasources/workflow_config_remote_data_source.dart';
import '../../features/workflow_settings/data/repositories/workflow_config_repository_impl.dart';
import '../../features/workflow_settings/domain/workflow_config_repository.dart';
import '../config/app_settings_service.dart';
import '../services/connection_service.dart';
import '../services/employee_identity.dart';
import '../services/lookup_service.dart';
import '../services/workflow_lookup_service.dart';

/// App-wide singletons. [AppSettingsService] is registered in `main()`
/// before this binding runs.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final settings = Get.find<AppSettingsService>();

    final identity = Get.put<EmployeeIdentity>(
      EmployeeIdentity(),
      permanent: true,
    );
    final api = ApiClient(
      baseUrl: settings.apiBaseUrl.value,
      timeout: settings.timeout,
      employeeName: () => identity.headerValue,
    );
    Get.put<ApiClient>(api, permanent: true);
    Get.put<NetworkInfo>(NetworkInfo(), permanent: true);

    // Repositories are shared by several features, so they live for the whole
    // app session.
    Get.put<ProspectsRepository>(
      ProspectsRepositoryImpl(ProspectsRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<ActivitiesRepository>(
      ActivitiesRepositoryImpl(ActivitiesRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<FollowUpsRepository>(
      FollowUpsRepositoryImpl(FollowUpsRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<ProductsRepository>(
      ProductsRepositoryImpl(ProductsRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<SalesStagesRepository>(
      SalesStagesRepositoryImpl(SalesStagesRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<LossReasonsRepository>(
      LossReasonsRepositoryImpl(LossReasonsRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<ProspectFormOptionsRepository>(
      ProspectFormOptionsRepositoryImpl(
        ProspectFormOptionsRemoteDataSource(api),
      ),
      permanent: true,
    );
    Get.put<DashboardRepository>(
      DashboardRepositoryImpl(DashboardRemoteDataSource(api)),
      permanent: true,
    );

    // Customer journey workflows (docs/PORTAL_AND_WORKFLOWS.md, section 3).
    Get.put<CustomersRepository>(
      CustomersRepositoryImpl(CustomersRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<SchedulingRepository>(
      SchedulingRepositoryImpl(SchedulingRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<InterventionsRepository>(
      InterventionsRepositoryImpl(InterventionsRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<ReleasesRepository>(
      ReleasesRepositoryImpl(ReleasesRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<BillingRepository>(
      BillingRepositoryImpl(BillingRemoteDataSource(api)),
      permanent: true,
    );
    Get.put<WorkflowConfigRepository>(
      WorkflowConfigRepositoryImpl(WorkflowConfigRemoteDataSource(api)),
      permanent: true,
    );
    final employees = Get.put<EmployeesRepository>(
      EmployeesRepositoryImpl(api),
      permanent: true,
    );
    Get.put<WorkflowLookupService>(
      WorkflowLookupService(
        config: Get.find(),
        employees: employees,
        identity: identity,
      ),
      permanent: true,
    );

    final lookups = Get.put<LookupService>(
      LookupService(
        stagesRepository: Get.find(),
        productsRepository: Get.find(),
        lossReasonsRepository: Get.find(),
        prospectFormOptionsRepository: Get.find(),
      ),
      permanent: true,
    );

    final connection = Get.put<ConnectionService>(
      ConnectionService(
        Get.find(),
        settings,
        onHeartbeat: () => employees.sendHeartbeat(
          employeeId: identity.employeeId,
          username: identity.username,
          deviceName: identity.deviceName.isEmpty ? null : identity.deviceName,
        ),
      ),
      permanent: true,
    );
    connection.addReconnectListener(lookups.refreshQuietly);

    // Keep the HTTP client in sync with the saved server settings.
    ever<String>(settings.apiBaseUrl, (url) => api.configure(baseUrl: url));
    ever<int>(
      settings.timeoutSeconds,
      (_) => api.configure(timeout: settings.timeout),
    );
  }
}
