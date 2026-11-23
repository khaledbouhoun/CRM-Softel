import '../../../../core/utils/file_access.dart';
import '../../domain/products_repository.dart';
import '../datasources/products_remote_data_source.dart';
import '../models/pack.dart';
import '../models/product.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<String> uploadDemoFile(
    PickedFile file, {
    int? productId,
    void Function(int sent, int total)? onProgress,
  }) => _remote.uploadDemoFile(file, productId: productId, onProgress: onProgress);

  @override
  Future<String> uploadProductImage(
    PickedFile file, {
    int? productId,
    void Function(int sent, int total)? onProgress,
  }) => _remote.uploadImage(file, productId: productId, onProgress: onProgress);

  @override
  Future<List<Product>> getProducts({
    bool includeInactive = false,
    String? search,
    int? prospectId,
    String relation = 'linked',
    bool hasDemo = false,
  }) async {
    final products = await _remote.fetchAll(
      includeInactive: includeInactive,
      search: search,
      prospectId: prospectId,
      relation: relation,
      hasDemo: hasDemo,
    );
    return [...products]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<Product> createProduct(ProductPayload payload) =>
      _remote.create(payload);

  @override
  Future<Product> updateProduct(int id, ProductPayload payload) =>
      _remote.update(id, payload);

  @override
  Future<Product> setProductActive(int id, bool isActive) =>
      _remote.setActive(id, isActive);

  @override
  Future<List<Pack>> getPacks() => _remote.fetchPacks();

  @override
  Future<Pack> createPack(PackPayload payload) => _remote.createPack(payload);

  @override
  Future<Pack> updatePack(int id, PackPayload payload) =>
      _remote.updatePack(id, payload);

  @override
  Future<void> deletePack(int id) => _remote.deletePack(id);
}
