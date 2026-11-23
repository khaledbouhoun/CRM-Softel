import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/analytics_models.dart';

class AnalyticsRemoteDataSource {
  const AnalyticsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<AnalyticsData> fetch(String range) async {
    final body = await _api.get(
      ApiEndpoints.analytics,
      query: {'range': range},
    );
    return AnalyticsData.fromJson(ApiResponse.object(body));
  }
}
