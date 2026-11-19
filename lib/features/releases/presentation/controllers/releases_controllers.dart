import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../core/models/named_ref.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/file_access.dart';
import '../../data/models/product_release.dart';
import '../../domain/releases_repository.dart';

/// Product releases list, optionally filtered by product.
class ReleasesController extends GetxController {
  ReleasesController({required ReleasesRepository repository})
    : _repository = repository;

  final ReleasesRepository _repository;

  final page = Rx<Paginated<ProductRelease>>(const Paginated.empty());
  final state = LoadState();
  final productId = RxnInt();
  final busyIds = <int>{}.obs;
  int _pageNumber = 1;

  List<ProductRelease> get releases => page.value.items;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    page.value = await _repository.getReleases(
      productId: productId.value,
      page: _pageNumber,
    );
  });

  Future<void> setProduct(int? id) {
    productId.value = id;
    _pageNumber = 1;
    return load();
  }

  Future<void> goToPage(int value) {
    _pageNumber = value;
    return load();
  }

  Future<ActionResult<void>> delete(ProductRelease release) async {
    busyIds.add(release.id);
    try {
      final result = await ActionResult.guard<void>(
        () => _repository.delete(release.id),
      );
      if (result.isSuccess) await load();
      return result;
    } finally {
      busyIds.remove(release.id);
    }
  }

  /// Saves the installer of [release] in the Downloads folder.
  Future<ActionResult<String>> saveInstaller(ProductRelease release) =>
      ActionResult.guard(() async {
        final name = release.installer?.name ?? 'installer-${release.id}';
        final path = FileAccess.freePath(FileAccess.downloadsDirectory(), name);
        await _repository.downloadInstaller(release.id, path);
        return path;
      });
}

/// Create / edit form of one release.
class ReleaseFormController extends GetxController {
  ReleaseFormController({
    required ReleasesRepository repository,
    this.existing,
    DateTime Function()? clock,
  }) : _repository = repository {
    final release = existing;
    if (release != null) {
      productId.value = release.product?.id;
      version.text = release.versionNumber;
      changelog.text = release.changelog ?? '';
      downloadUrl.text = release.downloadUrl ?? '';
      date.value = release.releaseDate;
      audience.value = release.audience;
      isPublished.value = release.isPublished;
    } else {
      final now = (clock ?? DateTime.now)();
      date.value = DateTime(now.year, now.month, now.day);
    }
  }

  final ReleasesRepository _repository;
  final ProductRelease? existing;

  bool get isEdit => existing != null;

  final formKey = GlobalKey<FormState>();
  final version = TextEditingController();
  final changelog = TextEditingController();
  final downloadUrl = TextEditingController();
  final productId = RxnInt();
  final date = Rxn<DateTime>();
  final audience = ReleaseAudience.all.obs;
  final isPublished = false.obs;
  final customers = <NamedRef>[].obs;

  /// Installer chosen in this session (not yet uploaded).
  final newInstaller = Rxn<PickedFile>();

  /// The existing installer is to be removed on save.
  final removeExistingInstaller = false.obs;

  final isSubmitting = false.obs;
  final progress = RxnDouble();
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;
  final showValidation = false.obs;

  /// Installer shown in the form after the pending changes.
  ReleaseInstaller? get currentInstaller {
    if (newInstaller.value != null) {
      return ReleaseInstaller(
        name: newInstaller.value!.name,
        size: newInstaller.value!.size,
      );
    }
    return removeExistingInstaller.value ? null : existing?.installer;
  }

  void addCustomer(NamedRef customer) {
    if (!customers.contains(customer)) customers.add(customer);
  }

  void removeCustomer(NamedRef customer) => customers.remove(customer);

  Future<void> pickInstaller() async {
    final picked = await FileAccess.pick(
      extensions: FileAccess.installerExtensions,
      multiple: false,
    );
    if (picked.isEmpty) return;
    newInstaller.value = picked.first;
    removeExistingInstaller.value = false;
  }

  void clearInstaller() {
    if (newInstaller.value != null) {
      newInstaller.value = null;
    } else if (existing?.installer != null) {
      removeExistingInstaller.value = true;
    }
  }

  String? get productError => showValidation.value && productId.value == null
      ? tr.wfSelectProduct
      : serverErrors['product_id'];

  String? get dateError => showValidation.value && date.value == null
      ? tr.validDateRequired
      : serverErrors['release_date'];

  String? get customersError =>
      audience.value == ReleaseAudience.specific &&
          showValidation.value &&
          customers.isEmpty
      ? tr.rlCustomersRequired
      : serverErrors['customer_ids'];

  String? validateVersion(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return serverErrors['version_number'] ?? tr.rlVersionRequired;
    if (text.length > 50) return tr.wfTooLong(50);
    return serverErrors['version_number'];
  }

  String? validateUrl(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return serverErrors['download_url'];
    final uri = Uri.tryParse(text);
    final ok =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return ok ? serverErrors['download_url'] : tr.wfUrlInvalid;
  }

  bool get isValid =>
      productId.value != null &&
      date.value != null &&
      validateVersion(version.text) == null &&
      validateUrl(downloadUrl.text) == null &&
      customersError == null;

  ReleasePayload buildPayload() => ReleasePayload(
    productId: productId.value!,
    versionNumber: version.text,
    releaseDate: date.value!,
    audience: audience.value,
    changelog: changelog.text,
    downloadUrl: downloadUrl.text,
    customerIds: customers.map((c) => c.id).toList(),
    isPublished: isPublished.value,
  );

  void _onProgress(int sent, int total) {
    if (total > 0) progress.value = sent / total;
  }

  Future<ProductRelease?> submit() async {
    if (isSubmitting.value) return null;
    showValidation.value = true;
    serverErrors.clear();
    errorMessage.value = null;
    final formValid = formKey.currentState?.validate() ?? true;
    if (!formValid || !isValid) {
      errorMessage.value = tr.validFixFields;
      return null;
    }
    isSubmitting.value = true;
    progress.value = null;
    try {
      final payload = buildPayload();
      final current = existing;
      if (current == null) {
        return await _repository.create(
          payload,
          installer: newInstaller.value,
          onProgress: _onProgress,
        );
      }
      var saved = await _repository.update(current.id, payload);
      final picked = newInstaller.value;
      if (picked != null) {
        saved = await _repository.uploadInstaller(
          current.id,
          picked,
          onProgress: _onProgress,
        );
      } else if (removeExistingInstaller.value) {
        saved = await _repository.removeInstaller(current.id);
      }
      return saved;
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k.split('.').first] = m.first;
      });
      errorMessage.value = e.describeFor(const {
        'product_id',
        'version_number',
        'release_date',
        'download_url',
        'customer_ids',
      });
      formKey.currentState?.validate();
      return null;
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return null;
    } finally {
      isSubmitting.value = false;
      progress.value = null;
    }
  }

  @override
  void onClose() {
    version.dispose();
    changelog.dispose();
    downloadUrl.dispose();
    super.onClose();
  }
}
