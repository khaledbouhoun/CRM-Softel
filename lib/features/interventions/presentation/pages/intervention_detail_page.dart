import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/workflow_lookup_service.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/navigation.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../../workflow_settings/data/models/config_models.dart';
import '../../data/models/intervention.dart';
import '../controllers/interventions_controllers.dart';
import '../dialogs/intervention_dialogs.dart';
import '../widgets/chat_widgets.dart';

/// Route `/after-sales/:id`.
class InterventionDetailPage extends StatefulWidget {
  const InterventionDetailPage({super.key});

  @override
  State<InterventionDetailPage> createState() => _InterventionDetailPageState();
}

class _InterventionDetailPageState extends State<InterventionDetailPage> {
  late final int? _id = int.tryParse(Get.parameters['id'] ?? '');
  InterventionDetailController? _controller;

  @override
  void initState() {
    super.initState();
    if (_id != null) {
      final workflow = Get.find<WorkflowLookupService>()..refreshQuietly();
      _controller = Get.put(
        InterventionDetailController(
          interventionId: _id,
          repository: Get.find(),
          workflow: workflow,
        ),
        tag: 'intervention-$_id',
      );
    }
  }

  @override
  void dispose() {
    if (_id != null) {
      Get.delete<InterventionDetailController>(tag: 'intervention-$_id');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
    route: Routes.afterSales,
    child: _controller == null
        ? ErrorView(message: tr.wfInvalidId)
        : _Body(_controller!),
  );
}

void _report(ActionResult<Intervention> result, String successMessage) {
  if (result.isSuccess) {
    AppFeedback.success(successMessage);
  } else {
    AppFeedback.error(result.error!);
  }
}

/// Employees reopen a closed intervention from the options menu: replies are
/// enabled again for both sides and the timeline records who reopened it.
Future<void> _reopen(InterventionDetailController c) async {
  final note = await showReopenDialog();
  if (note == null) return;
  _report(await c.reopen(note: note), tr.ivReopened);
}

class _Body extends StatelessWidget {
  const _Body(this.c);

  final InterventionDetailController c;

  @override
  Widget build(BuildContext context) => Obx(() {
    final i = c.intervention.value;
    if (i == null) {
      return c.state.hasError
          ? ErrorView(
              message: c.state.errorMessage.value ?? '',
              isConnectionError: c.state.isConnectionError,
              onRetry: c.load,
            )
          : LoadingView(message: tr.loadingRecord);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          leading: IconButton(
            tooltip: tr.actionBack,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: '${i.reference} · ${i.title}',
          subtitle: joinNonEmpty([
            i.type?.name,
            i.isFromCustomer ? tr.wfSourceCustomer : tr.wfSourceEmployee,
            Formatters.dateTime(i.createdAt),
          ]),
          actions: [
            IconButton(
              tooltip: tr.actionRefresh,
              onPressed: c.load,
              icon: const Icon(Icons.refresh),
            ),
            InterventionStatusBadge(status: i.status),
            PriorityChip(priority: i.priority),
            if (c.canReopen)
              PopupMenuButton<String>(
                enabled: !c.isBusy.value,
                icon: const Icon(Icons.more_vert),
                onSelected: (_) => _reopen(c),
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    value: 'reopen',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lock_open_outlined),
                      title: Text(tr.ivReopen),
                    ),
                  ),
                ],
              ),
          ],
        ),
        RefreshingBar(visible: c.state.isLoading || c.isBusy.value),
        if (c.state.hasError)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 8),
            child: ErrorBanner(
              message: tr.dataMaybeStale(c.state.errorMessage.value ?? ''),
              onRetry: c.load,
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final left = [
                _DetailsCard(i),
                _StatusCard(c: c, i: i),
                _TriageCard(c: c, i: i),
                _PublishCard(c: c, i: i),
              ];
              final right = [_ConversationCard(c: c, i: i)];
              Widget col(List<Widget> items) => Column(
                children: [
                  for (var k = 0; k < items.length; k++) ...[
                    if (k > 0) const SizedBox(height: 16),
                    items[k],
                  ],
                ],
              );
              if (constraints.maxWidth < 1050) {
                return ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(28, 4, 28, 28),
                  children: [
                    col([...left, ...right]),
                  ],
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 4, 28, 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: col(left)),
                    const SizedBox(width: 18),
                    Expanded(flex: 6, child: col(right)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  });
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard(this.i);

  final Intervention i;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.sectionInformation,
    icon: Icons.info_outline,
    child: Column(
      children: [
        InfoRow(
          label: tr.fieldCompany,
          child: i.prospect == null
              ? Text('—', style: context.text.bodyMedium)
              : TextButton(
                  onPressed: () => AppNavigation.openProspect(i.prospect!.id),
                  child: Text(i.prospect!.name),
                ),
        ),
        InfoRow(label: tr.fieldProduct, value: i.product?.name),
        if (i.customers.isNotEmpty)
          InfoRow(
            label: tr.wfAffectedCustomers,
            value: i.customers.map((c) => c.name).join(', '),
          ),
        InfoRow(label: tr.fieldDescription, value: i.description),
        if (i.closedAt != null)
          InfoRow(label: tr.wfClosedAt, value: Formatters.dateTime(i.closedAt)),
      ],
    ),
  );
}

