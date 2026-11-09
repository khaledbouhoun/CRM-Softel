import '../data/models/loss_reason.dart';
import '../data/models/sales_stage.dart';

/// Sales pipeline stages. Results are always ordered by `position`.
abstract interface class SalesStagesRepository {
  Future<List<SalesStage>> getStages({bool includeInactive = false});
  Future<SalesStage> createStage(SalesStagePayload payload);
  Future<SalesStage> updateStage(int id, SalesStagePayload payload);
  Future<SalesStage> setStageActive(int id, bool isActive);
  Future<List<SalesStage>> reorderStages(List<int> orderedIds);

  /// Only allowed by the backend for stages that were never used.
  Future<void> deleteStage(int id);
}

/// Loss reasons. Results are always ordered by `position`.
abstract interface class LossReasonsRepository {
  Future<List<LossReason>> getLossReasons({bool includeInactive = false});
  Future<LossReason> createLossReason(LossReasonPayload payload);
  Future<LossReason> updateLossReason(int id, LossReasonPayload payload);
  Future<LossReason> setLossReasonActive(int id, bool isActive);
  Future<List<LossReason>> reorderLossReasons(List<int> orderedIds);
}
