import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../../products/data/models/product.dart';
import '../../../products/domain/pack_rules.dart';
import '../../../products/domain/products_repository.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../data/models/customer_models.dart';
import '../../domain/customers_repository.dart';

/// Customer list (converted prospects), searchable and paged by the server.
class CustomersListController extends GetxController {
  CustomersListController({required CustomersRepository repository})
    : _repository = repository;

  final CustomersRepository _repository;

  final page = Rx<Paginated<Prospect>>(const Paginated.empty());
  final state = LoadState();
  final search = ''.obs;
  int _pageNumber = 1;
  int _perPage = 25;

  List<Prospect> get customers => page.value.items;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    page.value = await _repository.getCustomers(
      search: search.value,
      page: _pageNumber,
      perPage: _perPage,
    );
  });

  Future<void> setSearch(String value) {
    if (value.trim() == search.value.trim()) return Future.value();
    search.value = value;
    _pageNumber = 1;
    return load();
  }

  Future<void> goToPage(int value) {
    _pageNumber = value;
    return load();
  }

  Future<void> setPerPage(int value) {
    _perPage = value;
    _pageNumber = 1;
    return load();
  }
}

/// Profile of one customer: linked products, portal accounts, trials and
/// appointments. Trials are managed here (activate / revoke).
class CustomerProfileController extends GetxController {
  CustomerProfileController({
    required this.prospectId,
    required CustomersRepository repository,
  }) : _repository = repository;

  final int prospectId;
  final CustomersRepository _repository;

  final profile = Rxn<CustomerProfile>();
  final state = LoadState();
  final busyTrialIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    profile.value = await _repository.getCustomer(prospectId);
  });

  Future<ActionResult<Trial>> revokeTrial(Trial trial) async {
    if (busyTrialIds.contains(trial.id)) {
      return ActionResult.success(trial);
    }
    busyTrialIds.add(trial.id);
    try {
      final result = await ActionResult.guard(
        () => _repository.revokeTrial(trial.id),
      );
      if (result.isSuccess) await load();
      return result;
    } finally {
      busyTrialIds.remove(trial.id);
    }
  }
}

/// Converts a prospect into a customer (explicit, audited transition). The
/// prospect, its history and its product interests are kept; the chosen
/// products become purchased products.
class ConvertProspectController extends GetxController {
  ConvertProspectController({
    required CustomersRepository repository,
    required this.prospect,
    this.catalog = const [],
  }) : _repository = repository {
    selectedProductIds.addAll(prospect.products.map((p) => p.id));
  }

  final CustomersRepository _repository;
  final Prospect prospect;

  /// Every product (with its pack) so "one product per pack" can be applied
  /// while ticking. Empty = no pack rule on the client (the server still
  /// enforces it).
  final List<Product> catalog;

  final note = TextEditingController();
  final selectedProductIds = <int>{}.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  /// The server says it already is a customer (`409 ALREADY_CUSTOMER`).
  final alreadyCustomer = false.obs;
  final serverErrors = <String, String>{}.obs;

  /// Checks/unchecks a product. Checking a tier of a pack unchecks the other
  /// tiers of that pack; the dropped products are returned so the UI can say
  /// so.
  List<Product> toggleProduct(int id, bool selected) {
    final dropped = <Product>[];
    final next = PackRules.toggle(
      catalog: catalog,
      selected: selectedProductIds.toSet(),
      productId: id,
      checked: selected,
      onReplaced: dropped.addAll,
    );
    selectedProductIds
      ..clear()
      ..addAll(next);
    return dropped;
  }

  ConvertPayload buildPayload() => ConvertPayload(
    productIds: selectedProductIds.toList()..sort(),
    note: note.text,
  );

  Future<Prospect?> submit() async {
    if (isSubmitting.value) return null;
    isSubmitting.value = true;
    errorMessage.value = null;
    alreadyCustomer.value = false;
    serverErrors.clear();
    try {
      return await _repository.convertProspect(prospect.id, buildPayload());
    } on ConflictException catch (e) {
      if (e.errorCode == 'ALREADY_CUSTOMER') {
        alreadyCustomer.value = true;
        errorMessage.value = tr.wfAlreadyCustomer;
      } else {
        errorMessage.value = e.message;
      }
      return null;
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k.split('.').first] = m.first;
      });
      errorMessage.value = e.describeFor(const {'note'});
      return null;
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    note.dispose();
    super.onClose();
  }
}

/// Activates trial access for a customer and one or more products.
class TrialFormController extends GetxController {
  TrialFormController({
    required CustomersRepository repository,
    required this.prospectId,
    ProductsRepository? productsRepository,
    this.initialProductId,
    this.initialProductIds,
    this.initialNotes,
    this.defaultDays,
    DateTime Function()? clock,
  }) : _repository = repository,
       _products = productsRepository,
       _clock = clock ?? DateTime.now {
    if (initialProductId != null) {
      productId.value = initialProductId;
      selectedProductIds.add(initialProductId!);
    }
    if (initialProductIds != null) {
      selectedProductIds.addAll(initialProductIds!);
      if (productId.value == null && selectedProductIds.isNotEmpty) {
        productId.value = selectedProductIds.first;
      }
    }
    if (initialNotes != null && initialNotes!.trim().isNotEmpty) {
      notes.text = initialNotes!.trim();
    }
    final now = _clock();
    startsAt.value = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    if (defaultDays != null) {
      endsAt.value = startsAt.value!.add(Duration(days: defaultDays!));
    }
  }

