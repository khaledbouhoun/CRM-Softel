import '../../domain/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';
import '../models/analytics_models.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._remote);

  final AnalyticsRemoteDataSource _remote;

  @override
  Future<AnalyticsData> getAnalytics({String range = 'month'}) =>
      _remote.fetch(range);
}
