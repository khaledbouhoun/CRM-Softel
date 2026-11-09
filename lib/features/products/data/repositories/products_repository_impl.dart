import '../../domain/products_repository.dart';
import '../datasources/products_remote_data_source.dart';
import '../models/product.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<List<Product>> getProducts({
    bool includeInactive = false,
    String? search,
  }) async {
    final products = await _remote.fetchAll(
      includeInactive: includeInactive,
      search: search,
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
}
