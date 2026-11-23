import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/file_access.dart';
import '../models/pack.dart';
import '../models/product.dart';

class ProductsRemoteDataSource {
  const ProductsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<String> uploadDemoFile(
    PickedFile file, {
    int? productId,
    void Function(int sent, int total)? onProgress,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.name),
      if (productId != null) 'product_id': productId.toString(),
    });
    final body = await _api.postForm(
      ApiEndpoints.uploadProductDemo,
      data: form,
      timeout: const Duration(hours: 2),
      onProgress: onProgress,
    );
    final data = ApiResponse.object(body);
    return data['url'] as String;
  }

  Future<String> uploadImage(
    PickedFile file, {
    int? productId,
    void Function(int sent, int total)? onProgress,
  }) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path, filename: file.name),
      if (productId != null) 'product_id': productId.toString(),
    });
    final body = await _api.postForm(
      ApiEndpoints.uploadProductImage,
      data: form,
      timeout: const Duration(minutes: 2),
      onProgress: onProgress,
    );
    final data = ApiResponse.object(body);
    return data['url'] as String;
  }

  Future<List<Product>> fetchAll({
    bool includeInactive = false,
    String? search,
    int? prospectId,
    String relation = 'linked',
    bool hasDemo = false,
  }) async {
    final body = await _api.get(
      ApiEndpoints.products,
      query: {
        // The API lists every product unless filtered on is_active.
        'is_active': includeInactive ? null : 1,
        'search': search,
        'prospect_id': ?prospectId,
        if (prospectId != null) 'relation': relation,
        if (hasDemo) 'has_demo': 1,
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

  Future<List<Pack>> fetchPacks() async {
    final body = await _api.get(ApiEndpoints.packs);
    return ApiResponse.list(body, Pack.fromJson);
  }

  Future<Pack> createPack(PackPayload payload) async {
    final body = await _api.post(ApiEndpoints.packs, data: payload.toJson());
    return Pack.fromJson(ApiResponse.object(body));
  }

  Future<Pack> updatePack(int id, PackPayload payload) async {
    final body = await _api.put(ApiEndpoints.pack(id), data: payload.toJson());
    return Pack.fromJson(ApiResponse.object(body));
  }

  Future<void> deletePack(int id) async {
    await _api.delete(ApiEndpoints.pack(id));
  }
}
