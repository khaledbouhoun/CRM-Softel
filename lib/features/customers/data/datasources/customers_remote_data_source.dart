import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../prospects/data/models/prospect.dart';
import '../models/customer_models.dart';

class CustomersRemoteDataSource {
  const CustomersRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Paginated<Prospect>> getCustomers({
    String search = '',
    int page = 1,
    int perPage = 25,
    int? productId,
    CustomerMaintenanceFilter maintenance = CustomerMaintenanceFilter.all,
    CustomerPortalFilter portal = CustomerPortalFilter.all,
    CustomerSort sort = CustomerSort.convertedAt,
    bool ascending = false,
  }) async {
    final body = await _api.get(
      ApiEndpoints.customers,
      query: {
        'search': search.trim(),
        'page': page,
        'per_page': perPage,
        'product_id': ?productId,
        'maintenance': ?maintenance.apiValue,
        'portal': ?portal.apiValue,
        'sort': sort.apiValue,
        'direction': ascending ? 'asc' : 'desc',
      },
    );
    return ApiResponse.paginated(body, Prospect.fromJson);
  }

  Future<CustomerProfile> getCustomer(int id) async => CustomerProfile.fromJson(
    ApiResponse.object(await _api.get(ApiEndpoints.customer(id))),
  );

  Future<Prospect> convert(int prospectId, ConvertPayload payload) async {
    final body = await _api.post(
      ApiEndpoints.prospectConvert(prospectId),
      data: payload.toJson(),
    );
    return Prospect.fromJson(ApiResponse.object(body));
  }

  Future<List<Trial>> getTrials(int prospectId) async => ApiResponse.list(
    await _api.get(ApiEndpoints.prospectTrials(prospectId)),
    Trial.fromJson,
  );

  Future<Trial> activateTrial(int prospectId, TrialPayload payload) async {
    final body = await _api.post(
      ApiEndpoints.prospectTrials(prospectId),
      data: payload.toJson(),
    );
    final map = asMapOrNull(body);
    if (map != null && map['data'] is List) {
      final list = asList(map['data'], Trial.fromJson);
      return list.first;
    }
    return Trial.fromJson(ApiResponse.object(body));
  }

  Future<Trial> revokeTrial(int trialId) async => Trial.fromJson(
    ApiResponse.object(
      await _api.post(
        ApiEndpoints.trialRevoke(trialId),
        data: const <String, dynamic>{},
      ),
    ),
  );
}
