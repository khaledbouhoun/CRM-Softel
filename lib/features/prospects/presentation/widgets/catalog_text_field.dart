import 'package:flutter/material.dart';

import '../../data/models/prospect_catalogs.dart';

/// Text field with a menu of suggested options. Picking an option fills the
/// field with its label; the user can also type anything (the catalogue
/// never restricts valid values).
class CatalogTextField extends StatelessWidget {
  const CatalogTextField({
    super.key,
    required this.controller,
    required this.options,
    required this.label,
    this.hint,
    this.icon,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final List<CatalogOption> options;
  final String label;
  final String? hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      suffixIcon: PopupMenuButton<CatalogOption>(
        tooltip: label,
        icon: const Icon(Icons.arrow_drop_down),
        onSelected: (o) {
          controller.text = o.label;
          controller.selection = TextSelection.collapsed(
            offset: controller.text.length,
          );
          onChanged?.call(o.label);
        },
        itemBuilder: (_) => [
          for (final o in options)
            PopupMenuItem(value: o, child: Text(o.label)),
        ],
      ),
    ),
  );
}
