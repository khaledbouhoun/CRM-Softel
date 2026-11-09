import '../../domain/settings_repositories.dart';
import '../datasources/loss_reasons_remote_data_source.dart';
import '../datasources/sales_stages_remote_data_source.dart';
import '../models/loss_reason.dart';
import '../models/sales_stage.dart';

class SalesStagesRepositoryImpl implements SalesStagesRepository {
  const SalesStagesRepositoryImpl(this._remote);

  final SalesStagesRemoteDataSource _remote;

  static List<SalesStage> _sorted(List<SalesStage> stages) =>
      [...stages]..sort((a, b) => a.position.compareTo(b.position));

  @override
  Future<List<SalesStage>> getStages({bool includeInactive = false}) async =>
      _sorted(await _remote.fetchAll(includeInactive: includeInactive));

  @override
  Future<SalesStage> createStage(SalesStagePayload payload) =>
      _remote.create(payload);

  @override
  Future<SalesStage> updateStage(int id, SalesStagePayload payload) =>
      _remote.update(id, payload);

  @override
  Future<SalesStage> setStageActive(int id, bool isActive) =>
      _remote.setActive(id, isActive);

  @override
  Future<List<SalesStage>> reorderStages(List<int> orderedIds) async =>
      _sorted(await _remote.reorder(orderedIds));

  @override
  Future<void> deleteStage(int id) => _remote.delete(id);
}

class LossReasonsRepositoryImpl implements LossReasonsRepository {
  const LossReasonsRepositoryImpl(this._remote);

  final LossReasonsRemoteDataSource _remote;

  static List<LossReason> _sorted(List<LossReason> reasons) =>
      [...reasons]..sort((a, b) => a.position.compareTo(b.position));

  @override
  Future<List<LossReason>> getLossReasons({
    bool includeInactive = false,
  }) async => _sorted(await _remote.fetchAll(includeInactive: includeInactive));

  @override
  Future<LossReason> createLossReason(LossReasonPayload payload) =>
      _remote.create(payload);

  @override
  Future<LossReason> updateLossReason(int id, LossReasonPayload payload) =>
      _remote.update(id, payload);

  @override
  Future<LossReason> setLossReasonActive(int id, bool isActive) =>
      _remote.setActive(id, isActive);

  @override
  Future<List<LossReason>> reorderLossReasons(List<int> orderedIds) async =>
      _sorted(await _remote.reorder(orderedIds));
}
