import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../products/presentation/widgets/product_selector.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../../prospects/presentation/dialogs/prospect_dialogs.dart';
import '../../../prospects/presentation/dialogs/prospect_search_dialog.dart';
import '../../../settings/data/models/sales_stage.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../controllers/pipeline_controller.dart';
import '../../../../app/l10n/l10n.dart';

class PipelinePage extends GetView<PipelineController> {
  const PipelinePage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.pipeline,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => PageHeader(
            title: tr.pipelineTitle,
            subtitle: controller.stagesState.isSuccess
                ? tr.pipelineCountSubtitle(controller.totalProspects)
                : tr.pipelineSubtitle,
            actions: [
              SearchField(
                initialValue: controller.search.value,
                hint: tr.pipelineFilterHint,
                width: 240,
                onChanged: controller.setSearch,
              ),
              Tooltip(
                message: tr.searchAllStagesNote,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Looks in every stage, not only in the visible column.
                    final found = await showProspectSearchDialog(
                      initialQuery: controller.search.value,
                    );
                    if (found != null) AppNavigation.openProspect(found.id);
                  },
                  icon: const Icon(Icons.travel_explore, size: 18),
                  label: Text(tr.searchProspectTitle),
                ),
              ),
              OutlinedButton.icon(
                onPressed: controller.stagesState.isLoading
                    ? null
                    : controller.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(tr.actionRefresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(
            () => LoadStateView(
              state: controller.stagesState,
              isEmpty: controller.columns.isEmpty,
              onRetry: controller.load,
              empty: EmptyView(
                icon: Icons.view_kanban_outlined,
                title: tr.noStagesConfigured,
                action: FilledButton(
                  onPressed: () => AppNavigation.goTo(Routes.stagesSettings),
                  child: Text(tr.configureStages),
                ),
              ),
              builder: (_) => _Board(controller),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Board extends StatefulWidget {
  const _Board(this.c);

  final PipelineController c;

  @override
  State<_Board> createState() => _BoardState();
}

class _BoardState extends State<_Board> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scrollbar(
    controller: _scroll,
    thumbVisibility: true,
    child: SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 20),
      child: Obx(
        () => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final column in widget.c.columns)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: _StageColumn(c: widget.c, column: column),
              ),
          ],
        ),
      ),
    ),
  );
}

class _StageColumn extends StatelessWidget {
  const _StageColumn({required this.c, required this.column});

  final PipelineController c;
  final PipelineColumn column;

  static const width = 290.0;

  Future<void> _move(Prospect prospect, SalesStage target) async {
    final fromStageId = prospect.stage?.id;
    // The dialog is the confirmation step and enforces the loss reason.
    final updated = await showStageChangeDialog(
      prospect,
      targetStageId: target.id,
    );
    if (updated == null) return;
    AppFeedback.success(
      tr.prospectMovedToStage(
        updated.companyName,
        updated.stage?.name ?? target.name,
      ),
    );
    await c.onMoved(fromStageId: fromStageId, updated: updated);
  }

