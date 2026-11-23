import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/file_access.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_feedback.dart';
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

  /// Clicked column: `name`, `prospects` or `status`; null = server order.
  final sortKey = RxnString();
  final ascending = true.obs;

  void sortBy(String key) {
    ascending.value = sortKey.value == key ? !ascending.value : true;
    sortKey.value = key;
  }

  List<Product> get visibleProducts {
    final query = search.value.trim().toLowerCase();
    final list = products
        .where((p) {
          if (!showInactive.value && !p.isActive) return false;
          if (query.isEmpty) return true;
          return p.name.toLowerCase().contains(query) ||
              (p.description?.toLowerCase().contains(query) ?? false);
        })
        .toList();
    final key = sortKey.value;
    if (key == null) return list;
    Comparable<Object> value(Product p) => switch (key) {
      'prospects' => p.prospectsCount ?? 0,
      'status' => p.isActive ? 0 : 1,
      _ => p.name.toLowerCase(),
    };
    final dir = ascending.value ? 1 : -1;
    list.sort((a, b) => dir * value(a).compareTo(value(b)));
    return list;
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
  late final packId = RxnInt(initial?.packId);
  late final demoUrl = TextEditingController(text: initial?.demoUrl);
  late final isActiveOnWeb = (initial?.isActiveOnWeb ?? false).obs;

  // Catalog & web.
  static const languages = ['ar', 'fr', 'en'];
  static const maxFeatures = 50;
  static const maxImageBytes = 5 * 1024 * 1024;

  late final slug = TextEditingController(text: initial?.slug);
  late final sortOrder = TextEditingController(
    text: (initial?.sortOrder ?? 0).toString(),
  );
  late final imagePath = RxnString(initial?.imagePath);
  late final imageUrl = TextEditingController(text: initial?.imagePath);
  final isUploadingImage = false.obs;
  final imageUploadProgress = 0.0.obs;

  /// Public summary / description per language (`ar`, `fr`, `en`).
  late final summaryI18n = {
    for (final l in languages)
      l: TextEditingController(text: initial?.summaryI18n?[l]),
  };
  late final descriptionI18n = {
    for (final l in languages)
      l: TextEditingController(text: initial?.descriptionI18n?[l]),
  };

  late final features = <String>[...?initial?.features].obs;
  final featureInput = TextEditingController();

  /// Selected form tab: 0 basic info, 1 catalog & web, 2 demo.
  final tab = 0.obs;

  static const _tabOfField = {
    'name': 0,
    'description': 0,
    'pack_id': 0,
    'slug': 0,
    'sort_order': 0,
    'image_path': 0,
    'summary_i18n': 1,
    'description_i18n': 1,
    'features': 1,
    'demo_url': 2,
  };

  /// Switches to the first tab holding a field in error so the user sees it.
  void revealFirstError() {
    final fields = {...validateAll().keys, ...serverErrors.keys};
    final tabs = [
      for (final f in fields) _tabOfField[f.split('.').first] ?? 0,
    ]..sort();
    if (tabs.isNotEmpty) tab.value = tabs.first;
  }

  final isSubmitting = false.obs;
  final isUploadingDemo = false.obs;
  final demoUploadProgress = 0.0.obs;
  final uploadedDemoName = RxnString();
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;

  Future<void> pickAndUploadDemoFile() async {
    if (isUploadingDemo.value || isSubmitting.value) return;
    try {
      final picked = await FileAccess.pick(
        extensions: FileAccess.installerExtensions,
        multiple: false,
      );
      if (picked.isEmpty) return;
      final file = picked.first;
      isUploadingDemo.value = true;
      demoUploadProgress.value = 0.0;
      uploadedDemoName.value = file.name;

      final url = await _repository.uploadDemoFile(
        file,
        productId: initial?.id,
        onProgress: (sent, total) {
          if (total > 0) {
            demoUploadProgress.value = sent / total;
          }
        },
      );

      demoUrl.text = url;
      serverErrors.remove('demo_url');
      AppFeedback.success(tr.productDemoUploaded);
    } catch (e) {
      AppFeedback.error(ApiException.from(e).message);
    } finally {
      isUploadingDemo.value = false;
    }
  }

  /// Picks an image, uploads it and shows it as the product image.
  Future<void> pickAndUploadImage() async {
    if (isUploadingImage.value || isSubmitting.value) return;
    try {
      final picked = await FileAccess.pick(
        extensions: FileAccess.productImageExtensions,
        multiple: false,
      );
      if (picked.isEmpty) return;
      final file = picked.first;
      if (file.size > maxImageBytes) {
        AppFeedback.error(tr.productImageTooLarge);
        return;
      }
      isUploadingImage.value = true;
      imageUploadProgress.value = 0.0;

      final url = await _repository.uploadProductImage(
        file,
        productId: initial?.id,
        onProgress: (sent, total) {
          if (total > 0) imageUploadProgress.value = sent / total;
        },
      );

      setImage(url);
      AppFeedback.success(tr.productImageUploaded);
    } catch (e) {
      AppFeedback.error(ApiException.from(e).message);
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Sets (or clears, when blank) the product image URL.
  void setImage(String? url) {
    final value = url?.trim();
    final next = (value == null || value.isEmpty) ? null : value;
    imagePath.value = next;
    if (imageUrl.text != (next ?? '')) imageUrl.text = next ?? '';
    serverErrors.remove('image_path');
  }

  void clearImage() => setImage(null);

  void addFeature() {
    final text = featureInput.text.trim();
    if (text.isEmpty || features.length >= maxFeatures) return;
    if (!features.contains(text)) features.add(text);
    featureInput.clear();
  }

  void removeFeature(String feature) => features.remove(feature);

  String? validateSlug(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return serverErrors['slug'];
    final ok =
        text.length <= 170 && RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(text);
    return ok ? serverErrors['slug'] : tr.productSlugInvalid;
  }

  String? validateSortOrder(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return null;
    final n = int.tryParse(text);
    return (n != null && n >= 0 && n <= 100000)
        ? serverErrors['sort_order']
        : tr.productSortOrderInvalid;
  }

  String? validateImageUrl(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return serverErrors['image_path'];
    if (text.length > 500) return tr.productImageUrlInvalid;
    final uri = Uri.tryParse(text);
    final ok =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return ok ? serverErrors['image_path'] : tr.productImageUrlInvalid;
  }

  String? validateSummary(String? v) =>
      Validators.maxLength(v, 1000);

  String? validateWebDescription(String? v) =>
      Validators.maxLength(v, 20000);

  String? validateName(String? v) =>
      serverErrors['name'] ??
      Validators.combine([
        () => Validators.required(v, field: tr.validFieldName),
        () => Validators.maxLength(v, 150),
      ]);

  String? validateDescription(String? v) =>
      serverErrors['description'] ?? Validators.maxLength(v, 1000);

  String? validateDemoUrl(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return serverErrors['demo_url'];
    final uri = Uri.tryParse(text);
    final ok =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return ok ? serverErrors['demo_url'] : tr.wfUrlInvalid;
  }

  Map<String, String> validateAll() {
    final errors = <String, String>{};
    final n = validateName(name.text);
    if (n != null) errors['name'] = n;
    final d = validateDescription(description.text);
    if (d != null) errors['description'] = d;
    final u = validateDemoUrl(demoUrl.text);
    if (u != null) errors['demo_url'] = u;
    final sl = validateSlug(slug.text);
    if (sl != null) errors['slug'] = sl;
    final so = validateSortOrder(sortOrder.text);
    if (so != null) errors['sort_order'] = so;
    final im = validateImageUrl(imageUrl.text);
    if (im != null) errors['image_path'] = im;
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
        packId: packId.value,
        demoUrl: demoUrl.text,
        isActiveOnWeb: isActiveOnWeb.value,
        slug: slug.text.trim().isEmpty ? null : slug.text,
        // Always sent so that clearing the image really removes it.
        imagePath: imagePath.value ?? '',
        features: features.toList(),
        summaryI18n: {for (final e in summaryI18n.entries) e.key: e.value.text},
        descriptionI18n: {
          for (final e in descriptionI18n.entries) e.key: e.value.text,
        },
        sortOrder: int.tryParse(sortOrder.text.trim()) ?? 0,
      );
      return isEdit
          ? await _repository.updateProduct(initial!.id, payload)
          : await _repository.createProduct(payload);
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k] = m.first;
      });
      errorMessage.value = e.describeFor(const {
        'name',
        'description',
        'pack_id',
        'demo_url',
        'is_active_on_web',
        'slug',
        'image_path',
        'sort_order',
        'features',
        'summary_i18n',
        'description_i18n',
      });
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
    demoUrl.dispose();
    slug.dispose();
    sortOrder.dispose();
    imageUrl.dispose();
    featureInput.dispose();
    for (final c in [...summaryI18n.values, ...descriptionI18n.values]) {
      c.dispose();
    }
    super.onClose();
  }
}
