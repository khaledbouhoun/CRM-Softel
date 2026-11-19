import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/file_access.dart';
import '../models/intervention.dart';

class InterventionsRemoteDataSource {
  const InterventionsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Intervention>> getInterventions(
    InterventionFilter filter,
  ) async => ApiResponse.paginated(
    await _api.get(ApiEndpoints.interventions, query: filter.toQuery()),
    Intervention.fromJson,
  );

  Future<Intervention> getIntervention(int id) async => Intervention.fromJson(
    ApiResponse.object(await _api.get(ApiEndpoints.intervention(id))),
  );

  Future<Intervention> create(InterventionPayload payload) async =>
      Intervention.fromJson(
        ApiResponse.object(
          await _api.post(ApiEndpoints.interventions, data: payload.toJson()),
        ),
      );

  Future<Intervention> update(int id, Map<String, dynamic> changes) async =>
      Intervention.fromJson(
        ApiResponse.object(
          await _api.patch(ApiEndpoints.intervention(id), data: changes),
        ),
      );

  Future<List<AllowedTransition>> getTransitions(int id) async =>
      ApiResponse.list(
        await _api.get(ApiEndpoints.interventionAction(id, 'transitions')),
        AllowedTransition.fromJson,
      );

  /// Reply with attachments: multipart, `files[]` as Laravel expects.
  Future<Intervention> postMessageWithFiles(
    int id, {
    required String visibility,
    required String body,
    required List<PickedFile> files,
  }) async {
    final form = FormData();
    form.fields.add(MapEntry('visibility', visibility));
    if (body.isNotEmpty) form.fields.add(MapEntry('body', body));
    for (final file in files) {
      form.files.add(
        MapEntry(
          'files[]',
          await MultipartFile.fromFile(file.path, filename: file.name),
        ),
      );
    }
    return Intervention.fromJson(
      ApiResponse.object(
        await _api.postForm(
          ApiEndpoints.interventionAction(id, 'messages'),
          data: form,
          // 5 files up to 100 MB each.
          timeout: const Duration(minutes: 30),
        ),
      ),
    );
  }

  Future<Uint8List> preview(int id, int attachmentId) => _api.getBytes(
    ApiEndpoints.interventionAttachmentPreview(id, attachmentId),
    timeout: const Duration(minutes: 5),
  );

  Future<void> download(
    int id,
    int attachmentId,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) => _api.downloadTo(
    ApiEndpoints.interventionAttachment(id, attachmentId),
    savePath,
    onProgress: onProgress,
    timeout: const Duration(minutes: 30),
  );

  Future<Intervention> post(
    int id,
    String action,
    Map<String, dynamic> data,
  ) async => Intervention.fromJson(
    ApiResponse.object(
      await _api.post(ApiEndpoints.interventionAction(id, action), data: data),
    ),
  );
}
