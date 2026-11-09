import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/network/api_exceptions.dart';
import '../../features/products/data/models/product.dart';
import '../../features/products/domain/products_repository.dart';
import '../../features/settings/data/models/loss_reason.dart';
import '../../features/settings/data/models/sales_stage.dart';
import '../../features/settings/domain/settings_repositories.dart';

/// Shared cache of reference data (stages, products, loss reasons) used by
/// filters and forms across features.
///
/// Holds every item including inactive ones (filters must be able to target
/// a deactivated stage); forms use the `active*` getters.
class LookupService extends GetxService {
  LookupService({
    required SalesStagesRepository stagesRepository,
    required ProductsRepository productsRepository,
    required LossReasonsRepository lossReasonsRepository,
  }) : _stagesRepo = stagesRepository,
       _productsRepo = productsRepository,
       _reasonsRepo = lossReasonsRepository;

  final SalesStagesRepository _stagesRepo;
  final ProductsRepository _productsRepo;
  final LossReasonsRepository _reasonsRepo;

  final stages = <SalesStage>[].obs;
  final products = <Product>[].obs;
  final lossReasons = <LossReason>[].obs;
  final isLoaded = false.obs;
  final lastError = Rxn<ApiException>();

  Future<void>? _pending;

  List<SalesStage> get activeStages =>
      stages.where((s) => s.isActive).toList(growable: false);
  List<Product> get activeProducts =>
      products.where((p) => p.isActive).toList(growable: false);
  List<LossReason> get activeLossReasons =>
      lossReasons.where((r) => r.isActive).toList(growable: false);

  SalesStage? stageById(int? id) => stages.firstWhereOrNull((s) => s.id == id);

  /// Loads everything once; concurrent callers share the same request.
  Future<void> ensureLoaded() {
    if (isLoaded.value) return Future.value();
    return refreshAll();
  }

  /// Reloads all reference data. Throws [ApiException] on failure.
  Future<void> refreshAll() =>
      _pending ??= _load().whenComplete(() => _pending = null);

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _stagesRepo.getStages(includeInactive: true),
        _productsRepo.getProducts(includeInactive: true),
        _reasonsRepo.getLossReasons(includeInactive: true),
      ]);
      stages.assignAll(results[0] as List<SalesStage>);
      products.assignAll(results[1] as List<Product>);
      lossReasons.assignAll(results[2] as List<LossReason>);
      isLoaded.value = true;
      lastError.value = null;
    } catch (e) {
      final error = ApiException.from(e);
      lastError.value = error;
      debugPrint('[Lookups] load failed: $error');
      throw error;
    }
  }

  /// Background refresh used after settings changes; failures are recorded in
  /// [lastError] and logged instead of interrupting the user.
  Future<void> refreshQuietly() async {
    try {
      await refreshAll();
    } on ApiException {
      // Already recorded and logged in _load().
    }
  }

  Future<void> refreshStages() async {
    stages.assignAll(await _stagesRepo.getStages(includeInactive: true));
  }

  Future<void> refreshProducts() async {
    products.assignAll(await _productsRepo.getProducts(includeInactive: true));
  }

  Future<void> refreshLossReasons() async {
    lossReasons.assignAll(
      await _reasonsRepo.getLossReasons(includeInactive: true),
    );
  }
}
