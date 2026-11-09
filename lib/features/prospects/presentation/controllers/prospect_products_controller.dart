import 'package:get/get.dart';

import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/load_state.dart';
import '../../data/models/prospect.dart';
import '../../domain/prospects_repository.dart';

/// Edits only the products a prospect is interested in
/// (PUT /prospects/{id}/products).
class ProspectProductsController extends GetxController {
  ProspectProductsController({
    required ProspectsRepository repository,
    required this.lookups,
    required this.prospect,
  }) : _repository = repository;

  final ProspectsRepository _repository;
  final LookupService lookups;
  final Prospect prospect;

  final selectedIds = <int>{}.obs;
  final lookupState = LoadState();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  bool get hasChanges {
    final original = prospect.products.map((p) => p.id).toSet();
    return original.length != selectedIds.length ||
        !original.containsAll(selectedIds);
  }

  @override
  void onInit() {
    super.onInit();
    selectedIds.addAll(prospect.products.map((p) => p.id));
    lookupState.run(lookups.refreshProducts);
  }

  void toggle(int productId, bool selected) {
    if (selected) {
      selectedIds.add(productId);
    } else {
      selectedIds.remove(productId);
    }
    errorMessage.value = null;
  }

  Future<Prospect?> submit() async {
    if (isSubmitting.value) return null;
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      return await _repository.updateProducts(
        prospect.id,
        selectedIds.toList(),
      );
    } on ValidationException catch (e) {
      errorMessage.value = [e.message, ...e.allMessages].join('\n');
      return null;
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}
