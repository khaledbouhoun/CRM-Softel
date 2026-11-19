import '../../../../core/network/api_response.dart';
import '../../../../core/utils/file_access.dart';
import '../../domain/releases_repository.dart';
import '../datasources/releases_remote_data_source.dart';
import '../models/product_release.dart';

class ReleasesRepositoryImpl implements ReleasesRepository {
  const ReleasesRepositoryImpl(this._remote);

  final ReleasesRemoteDataSource _remote;

  @override
  Future<Paginated<ProductRelease>> getReleases({
    int? productId,
    int page = 1,
    int perPage = 25,
  }) => _remote.fetch(productId: productId, page: page, perPage: perPage);

  @override
  Future<ProductRelease> create(
    ReleasePayload payload, {
    PickedFile? installer,
    void Function(int sent, int total)? onProgress,
  }) => installer == null
      ? _remote.create(payload)
      : _remote.createWithInstaller(payload, installer, onProgress: onProgress);

  @override
  Future<ProductRelease> update(int id, ReleasePayload payload) =>
      _remote.update(id, payload);

  @override
  Future<void> delete(int id) => _remote.delete(id);

  @override
  Future<ProductRelease> uploadInstaller(
    int id,
    PickedFile installer, {
    void Function(int sent, int total)? onProgress,
  }) => _remote.uploadInstaller(id, installer, onProgress: onProgress);

  @override
  Future<ProductRelease> removeInstaller(int id) => _remote.removeInstaller(id);

  @override
  Future<void> downloadInstaller(
    int id,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) => _remote.download(id, savePath, onProgress: onProgress);
}
