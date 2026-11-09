import 'package:flutter/material.dart';

import '../../../../app/l10n/l10n.dart';
import '../../data/models/prospect_ref.dart';
import '../dialogs/prospect_search_dialog.dart';

/// Read-only field that opens the shared prospect search dialog.
///
/// [optional] fields can be cleared; required ones can only be replaced.
class ProspectPickerField extends StatelessWidget {
  const ProspectPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.optional = false,
  });

  final ProspectRef? value;
  final ValueChanged<ProspectRef?> onChanged;
  final String? errorText;
  final bool enabled;
  final bool optional;

  Future<void> _pick() async {
    final picked = await showProspectSearchDialog(title: tr.pickProspect);
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final label = optional
        ? tr.prospectOptionalLabel
        : tr.prospectRequiredLabel;
    final selected = value;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? _pick : null,
      child: InputDecorator(
        isEmpty: selected == null,
        decoration: InputDecoration(
          labelText: label,
          hintText: tr.pickProspect,
          errorText: errorText,
          enabled: enabled,
          prefixIcon: Icon(
            selected == null ? Icons.search : Icons.business_outlined,
            size: 20,
          ),
          suffixIcon: !enabled
              ? null
              : selected != null && optional
              ? IconButton(
                  tooltip: tr.actionClear,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => onChanged(null),
                )
              : selected != null
              ? IconButton(
                  tooltip: tr.changeProspect,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  onPressed: _pick,
                )
              : null,
        ),
        child: selected == null
            ? null
            : Text(selected.displayName, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