  final CustomersRepository _repository;
  final ProductsRepository? _products;
  final int prospectId;
  final int? initialProductId;
  final List<int>? initialProductIds;
  final String? initialNotes;

  /// Products this customer/prospect is linked to AND that have a fixed demo
  /// link (`GET /products?prospect_id=..&has_demo=1`).
  final products = <Product>[].obs;
  final selectedProductIds = <int>{}.obs;
  final isLoadingProducts = false.obs;
  final productsError = RxnString();

  /// `trial_default_days` from the scheduling settings (null = unknown).
  final int? defaultDays;
  final DateTime Function() _clock;

  final formKey = GlobalKey<FormState>();
  final notes = TextEditingController();
  final productId = RxnInt();
  final startsAt = Rxn<DateTime>();
  final endsAt = Rxn<DateTime>();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void toggleProduct(int id, bool selected) {
    if (selected) {
      selectedProductIds.add(id);
      productId.value ??= id;
    } else {
      selectedProductIds.remove(id);
      if (productId.value == id) {
        productId.value = selectedProductIds.firstOrNull;
      }
    }
  }

  void setDurationDays(int days) {
    final s = startsAt.value ?? _clock();
    startsAt.value = s;
    endsAt.value = s.add(Duration(days: days));
  }

  /// Only products linked to this customer that have a demo link are offered.
  Future<void> loadProducts() async {
    final repository = _products;
    if (repository == null) return;
    isLoadingProducts.value = true;
    productsError.value = null;
    try {
      final loaded = await repository.getProducts(prospectId: prospectId, hasDemo: true);
      products.assignAll(loaded);

      if (selectedProductIds.isEmpty) {
        if (initialProductId != null && products.any((p) => p.id == initialProductId)) {
          selectedProductIds.add(initialProductId!);
        } else if (initialProductIds != null && initialProductIds!.isNotEmpty) {
          final matches = products.where((p) => initialProductIds!.contains(p.id)).map((p) => p.id);
          selectedProductIds.addAll(matches);
        } else if (products.isNotEmpty) {
          selectedProductIds.addAll(products.map((p) => p.id));
        }
      } else {
        selectedProductIds.removeWhere((id) => !products.any((p) => p.id == id));
      }

      if (selectedProductIds.isNotEmpty) {
        productId.value = selectedProductIds.first;
      } else if (products.any((p) => p.id == productId.value)) {
        selectedProductIds.add(productId.value!);
      } else {
        productId.value = null;
      }
    } catch (e) {
      productsError.value = ApiException.from(e).message;
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// The demo link of the selected product: fixed, never typed by hand.
  Product? get selectedProduct =>
      products.firstWhereOrNull((p) => p.id == (productId.value ?? selectedProductIds.firstOrNull));

  String? get endError {
    final s = startsAt.value;
    final e = endsAt.value;
    if (s != null && e != null && !e.isAfter(s)) return tr.wfEndAfterStart;
    return serverErrors['ends_at'];
  }

  Future<Trial?> submit() async {
    if (isSubmitting.value) return null;
    serverErrors.clear();
    errorMessage.value = null;
    final valid = formKey.currentState?.validate() ?? true;
    final ids = selectedProductIds.isNotEmpty
        ? selectedProductIds.toList()
        : (productId.value != null ? [productId.value!] : <int>[]);
    if (ids.isEmpty) {
      errorMessage.value = tr.wfSelectProduct;
      return null;
    }
    if (!valid || endError != null) return null;
    isSubmitting.value = true;
    try {
      final payload = ids.length > 1
          ? TrialPayload(
              productIds: ids,
              startsAt: startsAt.value,
              endsAt: endsAt.value,
              internalNotes: notes.text,
            )
          : TrialPayload(
              productId: ids.first,
              startsAt: startsAt.value,
              endsAt: endsAt.value,
              internalNotes: notes.text,
            );
      return await _repository.activateTrial(prospectId, payload);
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k.split('.').first] = m.first;
      });
      errorMessage.value = e.describeFor(const {'ends_at', 'product_id', 'product_ids'});
      formKey.currentState?.validate();
      return null;
    } on ConflictException catch (e) {
      // TRIAL_OVERLAP: a trial for this product already covers the period.
      errorMessage.value = e.errorCode == 'TRIAL_OVERLAP'
          ? tr.wfTrialOverlap
          : e.message;
      return null;
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    notes.dispose();
    super.onClose();
  }
}
