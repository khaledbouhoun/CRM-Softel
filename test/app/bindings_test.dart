import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/app/config/app_settings_service.dart';
import 'package:softel_crm/app/config/key_value_store.dart';
import 'package:softel_crm/app/services/connection_service.dart';
import 'package:softel_crm/core/network/network_info.dart';
import 'package:softel_crm/features/activities/presentation/bindings/activities_binding.dart';
import 'package:softel_crm/features/activities/presentation/controllers/activities_controller.dart';
import 'package:softel_crm/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:softel_crm/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:softel_crm/features/dashboard/domain/dashboard_repository.dart';
import 'package:softel_crm/features/dashboard/presentation/bindings/dashboard_binding.dart';
import 'package:softel_crm/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:softel_crm/features/follow_ups/presentation/bindings/follow_ups_binding.dart';
import 'package:softel_crm/features/follow_ups/presentation/controllers/follow_ups_controller.dart';
import 'package:softel_crm/features/pipeline/presentation/bindings/pipeline_binding.dart';
import 'package:softel_crm/features/pipeline/presentation/controllers/pipeline_controller.dart';
import 'package:softel_crm/features/products/presentation/bindings/products_binding.dart';
import 'package:softel_crm/features/products/presentation/controllers/products_controllers.dart';
import 'package:softel_crm/features/prospects/presentation/bindings/prospects_binding.dart';
import 'package:softel_crm/features/prospects/presentation/controllers/prospects_list_controller.dart';
import 'package:softel_crm/features/settings/presentation/bindings/settings_bindings.dart';
import 'package:softel_crm/features/settings/presentation/controllers/connection_settings_controller.dart';
import 'package:softel_crm/features/settings/presentation/controllers/loss_reasons_settings_controllers.dart';
import 'package:softel_crm/features/settings/presentation/controllers/stages_settings_controllers.dart';

import '../helpers/test_env.dart';

/// Every route binding must resolve its controller from the app-level
/// registrations (regression: `Get.find()` into a nullable parameter looked
/// up `LookupService?` and crashed the settings screens).
void main() {
  setUp(() {
    Get.testMode = true;
    final env = TestEnv()
      ..stubReferenceData()
      ..registerInGet();
    final settings = Get.put(
      AppSettingsService(InMemoryStore()),
      permanent: true,
    );
    Get.put(NetworkInfo(httpClientAdapter: env.adapter), permanent: true);
    Get.put(
      ConnectionService(Get.find(), settings, autoCheck: false),
      permanent: true,
    );
    Get.put<DashboardRepository>(
      DashboardRepositoryImpl(DashboardRemoteDataSource(env.api)),
      permanent: true,
    );
  });

  tearDown(Get.reset);

  void expectResolves<T>(Bindings binding) {
    binding.dependencies();
    expect(Get.find<T>(), isA<T>());
  }

  test('all route bindings resolve their controllers', () {
    expectResolves<DashboardController>(DashboardBinding());
    expectResolves<ProspectsListController>(ProspectsBinding());
    expectResolves<PipelineController>(PipelineBinding());
    expectResolves<ActivitiesController>(ActivitiesBinding());
    expectResolves<FollowUpsController>(FollowUpsBinding());
    expectResolves<ProductsController>(ProductsBinding());
    expectResolves<StagesSettingsController>(StagesSettingsBinding());
    expectResolves<LossReasonsSettingsController>(LossReasonsSettingsBinding());
    expectResolves<ConnectionSettingsController>(ConnectionSettingsBinding());
  });

  test('controllers with optional services receive them from the binding', () {
    ProductsBinding().dependencies();
    StagesSettingsBinding().dependencies();
    ConnectionSettingsBinding().dependencies();
    expect(Get.find<ProductsController>().lookups, isNotNull);
    expect(Get.find<StagesSettingsController>().lookups, isNotNull);
    final connection = Get.find<ConnectionSettingsController>();
    expect(connection.connection, isNotNull);
    expect(connection.lookups, isNotNull);
  });
}
