import '../../../core/network/api_response.dart';
import '../data/models/prospect.dart';
import '../data/models/prospect_filter.dart';
import '../data/models/prospect_requests.dart';
import '../data/models/stage_history_entry.dart';

abstract interface class ProspectsRepository {
  Future<Paginated<Prospect>> getProspects(ProspectFilter filter);
  Future<Prospect> getProspect(int id);
  Future<Prospect> createProspect(ProspectPayload payload);

  /// Updates the prospect's information (never its stage).
  Future<Prospect> updateProspect(int id, ProspectPayload payload);

  /// Replaces the prospect's interested products.
  Future<Prospect> updateProducts(int id, List<int> productIds);

  /// Moves the prospect to another stage; the backend records the history.
  Future<Prospect> changeStage(int id, StageTransitionRequest request);

  /// Stage history, newest first.
  Future<List<StageHistoryEntry>> getStageHistory(int id);
}
