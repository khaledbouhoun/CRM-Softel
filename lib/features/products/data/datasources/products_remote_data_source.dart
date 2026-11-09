import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/product.dart';

class ProductsRemoteDataSource {
  const ProductsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<Product>> fetchAll({
    bool includeInactive = false,
    String? search,
  }) async {
    final body = await _api.get(
      ApiEndpoints.products,
      query: {
        // The API lists every product unless filtered on is_active.
        'is_active': includeInactive ? null : 1,
        'search': search,
      },
    );
    return ApiResponse.list(body, Product.fromJson);
  }

  Future<Product> create(ProductPayload payload) async {
    final body = await _api.post(ApiEndpoints.products, data: payload.toJson());
    return Product.fromJson(ApiResponse.object(body));
  }

  Future<Product> update(int id, ProductPayload payload) async {
    final body = await _api.put(
      ApiEndpoints.product(id),
      data: payload.toJson(),
    );
    return Product.fromJson(ApiResponse.object(body));
  }

  Future<Product> setActive(int id, bool isActive) async {
    final body = await _api.patch(
      ApiEndpoints.product(id),
      data: {'is_active': isActive},
    );
    return Product.fromJson(ApiResponse.object(body));
  }
}
