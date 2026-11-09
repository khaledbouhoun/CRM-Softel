import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/load_state.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../../prospects/data/models/prospect_filter.dart';
import '../../../prospects/domain/prospects_repository.dart';
import '../../../settings/data/models/sales_stage.dart';
import '../../../settings/domain/settings_repositories.dart';

/// One Kanban column: a stage and its prospects (server-paginated).
class PipelineColumn {
  PipelineColumn(this.stage);

  final SalesStage stage;
  final items = <Prospect>[].obs;
  final total = 0.obs;
  final state = LoadState();
  final hasMore = false.obs;
  final isLoadingMore = false.obs;
  int page = 1;
  int requestId = 0;
}

/// Prospects grouped by stage. Moves are applied only after the API
/// confirmed the stage transition.
class PipelineController extends GetxController {
  PipelineController({
    required ProspectsRepository prospectsRepository,
    required SalesStagesRepository stagesRepository,
  }) : _prospects = prospectsRepository,
       _stages = stagesRepository;

  static const pageSize = 30;

  final ProspectsRepository _prospects;
  final SalesStagesRepository _stages;

  final columns = <PipelineColumn>[].obs;
  final stagesState = LoadState();
  final search = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  PipelineColumn? columnFor(int? stageId) =>
      columns.firstWhereOrNull((c) => c.stage.id == stageId);

  Future<void> load() async {
    final ok = await stagesState.run(() async {
      final stages = await _stages.getStages(includeInactive: true);
      // Inactive stages are shown only while prospects remain in them.
      columns.assignAll(
        stages
            .where((s) => s.isActive || (s.prospectsCount ?? 1) > 0)
            .map(PipelineColumn.new),
      );
    });
    if (ok) await Future.wait(columns.map((c) => loadColumn(c)));
  }

  Future<void> loadColumn(PipelineColumn column) async {
    final requestId = ++column.requestId;
    column.state.loading();
    try {
      final result = await _prospects.getProspects(
        ProspectFilter(
          stageId: column.stage.id,
          search: search.value,
          perPage: pageSize,
          // Most recently touched first (the API cannot sort by last activity).
          sort: ProspectSort.updatedAt,
          ascending: false,
        ),
      );
      if (requestId != column.requestId) return;
      column.page = 1;
      column.items.assignAll(result.items);
      column.total.value = result.total;
      column.hasMore.value = result.hasNext;
      column.state.success();
    } catch (e) {
      if (requestId != column.requestId) return;
      column.state.error(ApiException.from(e));
    }
  }

  Future<void> loadMore(PipelineColumn column) async {
    if (column.isLoadingMore.value || !column.hasMore.value) return;
    column.isLoadingMore.value = true;
    try {
      final result = await _prospects.getProspects(
        ProspectFilter(
          stageId: column.stage.id,
          search: search.value,
          perPage: pageSize,
          page: column.page + 1,
          sort: ProspectSort.updatedAt,
          ascending: false,
        ),
      );
      column.page = result.currentPage;
      final known = column.items.map((p) => p.id).toSet();
      column.items.addAll(result.items.where((p) => !known.contains(p.id)));
      column.total.value = result.total;
      column.hasMore.value = result.hasNext;
    } catch (e) {
      column.state.error(ApiException.from(e));
    } finally {
      column.isLoadingMore.value = false;
    }
  }

  void setSearch(String query) {
    if (query.trim() == search.value.trim()) return;
    search.value = query;
    for (final c in columns) {
      loadColumn(c);
    }
  }

  /// Whether [prospect] may be dropped on [target] (the dialog still asks
  /// for confirmation / loss reason).
  bool canDrop(Prospect prospect, SalesStage target) =>
      target.isActive && prospect.stage?.id != target.id;

  /// Called with the prospect returned by the API after a confirmed move.
  Future<void> onMoved({
    required int? fromStageId,
    required Prospect updated,
  }) async {
    final from = columnFor(fromStageId);
    final to = columnFor(updated.stage?.id);
    await Future.wait([
      if (from != null) loadColumn(from),
      if (to != null && to != from) loadColumn(to),
    ]);
  }

  int get totalProspects => columns.fold(0, (sum, c) => sum + c.total.value);
}
