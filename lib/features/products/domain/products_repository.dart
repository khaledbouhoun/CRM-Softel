import '../data/models/product.dart';

abstract interface class ProductsRepository {
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
}
