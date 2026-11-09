import '../../../../core/network/api_response.dart';
import '../../domain/prospects_repository.dart';
import '../datasources/prospects_remote_data_source.dart';
import '../models/prospect.dart';
import '../models/prospect_filter.dart';
import '../models/prospect_requests.dart';
import '../models/stage_history_entry.dart';

class ProspectsRepositoryImpl implements ProspectsRepository {
  const ProspectsRepositoryImpl(this._remote);

  final ProspectsRemoteDataSource _remote;

  @override
  Future<Paginated<Prospect>> getProspects(ProspectFilter filter) =>
      _remote.fetchPage(filter);

  @override
  Future<Prospect> getProspect(int id) => _remote.fetch(id);

  @override
  Future<Prospect> createProspect(ProspectPayload payload) =>
      _remote.create(payload);

  @override
  Future<Prospect> updateProspect(int id, ProspectPayload payload) =>
      _remote.update(id, payload);

  @override
  Future<Prospect> updateProducts(int id, List<int> productIds) =>
      _remote.syncProducts(id, productIds.toSet().toList()..sort());

  @override
  Future<Prospect> changeStage(int id, StageTransitionRequest request) =>
      _remote.changeStage(id, request);

  @override
  Future<List<StageHistoryEntry>> getStageHistory(int id) async {
    final entries = await _remote.fetchStageHistory(id);
    // Newest first regardless of server ordering.
    return [...entries]..sort((a, b) {
      final ad = a.changedAt, bd = b.changedAt;
      if (ad == null || bd == null) return b.id.compareTo(a.id);
      return bd.compareTo(ad);
    });
  }
}
