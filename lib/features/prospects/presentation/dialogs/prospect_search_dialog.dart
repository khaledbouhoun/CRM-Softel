import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_filter.dart';
import '../../data/models/prospect_ref.dart';
import '../../domain/prospects_repository.dart';

/// The one prospect lookup used everywhere (prospect pickers, linking an
/// activity, pipeline and global search).
///
/// Searches the server by company name, contact name, phone and prospect id,
/// across every stage (won and lost included), and shows each result's
/// current stage. Resolves with the chosen prospect, or null when closed.
Future<ProspectRef?> showProspectSearchDialog({
  String? title,
  String initialQuery = '',
  int? excludeProspectId,
  List<int>? excludeStageIds,
  String? confirmHint,
}) => Get.dialog<ProspectRef>(
  _ProspectSearchDialog(
    title: title ?? tr.searchProspectTitle,
    initialQuery: initialQuery,
    excludeProspectId: excludeProspectId,
    excludeStageIds: excludeStageIds,
    hint: confirmHint,
  ),
);

class _ProspectSearchDialog extends StatefulWidget {
  const _ProspectSearchDialog({
    required this.title,
    required this.initialQuery,
    this.excludeProspectId,
    this.excludeStageIds,
    this.hint,
  });

  final String title;
  final String initialQuery;
  final int? excludeProspectId;
  final List<int>? excludeStageIds;
  final String? hint;

  @override
  State<_ProspectSearchDialog> createState() => _ProspectSearchDialogState();
}

class _ProspectSearchDialogState extends State<_ProspectSearchDialog> {
  static const _pageSize = 50;

  late final TextEditingController _controller = TextEditingController(text: widget.initialQuery);
  Timer? _debounce;
  int _requestId = 0;
  bool _loading = false;
  String _query = '';
  String? _error;
  List<Prospect> _results = const [];
  int _total = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.trim().isNotEmpty) _run(widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _run(value));
  }

  Future<void> _run(String value) async {
    final query = value.trim();
    final id = ++_requestId;
    if (query.isEmpty) {
      setState(() {
        _query = '';
        _results = const [];
        _total = 0;
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _query = query;
      _error = null;
    });
    try {
      final page = await Get.find<ProspectsRepository>().getProspects(
        ProspectFilter(search: query, perPage: _pageSize, sort: ProspectSort.companyName, ascending: true),
      );
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = page.items.where((p) {
          if (p.id == widget.excludeProspectId) return false;
          final stageId = p.stage?.id;
          if (widget.excludeStageIds != null && stageId != null && widget.excludeStageIds!.contains(stageId)) {
            return false;
          }
          return true;
        }).toList();
        _total = page.total;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.title, style: context.text.titleLarge)),
                IconButton(tooltip: tr.actionClose, icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            if (widget.hint != null) ...[
              Text(widget.hint!, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                _run(v);
              },
              decoration: InputDecoration(
                hintText: tr.searchProspectHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: tr.actionClear,
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _controller.clear();
                          _run('');
                        },
                      ),
              ),
            ),
            if (widget.excludeStageIds == null || widget.excludeStageIds!.isEmpty) ...[
              const SizedBox(height: 4),
              Text(
                tr.searchAllStagesNote,
                style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 10),
            Flexible(child: _body(context)),
          ],
        ),
      ),
    ),
  );

  Widget _body(BuildContext context) {
    if (_error != null) {
      return ErrorBanner(message: _error!, onRetry: () => _run(_query));
    }
    if (_query.isEmpty) {
      return _hint(context, tr.searchProspectIdle);
    }
    if (_loading && _results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_results.isEmpty) {
      return _hint(context, tr.searchProspectEmpty);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _results.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _ResultTile(
              prospect: _results[i],
              onTap: () => Get.back(result: _results[i].toRef()),
            ),
          ),
        ),
        if (_total > _results.length)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              tr.searchProspectMore(_total),
              style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  Widget _hint(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
      ),
    ),
  );
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.prospect, required this.onTap});

  final Prospect prospect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (prospect.contactName != null && prospect.contactName!.isNotEmpty) prospect.contactName!,
      if (prospect.phone != null && prospect.phone!.isNotEmpty) prospect.phone!,
      tr.prospectIdShort(prospect.id),
    ].join('  ·  ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prospect.companyName, style: context.text.titleSmall, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StageChip(stage: prospect.stage, dense: true),
          ],
        ),
      ),
    );
  }
}
