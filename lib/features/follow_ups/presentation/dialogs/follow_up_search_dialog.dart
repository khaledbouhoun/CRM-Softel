import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../activities/presentation/widgets/activity_widgets.dart';
import '../../data/models/follow_up.dart';
import '../../domain/follow_ups_repository.dart';

/// Modal dialog for finding and selecting an existing follow-up task.
///
/// When [prospectId] is supplied, only follow-ups belonging to that prospect are
/// returned (enforcing prospect consistency).
Future<FollowUp?> showFollowUpSearchDialog({
  String? title,
  int? prospectId,
  String? prospectName,
}) => Get.dialog<FollowUp>(
  _FollowUpSearchDialog(
    title: title ??
        (prospectName != null
            ? 'Select follow-up for $prospectName'
            : 'Select follow-up'),
    prospectId: prospectId,
  ),
);

class _FollowUpSearchDialog extends StatefulWidget {
  const _FollowUpSearchDialog({
    required this.title,
    this.prospectId,
  });

  final String title;
  final int? prospectId;

  @override
  State<_FollowUpSearchDialog> createState() => _FollowUpSearchDialogState();
}

class _FollowUpSearchDialogState extends State<_FollowUpSearchDialog> {
  final TextEditingController _controller = TextEditingController();
  final FollowUpsRepository _repo = Get.find<FollowUpsRepository>();

  Timer? _debounce;
  int _requestId = 0;
  bool _loading = false;
  String? _error;
  List<FollowUp> _results = const [];

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(value));
  }

  Future<void> _search(String query) async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _repo.getFollowUps(
        prospectId: widget.prospectId,
        search: query.trim().isEmpty ? null : query.trim(),
        page: 1,
        perPage: 30,
      );

      if (id != _requestId || !mounted) return;
      setState(() {
        _results = res.items;
        _loading = false;
      });
    } catch (e) {
      if (id != _requestId || !mounted) return;
      setState(() {
        _error = ApiException.from(e).message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.event_note, color: context.colors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: context.text.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: tr.actionClose,
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: widget.prospectId == null,
                decoration: InputDecoration(
                  hintText: 'Search follow-up description or task...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _search('');
                          },
                        )
                      : null,
                ),
                onChanged: _onChanged,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? ErrorBanner(message: _error!, onRetry: () => _search(_controller.text))
                        : _results.isEmpty
                            ? Center(
                                child: Text(
                                  'No follow-ups found.',
                                  style: context.text.bodyMedium?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _results.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final item = _results[i];
                                  final prospect = item.prospect;
                                  return ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    leading: item.activityType != null
                                        ? ActivityTypeAvatar(item.activityType!, size: 28)
                                        : CircleAvatar(
                                            radius: 14,
                                            backgroundColor: context.colors.surfaceContainerHighest,
                                            child: const Icon(Icons.event, size: 16),
                                          ),
                                    title: Text(
                                      item.description?.trim().isNotEmpty == true
                                          ? item.description!
                                          : 'Follow-up #${item.id}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      [
                                        Formatters.dateTime(item.dueAt),
                                        if (prospect != null && widget.prospectId == null)
                                          prospect.companyName,
                                        item.status.label,
                                      ].join(' • '),
                                      style: context.text.bodySmall?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.chevron_right, size: 20),
                                    onTap: () => Get.back(result: item),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
