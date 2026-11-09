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
import '../../features/settings/data/datasources/sales_stages_remote_data_source.dart';
import '../../features/settings/data/repositories/settings_repositories_impl.dart';
import '../../features/settings/domain/settings_repositories.dart';
import '../config/app_settings_service.dart';
import '../services/connection_service.dart';
import '../services/lookup_service.dart';

/// App-wide singletons. [AppSettingsService] is registered in `main()`
/// before this binding runs.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final settings = Get.find<AppSettingsService>();

    final api = ApiClient(
      baseUrl: settings.apiBaseUrl.value,
      timeout: settings.timeout,
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
    Get.put<DashboardRepository>(
      DashboardRepositoryImpl(DashboardRemoteDataSource(api)),
      permanent: true,
    );

    final lookups = Get.put<LookupService>(
      LookupService(
        stagesRepository: Get.find(),
        productsRepository: Get.find(),
        lossReasonsRepository: Get.find(),
      ),
      permanent: true,
    );

    final connection = Get.put<ConnectionService>(
      ConnectionService(Get.find(), settings),
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
