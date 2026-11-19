import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/file_access.dart';
import '../models/product_release.dart';

class ReleasesRemoteDataSource {
  const ReleasesRemoteDataSource(this._api);

  final ApiClient _api;

  /// Installers weigh up to 1 GB: give uploads and downloads plenty of time.
  static const transferTimeout = Duration(hours: 2);

  Future<Paginated<ProductRelease>> fetch({
    int? productId,
    int page = 1,
    int perPage = 25,
  }) async => ApiResponse.paginated(
    await _api.get(
      ApiEndpoints.productReleases,
      query: {'product_id': productId, 'page': page, 'per_page': perPage},
    ),
    ProductRelease.fromJson,
  );

  Future<ProductRelease> create(ReleasePayload payload) async =>
      ProductRelease.fromJson(
        ApiResponse.object(
          await _api.post(ApiEndpoints.productReleases, data: payload.toJson()),
        ),
      );

  Future<ProductRelease> createWithInstaller(
    ReleasePayload payload,
    PickedFile installer, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final form = FormData();
    form.fields.addAll(payload.toFormFields());
    form.files.add(
      MapEntry(
        'installer',
        await MultipartFile.fromFile(installer.path, filename: installer.name),
      ),
    );
    return ProductRelease.fromJson(
      ApiResponse.object(
        await _api.postForm(
          ApiEndpoints.productReleases,
          data: form,
          timeout: transferTimeout,
          onProgress: onProgress,
        ),
      ),
    );
  }

  Future<ProductRelease> update(int id, ReleasePayload payload) async =>
      ProductRelease.fromJson(
        ApiResponse.object(
          await _api.put(ApiEndpoints.productRelease(id), data: payload.toJson()),
        ),
      );

  Future<void> delete(int id) async {
    await _api.delete(ApiEndpoints.productRelease(id));
  }

  Future<ProductRelease> uploadInstaller(
    int id,
    PickedFile installer, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final form = FormData();
    form.files.add(
      MapEntry(
        'installer',
        await MultipartFile.fromFile(installer.path, filename: installer.name),
      ),
    );
    return ProductRelease.fromJson(
      ApiResponse.object(
        await _api.postForm(
          ApiEndpoints.productReleaseInstaller(id),
          data: form,
          timeout: transferTimeout,
          onProgress: onProgress,
        ),
      ),
    );
  }

  Future<ProductRelease> removeInstaller(int id) async =>
      ProductRelease.fromJson(
        ApiResponse.object(
          await _api.delete(ApiEndpoints.productReleaseInstaller(id)),
        ),
      );

  Future<void> download(
    int id,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) => _api.downloadTo(
    ApiEndpoints.productReleaseDownload(id),
    savePath,
    onProgress: onProgress,
    timeout: transferTimeout,
  );
}
