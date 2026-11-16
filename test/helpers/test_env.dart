import 'package:get/get.dart';
import 'package:softel_crm/app/services/lookup_service.dart';
import 'package:softel_crm/core/network/api_client.dart';
import 'package:softel_crm/features/activities/data/datasources/activities_remote_data_source.dart';
import 'package:softel_crm/features/activities/data/repositories/activities_repository_impl.dart';
import 'package:softel_crm/features/activities/domain/activities_repository.dart';
import 'package:softel_crm/features/follow_ups/data/datasources/follow_ups_remote_data_source.dart';
import 'package:softel_crm/features/follow_ups/data/repositories/follow_ups_repository_impl.dart';
import 'package:softel_crm/features/follow_ups/domain/follow_ups_repository.dart';
import 'package:softel_crm/features/products/data/datasources/products_remote_data_source.dart';
import 'package:softel_crm/features/products/data/repositories/products_repository_impl.dart';
import 'package:softel_crm/features/products/domain/products_repository.dart';
import 'package:softel_crm/features/prospects/data/datasources/prospects_remote_data_source.dart';
import 'package:softel_crm/features/prospects/data/repositories/prospects_repository_impl.dart';
import 'package:softel_crm/features/prospects/domain/prospects_repository.dart';
import 'package:softel_crm/features/settings/data/datasources/loss_reasons_remote_data_source.dart';
import 'package:softel_crm/features/settings/data/datasources/prospect_form_options_remote_data_source.dart';
import 'package:softel_crm/features/settings/data/datasources/sales_stages_remote_data_source.dart';
import 'package:softel_crm/features/settings/data/repositories/settings_repositories_impl.dart';
import 'package:softel_crm/features/settings/domain/settings_repositories.dart';

import 'fixtures.dart';
import 'mock_http_adapter.dart';

/// Real repositories wired to a [MockHttpAdapter]: tests exercise the whole
/// client stack (controller → repository → data source → Dio) with canned
/// HTTP responses.
class TestEnv {
  TestEnv() {
    api = buildTestClient(adapter);
    prospects = ProspectsRepositoryImpl(ProspectsRemoteDataSource(api));
    activities = ActivitiesRepositoryImpl(ActivitiesRemoteDataSource(api));
    followUps = FollowUpsRepositoryImpl(FollowUpsRemoteDataSource(api));
    products = ProductsRepositoryImpl(ProductsRemoteDataSource(api));
    stages = SalesStagesRepositoryImpl(SalesStagesRemoteDataSource(api));
    lossReasons = LossReasonsRepositoryImpl(LossReasonsRemoteDataSource(api));
    prospectFormOptions = ProspectFormOptionsRepositoryImpl(
      ProspectFormOptionsRemoteDataSource(api),
    );
    lookups = LookupService(
      stagesRepository: stages,
      productsRepository: products,
      lossReasonsRepository: lossReasons,
      prospectFormOptionsRepository: prospectFormOptions,
    );
  }

  final adapter = MockHttpAdapter();
  late final ApiClient api;
  late final ProspectsRepository prospects;
  late final ActivitiesRepository activities;
  late final FollowUpsRepository followUps;
  late final ProductsRepository products;
  late final SalesStagesRepository stages;
  late final LossReasonsRepository lossReasons;
  late final ProspectFormOptionsRepository prospectFormOptions;
  late final LookupService lookups;

  /// Default reference data endpoints.
  void stubReferenceData() {
    adapter
      ..reply(
        'GET',
        '/sales-stages',
        wrap([lostStage, openStage, wonStage, demoStage, inactiveStage]),
      )
      ..reply('GET', '/loss-reasons', wrap([competitor, tooExpensive]))
      ..reply('GET', '/prospect-form-options', wrap(<Map<String, dynamic>>[]))
      ..reply(
        'GET',
        '/products',
        wrap([
          productJson(id: 1, name: 'GestCom'),
          productJson(id: 2, name: 'Paie'),
        ]),
      );
  }

  /// Registers the shared repositories in GetX (for dialogs using Get.find).
  void registerInGet() {
    Get.put<ProspectsRepository>(prospects, permanent: true);
    Get.put<ActivitiesRepository>(activities, permanent: true);
    Get.put<FollowUpsRepository>(followUps, permanent: true);
    Get.put<ProductsRepository>(products, permanent: true);
    Get.put<SalesStagesRepository>(stages, permanent: true);
    Get.put<LossReasonsRepository>(lossReasons, permanent: true);
    Get.put<ProspectFormOptionsRepository>(
      prospectFormOptions,
      permanent: true,
    );
    Get.put<LookupService>(lookups, permanent: true);
  }
}
