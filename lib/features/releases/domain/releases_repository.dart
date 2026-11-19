import '../../../core/network/api_response.dart';
import '../../../core/utils/file_access.dart';
import '../data/models/product_release.dart';

/// Product releases (the "updates" module): versions, changelog, audience and
/// the installer binary.
abstract interface class ReleasesRepository {
  Future<Paginated<ProductRelease>> getReleases({
    int? productId,
    int page = 1,
    int perPage = 25,
  });

  /// Creates a release; the optional [installer] is sent in the same
  /// multipart request. [onProgress] reports the upload.
  Future<ProductRelease> create(
    ReleasePayload payload, {
    PickedFile? installer,
    void Function(int sent, int total)? onProgress,
  });

  Future<ProductRelease> update(int id, ReleasePayload payload);
  Future<void> delete(int id);

  /// Replaces the installer of an existing release.
  Future<ProductRelease> uploadInstaller(
    int id,
    PickedFile installer, {
    void Function(int sent, int total)? onProgress,
  });

  Future<ProductRelease> removeInstaller(int id);

  /// Streams the installer to [savePath] (installers can be very large).
  Future<void> downloadInstaller(
    int id,
    String savePath, {
    void Function(int received, int total)? onProgress,
  });
}