/// Status workflow: the picker only offers the transitions configured for
/// the current status (`GET .../transitions`).
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.c, required this.i});

  final InterventionDetailController c;
  final Intervention i;

  Future<void> _change(InterventionStatus status) async {
    final text = await showStatusChangeDialog(
      statusName: status.name,
      customerLabel: status.customerLabel,
    );
    if (text == null) return;
    _report(
      await c.changeStatus(status.id, customerMessage: text),
      tr.wfStatusChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = c.allowedStatuses;
    return SectionCard(
      title: tr.wfStatusWorkflow,
      subtitle: tr.wfStatusWorkflowHint,
      icon: Icons.account_tree_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            label: tr.wfCurrentStatus,
            child: InterventionStatusBadge(status: i.status),
          ),
          InfoRow(label: tr.wfCustomerSees, value: i.status?.customerLabel),
          const SizedBox(height: 8),
          if (options.isEmpty)
            Text(
              tr.wfNoTransitions,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in options)
                  OutlinedButton(
                    onPressed: c.isBusy.value ? null : () => _change(s),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: hexColor(s.color, context.colors.outline),
                      ),
                    ),
                    child: Text(s.name),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TriageCard extends StatelessWidget {
  const _TriageCard({required this.c, required this.i});

  final InterventionDetailController c;
  final Intervention i;

  @override
  Widget build(BuildContext context) {
    final workflow = c.workflow;
    return SectionCard(
      title: tr.wfTriage,
      icon: Icons.tune,
      child: Column(
        children: [
          DropdownButtonFormField<int?>(
            key: ValueKey('prio-${i.priority?.id}'),
            initialValue: i.priority?.id,
            isExpanded: true,
            decoration: InputDecoration(labelText: tr.wfPriority),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(tr.wfNoPriority)),
              for (final p in workflow.activePriorities)
                DropdownMenuItem<int?>(
                  value: p.id,
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: hexColor(p.color, context.colors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(p.name),
                    ],
                  ),
                ),
            ],
            onChanged: c.isBusy.value
                ? null
                : (v) async => _report(
                    await c.updateTriage(
                      priorityId: v,
                      clearPriority: v == null,
                    ),
                    tr.wfSaved,
                  ),
          ),
          const SizedBox(height: 12),
          EmployeeDropdown(
            value: i.assignedEmployee,
            names: workflow.employeeNames,
            onChanged: c.isBusy.value
                ? (_) {}
                : (v) async => _report(
                    await c.updateTriage(
                      assignedEmployee: v,
                      clearAssignee: v == null,
                    ),
                    tr.wfSaved,
                  ),
          ),
          const SizedBox(height: 12),
          DateTimeField(
            label: tr.wfScheduledAt,
            value: i.scheduledAt,
            clearable: true,
            enabled: !c.isBusy.value,
            onChanged: (v) async => _report(
              await c.updateTriage(scheduledAt: v, clearSchedule: v == null),
              tr.wfSaved,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishCard extends StatelessWidget {
  const _PublishCard({required this.c, required this.i});

  final InterventionDetailController c;
  final Intervention i;

  Future<void> _publish() async {
    final text = await showPublishDialog(i);
    if (text == null) return;
    _report(await c.publish(text), tr.wfPublished);
  }

  Future<void> _unpublish() async {
    final ok = await showConfirmDialog(
      title: tr.wfUnpublishTitle,
      message: tr.wfUnpublishBody,
      confirmLabel: tr.wfUnpublish,
      destructive: true,
    );
    if (!ok) return;
    _report(await c.unpublish(), tr.wfUnpublished);
  }

  @override
  Widget build(BuildContext context) => SectionCard(
    title: tr.wfReleaseNotes,
    subtitle: tr.wfReleaseNotesHint,
    icon: Icons.campaign_outlined,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (i.isPublished) ...[
          StatusBadge(
            label: tr.wfPublishedOn(Formatters.dateTime(i.publishedAt)),
            color: context.crm.success,
            icon: Icons.check_circle_outline,
          ),
          if (i.customerResolution != null) ...[
            const SizedBox(height: 8),
            SelectableText(i.customerResolution!),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: c.isBusy.value ? null : _unpublish,
            icon: const Icon(Icons.visibility_off_outlined, size: 18),
            label: Text(tr.wfUnpublish),
          ),
        ] else ...[
          Text(
            i.customers.isEmpty ? tr.wfPublishNoCustomers : tr.wfNotPublished,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: c.isBusy.value ? null : _publish,
            icon: const Icon(Icons.campaign_outlined, size: 18),
            label: Text(tr.wfPublish),
          ),
        ],
      ],
    ),
  );
}

/// Conversation with a hard visual split between internal notes (employee
/// only) and customer-visible replies.
class _ConversationCard extends StatelessWidget {
  const _ConversationCard({required this.c, required this.i});

  final InterventionDetailController c;
  final Intervention i;

  Future<void> _send() async {
    if (c.customerVisible.value) {
      final ok = await showConfirmDialog(
        title: tr.wfConfirmCustomerReplyTitle,
        message: tr.wfConfirmCustomerReplyBody,
        confirmLabel: tr.wfSendReply,
      );
      if (!ok) return;
    }
    final visible = c.customerVisible.value;
    _report(await c.sendMessage(), visible ? tr.wfReplySaved : tr.wfNoteSaved);
  }

  @override
  Widget build(BuildContext context) {
    final messages = i.messages;
    return SectionCard(
      title: tr.wfConversation,
      icon: Icons.forum_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (messages.isEmpty)
            EmptyView(compact: true, title: tr.wfNoMessages)
          else
            for (final m in messages)
              m.isEvent
                  ? ChatEventPill(message: m)
                  : ChatBubble(message: m, controller: c),
          const Divider(height: 28),
          // Closed: no composer, no attach button, just the explanation.
          if (i.canReply)
            _Composer(c: c, send: _send)
          else
            const ClosedInterventionBanner(),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.c, required this.send});

  final InterventionDetailController c;
  final VoidCallback send;

  @override
  Widget build(BuildContext context) => Obx(() {
    final visible = c.customerVisible.value;
    final crm = context.crm;
    final tint = visible ? crm.info : crm.warning;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: false,
              icon: const Icon(Icons.lock_outline, size: 18),
              label: Text(tr.wfInternalNote),
            ),
            ButtonSegment(
              value: true,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: Text(tr.wfCustomerReply),
            ),
          ],
          selected: {visible},
          onSelectionChanged: (s) => c.customerVisible.value = s.first,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                visible ? Icons.visibility_outlined : Icons.lock_outline,
                size: 18,
                color: tint,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  visible ? tr.wfCustomerReplyWarning : tr.wfInternalNoteHint,
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: c.message,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: visible ? tr.wfCustomerReply : tr.wfInternalNote,
            alignLabelWithHint: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: tint.withValues(alpha: 0.6)),
            ),
          ),
        ),
        PendingFilesBar(controller: c),
        const SizedBox(height: 8),
        Row(
          children: [
            Tooltip(
              message: tr.ivAttachLimit(InterventionDetailController.maxFiles),
              child: OutlinedButton.icon(
                onPressed: c.isBusy.value
                    ? null
                    : () async {
                        final skipped = await c.pickFiles();
                        if (skipped > 0) {
                          AppFeedback.warning(
                            tr.ivAttachLimit(
                              InterventionDetailController.maxFiles,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.attach_file, size: 18),
                label: Text(tr.ivAttachFiles),
              ),
            ),
            if (visible && c.pendingFiles.isNotEmpty) ...[
              const SizedBox(width: 8),
              FilterChip(
                avatar: const Icon(Icons.healing_outlined, size: 16),
                label: Text(tr.ivHotfixLabel),
                tooltip: tr.ivHotfixHint,
                selected: c.isHotfix.value,
                onSelected: c.isBusy.value ? null : (v) => c.isHotfix.value = v,
              ),
            ],
            const Spacer(),
            FilledButton.icon(
              onPressed: c.isBusy.value ? null : send,
              icon: Icon(
                visible ? Icons.send : Icons.note_add_outlined,
                size: 18,
              ),
              label: Text(visible ? tr.wfSendReply : tr.wfAddNote),
            ),
          ],
        ),
      ],
    );
  });
}
