import '../../../../core/utils/file_access.dart';
import '../data/models/pack.dart';
import '../data/models/product.dart';

abstract interface class ProductsRepository {
  /// Uploads an installer / demo file to the server and returns its public URL.
  Future<String> uploadDemoFile(
    PickedFile file, {
    int? productId,
    void Function(int sent, int total)? onProgress,
  });
  /// Products sorted by name.
  ///
  /// [prospectId] keeps only the products linked to that prospect/customer
  /// ([relation]: `linked` (default), `interested` or `owned`); [hasDemo]
  /// keeps only products with a fixed demo link.
  Future<List<Product>> getProducts({
    bool includeInactive = false,
    String? search,
    int? prospectId,
    String relation = 'linked',
    bool hasDemo = false,
  });
  Future<Product> createProduct(ProductPayload payload);
  Future<Product> updateProduct(int id, ProductPayload payload);
  Future<Product> setProductActive(int id, bool isActive);

  /// Packs management
  Future<List<Pack>> getPacks();
  Future<Pack> createPack(PackPayload payload);
  Future<Pack> updatePack(int id, PackPayload payload);
  Future<void> deletePack(int id);
}
