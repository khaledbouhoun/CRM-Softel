import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../settings/data/models/prospect_form_option.dart';

/// A searchable dropdown form field with instant in-line option creation.
///
/// Filters existing options as the user types and displays an "Add new" option
/// whenever the entered text does not match any existing option name.
class SearchableOptionDropdown extends StatefulWidget {
  const SearchableOptionDropdown({
    super.key,
    required this.type,
    required this.label,
    required this.icon,
    required this.options,
    required this.currentValue,
    required this.onChanged,
    required this.onAddNew,
    this.errorText,
    this.enabled = true,
  });

  final String type;
  final String label;
  final IconData icon;
  final List<ProspectFormOption> options;
  final String? currentValue;
  final ValueChanged<String?> onChanged;
  final Future<void> Function(String name, {bool requiresDetails}) onAddNew;
  final String? errorText;
  final bool enabled;

  @override
  State<SearchableOptionDropdown> createState() =>
      _SearchableOptionDropdownState();
}

class _SearchableOptionDropdownState extends State<SearchableOptionDropdown> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();
  final Object _regionGroupId = Object();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentValue ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(SearchableOptionDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue && !_focusNode.hasFocus) {
      _textController.text = widget.currentValue ?? '';
    }
    if (_isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _closeOverlay(updateState: false);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _openOverlay() {
    if (_isOpen || !widget.enabled || !mounted) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    _isOpen = true;
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    overlay.insert(_overlayEntry!);
    setState(() {});
  }

  void _closeOverlay({bool updateState = true}) {
    if (!_isOpen) return;
    _isOpen = false;
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    if (updateState && mounted) {
      if (_textController.text != (widget.currentValue ?? '')) {
        _textController.text = widget.currentValue ?? '';
      }
      setState(() {});
    }
  }

  Future<void> _handleAddNew(
    String name, {
    bool requiresDetails = false,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _isAdding) return;
    setState(() => _isAdding = true);
    _overlayEntry?.markNeedsBuild();
    try {
      await widget.onAddNew(trimmed, requiresDetails: requiresDetails);
      _closeOverlay();
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Widget _buildOverlay(BuildContext context) {
    final renderBox = this.context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return const SizedBox.shrink();

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    final spaceBelow =
        screenHeight -
        (offset.dy + size.height) -
        mediaQuery.viewInsets.bottom -
        16;
    final spaceAbove = offset.dy - mediaQuery.viewInsets.top - 16;

    final bool showAbove = spaceBelow < 180 && spaceAbove > spaceBelow;
    final double maxHeight = (showAbove ? spaceAbove : spaceBelow).clamp(
      120.0,
      260.0,
    );

    return Stack(
      children: [
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: showAbove ? Alignment.topLeft : Alignment.bottomLeft,
          followerAnchor: showAbove ? Alignment.bottomLeft : Alignment.topLeft,
          offset: Offset(0, showAbove ? -4 : 4),
          child: SizedBox(
            width: size.width,
            child: TapRegion(
              groupId: _regionGroupId,
              child: _buildDropdownCard(context, maxHeight),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCard(BuildContext context, double maxHeight) {
    final query = _textController.text.trim();
    final lowerQuery = query.toLowerCase();

    final hasCurrentInOptions = widget.options.any(
      (o) => o.name == widget.currentValue,
    );
    final List<ProspectFormOption> allOptions = [
      if (widget.currentValue != null &&
          widget.currentValue!.isNotEmpty &&
          !hasCurrentInOptions)
        ProspectFormOption(
          id: -1,
          type: widget.type,
          name: widget.currentValue!,
          requiresDetails: false,
          sortOrder: 0,
          isActive: true,
        ),
      ...widget.options,
    ];

    final filtered = allOptions.where((o) {
      if (query.isEmpty) return true;
      return o.name.toLowerCase().contains(lowerQuery);
    }).toList();

    final hasExactMatch =
        query.isEmpty ||
        allOptions.any((o) => o.name.toLowerCase() == lowerQuery);

    return Material(
      elevation: 8,
      shadowColor: AppShadows.dialog(context.theme.brightness).first.color,
      borderRadius: BorderRadius.circular(AppRadius.md),
      color: context.colors.surface,
      surfaceTintColor: context.colors.surfaceTint,
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  if (widget.currentValue != null &&
                      widget.currentValue!.isNotEmpty)
                    _buildClearTile(context),
                  for (final opt in filtered) _buildOptionTile(context, opt),
                  if (filtered.isEmpty && hasExactMatch)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        switch (L10n.current.languageCode) {
                          'ar' => 'لا توجد خيارات متاحة',
                          'fr' => 'Aucune option disponible',
                          _ => 'No options available',
                        },
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (query.isNotEmpty && !hasExactMatch) ...[
              const Divider(height: 1),
              _buildAddTile(context, query),
            ],
            if (query.isEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 14, color: context.colors.outline),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        switch (L10n.current.languageCode) {
                          'ar' => 'اكتب للبحث أو لإضافة خيار جديد...',
                          'fr' => 'Tapez pour rechercher ou ajouter...',
                          _ => 'Type to search or add new...',
                        },
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddTile(BuildContext context, String query) => InkWell(
    onTap: _isAdding
        ? null
        : () => _handleAddNew(query, requiresDetails: false),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: context.colors.primaryContainer.withValues(alpha: 0.25),
      child: Row(
        children: [
          if (_isAdding)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              Icons.add_circle,
              size: 20,
              color: context.colors.primary,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: context.text.bodyMedium,
                    children: [
                      TextSpan(
                        text: switch (L10n.current.languageCode) {
                          'ar' => 'إضافة ',
                          'fr' => 'Ajouter ',
                          _ => 'Add ',
                        },
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '"$query"',
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  switch (L10n.current.languageCode) {
                    'ar' => 'حفظ كعنصر جديد في القائمة',
                    'fr' => 'Enregistrer comme nouvelle option',
                    _ => 'Save as new option in list',
                  },
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.outline,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: switch (L10n.current.languageCode) {
              'ar' => 'إضافة مع اشتراط تفاصيل',
              'fr' => 'Ajouter avec précisions obligatoires',
              _ => 'Add with required details',
            },
            child: IconButton(
              icon: const Icon(Icons.edit_note, size: 20),
              onPressed: _isAdding
                  ? null
                  : () => _handleAddNew(query, requiresDetails: true),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildOptionTile(BuildContext context, ProspectFormOption opt) {
    final isSelected = opt.name == widget.currentValue;
    return InkWell(
      onTap: () {
        widget.onChanged(opt.name);
        _textController.text = opt.name;
        _closeOverlay();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        color: isSelected
            ? context.colors.primaryContainer.withValues(alpha: 0.35)
            : null,
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color:
                  isSelected ? context.colors.primary : context.colors.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                opt.name,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? context.colors.primary : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (opt.requiresDetails) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 12,
                      color: context.colors.onSecondaryContainer,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      tr.detailsRequired,
                      style: context.text.labelSmall?.copyWith(
                        fontSize: 10,
                        color: context.colors.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClearTile(BuildContext context) => InkWell(
    onTap: () {
      widget.onChanged(null);
      _textController.clear();
      _closeOverlay();
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.clear, size: 16, color: context.colors.outline),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr.notSpecified,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _regionGroupId,
      onTapOutside: (_) {
        if (_isOpen) {
          _closeOverlay();
          _focusNode.unfocus();
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextFormField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: widget.label,
            errorText: widget.errorText,
            prefixIcon: Icon(widget.icon, size: 20),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.currentValue != null &&
                    widget.currentValue!.isNotEmpty &&
                    widget.enabled)
                  IconButton(
                    tooltip: tr.actionClear,
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _textController.clear();
                      widget.onChanged(null);
                      if (_isOpen) _overlayEntry?.markNeedsBuild();
                    },
                  ),
                IconButton(
                  tooltip: widget.label,
                  icon: Icon(
                    _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 22,
                  ),
                  onPressed: !widget.enabled
                      ? null
                      : () {
                          if (_isOpen) {
                            _closeOverlay();
                            _focusNode.unfocus();
                          } else {
                            _focusNode.requestFocus();
                            _openOverlay();
                          }
                        },
                ),
              ],
            ),
          ),
          onTap: () {
            if (!_isOpen) {
              _openOverlay();
            }
            _textController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _textController.text.length,
            );
          },
          onChanged: (text) {
            if (!_isOpen) _openOverlay();
            _overlayEntry?.markNeedsBuild();
          },
          onFieldSubmitted: (text) async {
            final query = text.trim();
            if (query.isEmpty) return;
            final match = widget.options.firstWhereOrNull(
              (o) => o.name.toLowerCase() == query.toLowerCase(),
            );
            if (match != null) {
              widget.onChanged(match.name);
              _textController.text = match.name;
              _closeOverlay();
            } else {
              await _handleAddNew(query, requiresDetails: false);
            }
          },
        ),
      ),
    );
  }
}
