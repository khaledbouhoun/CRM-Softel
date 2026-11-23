import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/presentation/widgets/stage_widgets.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_filter.dart';
import '../../data/models/prospect_ref.dart';
import '../../domain/prospects_repository.dart';

import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/animated_entrance.dart';
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

  /// Only prospects/customers linked to this product (owned or interested).
  int? productId,
}) => showAppDialog<ProspectRef>(
  _ProspectSearchDialog(
    title: title ?? tr.searchProspectTitle,
    initialQuery: initialQuery,
    excludeProspectId: excludeProspectId,
    excludeStageIds: excludeStageIds,
    hint: confirmHint,
    productId: productId,
  ),
);

class _ProspectSearchDialog extends StatefulWidget {
  const _ProspectSearchDialog({
    required this.title,
    required this.initialQuery,
    this.excludeProspectId,
    this.excludeStageIds,
    this.hint,
    this.productId,
  });

  final String title;
  final String initialQuery;
  final int? excludeProspectId;
  final List<int>? excludeStageIds;
  final String? hint;
  final int? productId;

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

  /// Row highlighted by Arrow Up/Down; Enter opens it.
  int _selectedIndex = 0;
  final _itemKeys = <int, GlobalKey>{};

  late final FocusNode _searchFocus = FocusNode(onKeyEvent: _onKey);

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.trim().isNotEmpty) _run(widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      Get.back();
      return KeyEventResult.handled;
    }
    if (_results.isEmpty) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveSelection(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveSelection(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      if (event is KeyDownEvent && _query == _controller.text.trim()) {
        _select(_results[_selectedIndex.clamp(0, _results.length - 1)]);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _moveSelection(int delta) {
    setState(() => _selectedIndex = (_selectedIndex + delta).clamp(0, _results.length - 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _itemKeys[_selectedIndex]?.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 80));
    });
  }

  void _select(Prospect p) => Get.back(result: p.toRef());

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
        _selectedIndex = 0;
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
        ProspectFilter(
          search: query,
          // Pickers must also find customers (appointments, activities, ...).
          converted: ProspectConvertedFilter.all,
          productId: widget.productId,
          perPage: _pageSize,
          sort: ProspectSort.companyName,
          ascending: true,
        ),
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
        _selectedIndex = 0;
        _itemKeys.clear();
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
    elevation: 12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                IconButton(tooltip: tr.actionClose, icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 18), onPressed: () => Get.back()),
              ],
            ),
            if (widget.productId != null) ...[
              Text(
                tr.prCustomersFilteredByProduct,
                style: context.text.bodySmall?.copyWith(color: context.colors.primary),
              ),
              const SizedBox(height: 6),
            ],
            if (widget.hint != null) ...[
              Text(widget.hint!, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            TextField(
              controller: _controller,
              autofocus: true,
              focusNode: _searchFocus,
              onChanged: _onChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                _run(v);
              },
              decoration: InputDecoration(
                hintText: tr.searchProspectHint,
                helperText: tr.searchKeyboardHint,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8),
                  child: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, size: 18),
                ),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: tr.actionClear,
                        icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 18),
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
              key: _itemKeys.putIfAbsent(i, GlobalKey.new),
              prospect: _results[i],
              selected: i == _selectedIndex,
              onHover: () {
                if (_selectedIndex != i) setState(() => _selectedIndex = i);
              },
              onTap: () => _select(_results[i]),
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
  const _ResultTile({super.key, required this.prospect, required this.onTap, this.selected = false, this.onHover});

  final Prospect prospect;
  final VoidCallback onTap;
  final bool selected;
  final VoidCallback? onHover;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (prospect.contactName != null && prospect.contactName!.isNotEmpty) prospect.contactName!,
      if (prospect.phone != null && prospect.phone!.isNotEmpty) prospect.phone!,
      tr.prospectIdShort(prospect.id),
    ].join('  ·  ');
    return InkWell(
      onTap: onTap,
      onHover: (h) {
        if (h) onHover?.call();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? context.colors.primaryContainer.withValues(alpha: 0.4) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
            if (prospect.isCustomer)
              StatusPill(
                label: tr.customerSoftelClient,
                color: context.colors.primary,
                icon: HugeIcons.strokeRoundedBuilding02,
              )
            else
              StageChip(stage: prospect.stage, dense: true),
            if (selected) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.outlineVariant),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('↵', style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                    const SizedBox(width: 4),
                    Text(tr.actionOpen, style: context.text.labelSmall),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
