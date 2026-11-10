import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/network/api_exceptions.dart';
import '../../features/products/data/models/product.dart';
import '../../features/products/domain/products_repository.dart';
import '../../features/settings/data/models/loss_reason.dart';
import '../../features/settings/data/models/prospect_form_option.dart';
import '../../features/settings/data/models/sales_stage.dart';
import '../../features/settings/domain/settings_repositories.dart';

/// Shared cache of reference data (stages, products, loss reasons, prospect form options)
/// used by filters and forms across features.
///
/// Holds every item including inactive ones (filters must be able to target
/// a deactivated stage); forms use the `active*` getters.
class LookupService extends GetxService {
  LookupService({
    required SalesStagesRepository stagesRepository,
    required ProductsRepository productsRepository,
    required LossReasonsRepository lossReasonsRepository,
    required ProspectFormOptionsRepository prospectFormOptionsRepository,
  }) : _stagesRepo = stagesRepository,
       _productsRepo = productsRepository,
       _reasonsRepo = lossReasonsRepository,
       _optionsRepo = prospectFormOptionsRepository;

  final SalesStagesRepository _stagesRepo;
  final ProductsRepository _productsRepo;
  final LossReasonsRepository _reasonsRepo;
  final ProspectFormOptionsRepository _optionsRepo;

  final stages = <SalesStage>[].obs;
  final products = <Product>[].obs;
  final lossReasons = <LossReason>[].obs;
  final prospectFormOptions = <ProspectFormOption>[].obs;
  final isLoaded = false.obs;
  final lastError = Rxn<ApiException>();

  Future<void>? _pending;

  List<SalesStage> get activeStages =>
      stages.where((s) => s.isActive).toList(growable: false);
  List<Product> get activeProducts =>
      products.where((p) => p.isActive).toList(growable: false);
  List<LossReason> get activeLossReasons =>
      lossReasons.where((r) => r.isActive).toList(growable: false);

  List<ProspectFormOption> get activeSources => prospectFormOptions
      .where((o) => o.isActive && o.type == ProspectFormOption.typeSource)
      .toList(growable: false);

  List<ProspectFormOption> get activePreviousSoftware => prospectFormOptions
      .where(
        (o) => o.isActive && o.type == ProspectFormOption.typePreviousSoftware,
      )
      .toList(growable: false);

  List<ProspectFormOption> get activeBusinessActivities => prospectFormOptions
      .where(
        (o) => o.isActive && o.type == ProspectFormOption.typeBusinessActivity,
      )
      .toList(growable: false);

  List<ProspectFormOption> get activeProfessions => prospectFormOptions
      .where((o) => o.isActive && o.type == ProspectFormOption.typeProfession)
      .toList(growable: false);

  SalesStage? stageById(int? id) => stages.firstWhereOrNull((s) => s.id == id);

  ProspectFormOption? findOption(String type, String? value) {
    if (value == null) return null;
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    final normalized = trimmed.replaceAll('_', ' ');
    return prospectFormOptions.firstWhereOrNull(
      (o) =>
          o.type == type &&
          (o.name.trim().toLowerCase() == trimmed ||
              o.name.trim().toLowerCase() == normalized ||
              o.name.trim().toLowerCase().replaceAll(' ', '_') == trimmed),
    );
  }

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
        _optionsRepo.getOptions(includeInactive: true),
      ]);
      stages.assignAll(results[0] as List<SalesStage>);
      products.assignAll(results[1] as List<Product>);
      lossReasons.assignAll(results[2] as List<LossReason>);
      prospectFormOptions.assignAll(results[3] as List<ProspectFormOption>);
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

  Future<void> refreshProspectFormOptions() async {
    prospectFormOptions.assignAll(
      await _optionsRepo.getOptions(includeInactive: true),
    );
  }

  /// Adds a new prospect form option to the backend and immediately updates
  /// the local cache so forms and settings reflect it without a full reload.
  Future<ProspectFormOption> addProspectFormOption({
    required String type,
    required String name,
    bool requiresDetails = false,
  }) async {
    final created = await _optionsRepo.createOption(
      ProspectFormOptionPayload(
        type: type,
        name: name,
        requiresDetails: requiresDetails,
        isActive: true,
      ),
    );
    prospectFormOptions.removeWhere((o) => o.id == created.id);
    prospectFormOptions.add(created);
    return created;
  }
}
