import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/product.dart';
import '../../domain/products_repository.dart';
import '../../../../app/l10n/l10n.dart';

class ProductsController extends GetxController {
  ProductsController({required ProductsRepository repository, this.lookups})
    : _repository = repository;

  final ProductsRepository _repository;
  final LookupService? lookups;

  final products = <Product>[].obs;
  final state = LoadState();
  final search = ''.obs;
  final showInactive = true.obs;

  /// Ids of products whose activation is being saved.
  final busyIds = <int>{}.obs;

  List<Product> get visibleProducts {
    final query = search.value.trim().toLowerCase();
    return products
        .where((p) {
          if (!showInactive.value && !p.isActive) return false;
          if (query.isEmpty) return true;
          return p.name.toLowerCase().contains(query) ||
              (p.description?.toLowerCase().contains(query) ?? false);
        })
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    products.assignAll(await _repository.getProducts(includeInactive: true));
  });

  Future<ActionResult<Product>> setActive(
    Product product,
    bool isActive,
  ) async {
    if (busyIds.contains(product.id)) {
      return ActionResult.success(product);
    }
    busyIds.add(product.id);
    try {
      final result = await ActionResult.guard(
        () => _repository.setProductActive(product.id, isActive),
      );
      if (result.isSuccess) await afterMutation();
      return result;
    } finally {
      busyIds.remove(product.id);
    }
  }

  /// Reloads the list and the shared lookup cache used by forms/filters.
  Future<void> afterMutation() async {
    await load();
    await lookups?.refreshQuietly();
  }
}

class ProductFormController extends GetxController {
  ProductFormController({required ProductsRepository repository, this.initial})
    : _repository = repository;

  final ProductsRepository _repository;
  final Product? initial;

  bool get isEdit => initial != null;

  final formKey = GlobalKey<FormState>();
  late final name = TextEditingController(text: initial?.name);
  late final description = TextEditingController(text: initial?.description);
  late final isActive = (initial?.isActive ?? true).obs;

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;

  String? validateName(String? v) =>
      serverErrors['name'] ??
      Validators.combine([
        () => Validators.required(v, field: tr.validFieldName),
        () => Validators.maxLength(v, 150),
      ]);

  String? validateDescription(String? v) =>
      serverErrors['description'] ?? Validators.maxLength(v, 1000);

  Map<String, String> validateAll() {
    final errors = <String, String>{};
    final n = validateName(name.text);
    if (n != null) errors['name'] = n;
    final d = validateDescription(description.text);
    if (d != null) errors['description'] = d;
    return errors;
  }

  Future<Product?> submit() async {
    if (isSubmitting.value) return null;
    serverErrors.clear();
    errorMessage.value = null;
    final widgetValid = formKey.currentState?.validate() ?? true;
    if (!widgetValid || validateAll().isNotEmpty) return null;
    isSubmitting.value = true;
    try {
      final payload = ProductPayload(
        name: name.text,
        description: description.text,
        isActive: isActive.value,
      );
      return isEdit
          ? await _repository.updateProduct(initial!.id, payload)
          : await _repository.createProduct(payload);
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k] = m.first;
      });
      errorMessage.value = e.describeFor(const {'name', 'description'});
      formKey.currentState?.validate();
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
    name.dispose();
    description.dispose();
    super.onClose();
  }
}
