import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/dashboard_summary.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._api);

  final ApiClient _api;

  Future<DashboardSummary> fetchSummary() async {
    final body = await _api.get(ApiEndpoints.dashboard);
    return DashboardSummary.fromJson(ApiResponse.object(body));
  }
}