  @override
  Widget build(BuildContext context) {
    final stage = column.stage;
    return DragTarget<Prospect>(
      onWillAcceptWithDetails: (details) => c.canDrop(details.data, stage),
      onAcceptWithDetails: (details) => _move(details.data, stage),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: MediaQuery.sizeOf(context).height - 210,
          decoration: BoxDecoration(
            color: hovering
                ? stage.color.withValues(alpha: 0.10)
                : context.colors.surfaceContainerHigh.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hovering ? stage.color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ColumnHeader(column),
              Expanded(
                child: Obx(() {
                  final state = column.state;
                  if (state.hasError && column.items.isEmpty) {
                    return ErrorView(
                      compact: true,
                      message: state.errorMessage.value ?? '',
                      onRetry: () => c.loadColumn(column),
                    );
                  }
                  if (state.isLoading && column.items.isEmpty) {
                    return const LoadingView();
                  }
                  if (column.items.isEmpty) {
                    return EmptyView(
                      compact: true,
                      icon: Icons.move_to_inbox_outlined,
                      title: stage.isActive
                          ? tr.dropCardHere
                          : tr.stageDeactivated,
                    );
                  }
                  return ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      10,
                      0,
                      10,
                      10,
                    ),
                    children: [
                      if (state.isLoading)
                        const LinearProgressIndicator(minHeight: 2),
                      for (final p in column.items)
                        _DraggableCard(c: c, prospect: p, onMove: _move),
                      if (column.hasMore.value)
                        TextButton(
                          onPressed: column.isLoadingMore.value
                              ? null
                              : () => c.loadMore(column),
                          child: Text(
                            column.isLoadingMore.value
                                ? tr.loading
                                : tr.showMoreCount(
                                    column.total.value - column.items.length,
                                  ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader(this.column);

  final PipelineColumn column;

  @override
  Widget build(BuildContext context) {
    final stage = column.stage;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: stage.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!stage.isOpen) ...[
                Icon(stageTypeIcon(stage.type), size: 16, color: stage.color),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  stage.name,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: stage.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${column.total.value}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color.lerp(
                        stage.color,
                        context.colors.onSurface,
                        0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!stage.isActive)
            Text(
              tr.stageDeactivated,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.outline,
              ),
            ),
        ],
      ),
    );
  }
}

class _DraggableCard extends StatelessWidget {
  const _DraggableCard({
    required this.c,
    required this.prospect,
    required this.onMove,
  });

  final PipelineController c;
  final Prospect prospect;
  final Future<void> Function(Prospect, SalesStage) onMove;

  @override
  Widget build(BuildContext context) {
    final card = _ProspectCard(c: c, prospect: prospect, onMove: onMove);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Draggable<Prospect>(
        data: prospect,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.translate(
            offset: const Offset(-40, -20),
            child: Opacity(
              opacity: 0.92,
              child: SizedBox(
                width: _StageColumn.width - 20,
                child: _ProspectCard(c: c, prospect: prospect, elevated: true),
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: card),
        child: MouseRegion(cursor: SystemMouseCursors.grab, child: card),
      ),
    );
  }
}

class _ProspectCard extends StatelessWidget {
  const _ProspectCard({
    required this.c,
    required this.prospect,
    this.onMove,
    this.elevated = false,
  });

  final PipelineController c;
  final Prospect prospect;
  final Future<void> Function(Prospect, SalesStage)? onMove;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final next = prospect.nextFollowUpAt;
    final overdue = prospect.isNextFollowUpOverdue();
    return Card(
      elevation: elevated ? 6 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await AppNavigation.openProspect(prospect.id);
          final column = c.columnFor(prospect.stage?.id);
          if (column != null) await c.loadColumn(column);
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prospect.companyName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall,
                        ),
                        if (prospect.contactName != null)
                          Text(
                            prospect.contactName!,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onMove != null)
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: PopupMenuButton<SalesStage>(
                        tooltip: tr.moveTo,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, size: 18),
                        onSelected: (stage) => onMove!(prospect, stage),
                        itemBuilder: (_) => [
                          for (final col in c.columns)
                            if (c.canDrop(prospect, col.stage))
                              PopupMenuItem(
                                value: col.stage,
                                child: Row(
                                  children: [
                                    StageDot(col.stage),
                                    const SizedBox(width: 8),
                                    Text(tr.moveToStage(col.stage.name)),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                ],
              ),
              if (prospect.products.isNotEmpty) ...[
                const SizedBox(height: 8),
                ProductChips(products: prospect.products, max: 3),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  if (next != null)
                    _Meta(
                      icon: overdue
                          ? Icons.warning_amber_rounded
                          : Icons.event_outlined,
                      text: overdue
                          ? tr.followUpOverdueTip
                          : Formatters.relative(next),
                      color: overdue ? crm.danger : crm.info,
                    ),
                  if (prospect.lastActivityAt != null)
                    _Meta(
                      icon: Icons.history,
                      text: Formatters.relative(prospect.lastActivityAt),
                      color: context.colors.onSurfaceVariant,
                    ),
                  if (prospect.isLost && prospect.lossReason != null)
                    _Meta(
                      icon: Icons.do_not_disturb_on_outlined,
                      text: prospect.lossReason!.label,
                      color: crm.danger,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 11.5, color: color)),
    ],
  );
}
