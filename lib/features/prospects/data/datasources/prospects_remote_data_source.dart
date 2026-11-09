import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_utils.dart';
import '../models/prospect.dart';
import '../models/prospect_filter.dart';
import '../models/prospect_requests.dart';
import '../models/stage_history_entry.dart';
import '../../../../app/l10n/l10n.dart';

class ProspectsRemoteDataSource {
  const ProspectsRemoteDataSource(this._api);

  final ApiClient _api;

  /// Stage history is short; one page of the API maximum covers it.
  static const _historyPageSize = 100;

  Future<Paginated<Prospect>> fetchPage(ProspectFilter filter) async {
    final body = await _api.get(
      ApiEndpoints.prospects,
      query: filter.toQuery(),
    );
    return ApiResponse.paginated(body, Prospect.fromJson);
  }

  Future<Prospect> fetch(int id) async {
    final body = await _api.get(ApiEndpoints.prospect(id));
    return Prospect.fromJson(ApiResponse.object(body));
  }

  Future<Prospect> create(ProspectPayload payload) async {
    final body = await _api.post(
      ApiEndpoints.prospects,
      data: payload.toJson(isCreate: true),
    );
    return Prospect.fromJson(ApiResponse.object(body));
  }

  Future<Prospect> update(int id, ProspectPayload payload) async {
    final body = await _api.put(
      ApiEndpoints.prospect(id),
      data: payload.toJson(isCreate: false),
    );
    return Prospect.fromJson(ApiResponse.object(body));
  }

  /// Partial PUT: only `product_ids` changes.
  Future<Prospect> syncProducts(int id, List<int> productIds) async {
    final body = await _api.put(
      ApiEndpoints.prospect(id),
      data: {'product_ids': productIds},
    );
    return Prospect.fromJson(ApiResponse.object(body));
  }

  /// The API answers `{ prospect, stage_history }`; the updated prospect is
  /// returned.
  Future<Prospect> changeStage(int id, StageTransitionRequest request) async {
    final body = await _api.post(
      ApiEndpoints.prospectChangeStage(id),
      data: request.toJson(),
    );
    final prospect = asMapOrNull(ApiResponse.object(body)['prospect']);
    if (prospect == null) {
      throw UnexpectedResponseException(tr.errMissingProspect);
    }
    return Prospect.fromJson(prospect);
  }

  Future<List<StageHistoryEntry>> fetchStageHistory(int id) async {
    final body = await _api.get(
      ApiEndpoints.prospectStageHistory(id),
      query: {'per_page': _historyPageSize},
    );
    return ApiResponse.list(body, StageHistoryEntry.fromJson);
  }
}
