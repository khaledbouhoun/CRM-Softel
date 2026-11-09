import '../data/models/product.dart';

abstract interface class ProductsRepository {
  /// Products sorted by name.
  Future<List<Product>> getProducts({
    bool includeInactive = false,
    String? search,
  });
  Future<Product> createProduct(ProductPayload payload);
  Future<Product> updateProduct(int id, ProductPayload payload);
  Future<Product> setProductActive(int id, bool isActive);
}
