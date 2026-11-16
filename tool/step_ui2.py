# -*- coding: utf-8 -*-
"""Prospect form: business activity, source, previous software."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import edit  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CT = 'lib/features/prospects/presentation/controllers/prospect_form_controller.dart'
DG = 'lib/features/prospects/presentation/dialogs/prospect_dialogs.dart'

# ---------------------------------------------------------------- controller
edit(CT, "import '../../data/models/prospect.dart';",
     "import '../../data/models/prospect.dart';\nimport '../../data/models/prospect_catalogs.dart';")
edit(CT, "  late final notes = TextEditingController(text: initial?.notes);\n",
     "  late final notes = TextEditingController(text: initial?.notes);\n\n"
     "  // Business profile. business activity / previous software are a catalogue\n"
     "  // code or free text: the field shows the label (or the text), and the\n"
     "  // matching code is what gets saved.\n"
     "  late final businessActivity = TextEditingController(\n"
     "    text: initial?.businessActivity == null\n"
     "        ? ''\n"
     "        : ProspectCatalogs.labelOf(ProspectCatalogs.businessActivities, initial!.businessActivity),\n"
     "  );\n"
     "  late final previousSoftware = TextEditingController(\n"
     "    text: initial?.previousSoftware == null\n"
     "        ? ''\n"
     "        : ProspectCatalogs.labelOf(ProspectCatalogs.previousSoftware, initial!.previousSoftware),\n"
     "  );\n"
     "  late final sourceOther = TextEditingController(text: initial?.sourceOther);\n\n"
     "  /// Stable source code (`facebook`, `other`, ...) or null.\n"
     "  late final source = Rxn<String>(\n"
     "    (initial?.source ?? '').trim().isEmpty ? null : initial!.source,\n"
     "  );\n")
edit(CT, "    'city',\n    'notes',\n    'sales_stage_id',",
     "    'city',\n    'business_activity',\n    'source',\n    'source_other',\n    'previous_software',\n    'notes',\n    'sales_stage_id',")
edit(CT, "  String? validateNotes(String? v) =>",
     "  String? validateBusinessActivity(String? v) =>\n"
     "      serverErrors['business_activity'] ?? Validators.maxLength(v, 150);\n\n"
     "  String? validatePreviousSoftware(String? v) =>\n"
     "      serverErrors['previous_software'] ?? Validators.maxLength(v, 150);\n\n"
     "  String? validateSourceOther(String? v) =>\n"
     "      serverErrors['source_other'] ?? Validators.maxLength(v, 150);\n\n"
     "  void selectSource(String? code) {\n"
     "    source.value = code;\n"
     "    serverErrors.remove('source');\n"
     "  }\n\n"
     "  String? validateNotes(String? v) =>")
edit(CT, "    check('notes', validateNotes(notes.text));\n",
     "    check('business_activity', validateBusinessActivity(businessActivity.text));\n"
     "    check('previous_software', validatePreviousSoftware(previousSoftware.text));\n"
     "    check('source_other', validateSourceOther(sourceOther.text));\n"
     "    check('notes', validateNotes(notes.text));\n")
edit(CT, "    city: city.text,\n    notes: notes.text,\n    salesStageId",
     "    city: city.text,\n"
     "    businessActivity: ProspectCatalogs.codeFor(ProspectCatalogs.businessActivities, businessActivity.text),\n"
     "    source: source.value,\n"
     "    sourceOther: sourceOther.text,\n"
     "    previousSoftware: ProspectCatalogs.codeFor(ProspectCatalogs.previousSoftware, previousSoftware.text),\n"
     "    notes: notes.text,\n    salesStageId")
edit(CT, "    for (final c in [companyName, contactName, phone, email, address, city, notes]) {",
     "    for (final c in [\n      companyName, contactName, phone, email, address, city, notes,\n"
     "      businessActivity, previousSoftware, sourceOther,\n    ]) {")

# ---------------------------------------------------------------- reusable widget
with open(os.path.join(ROOT, 'lib/features/prospects/presentation/widgets/catalog_text_field.dart'),
          'w', encoding='utf-8', newline='\n') as f:
    f.write('''import 'package:flutter/material.dart';

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
          controller.selection = TextSelection.collapsed(offset: controller.text.length);
          onChanged?.call(o.label);
        },
        itemBuilder: (_) => [
          for (final o in options) PopupMenuItem(value: o, child: Text(o.label)),
        ],
      ),
    ),
  );
}
''')

# ---------------------------------------------------------------- dialog
edit(DG, """            const SizedBox(height: 18),
            FormSectionLabel(tr.sectionSalesFollowUp),""", """            const SizedBox(height: 18),
            FormSectionLabel(tr.sectionBusinessProfile),
            FormRow(
              children: [
                CatalogTextField(
                  controller: c.businessActivity,
                  options: ProspectCatalogs.businessActivities,
                  label: tr.fieldBusinessActivity,
                  hint: tr.businessActivityHint,
                  icon: Icons.storefront_outlined,
                  validator: c.validateBusinessActivity,
                  onChanged: (_) => c.clearServerError('business_activity'),
                ),
                CatalogTextField(
                  controller: c.previousSoftware,
                  options: ProspectCatalogs.previousSoftware,
                  label: tr.fieldPreviousSoftware,
                  hint: tr.previousSoftwareHint,
                  icon: Icons.apps_outlined,
                  validator: c.validatePreviousSoftware,
                  onChanged: (_) => c.clearServerError('previous_software'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sourceRow(),
            const SizedBox(height: 18),
            FormSectionLabel(tr.sectionSalesFollowUp),""")
edit(DG, "  Widget _stageField(BuildContext context) {", """  Widget _sourceRow() {
    final known = ProspectCatalogs.sources;
    final current = c.source.value;
    // A code added by a newer server is still shown (and kept) as-is.
    final extra = current != null && !known.any((o) => o.code == current)
        ? [CatalogOption(current, () => current)]
        : const <CatalogOption>[];
    final sourceField = DropdownButtonFormField<String?>(
      key: ValueKey('source-$current'),
      initialValue: current,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: tr.fieldSource,
        errorText: c.serverErrors['source'],
        prefixIcon: const Icon(Icons.campaign_outlined, size: 20),
      ),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(tr.notSpecified)),
        for (final o in [...known, ...extra]) DropdownMenuItem<String?>(value: o.code, child: Text(o.label)),
      ],
      onChanged: c.selectSource,
    );
    if (current != ProspectCatalogs.otherCode) return sourceField;
    return FormRow(
      children: [
        sourceField,
        TextFormField(
          controller: c.sourceOther,
          decoration: InputDecoration(
            labelText: tr.fieldSourceOther,
            prefixIcon: const Icon(Icons.edit_note, size: 20),
          ),
          validator: c.validateSourceOther,
          onChanged: (_) => c.clearServerError('source_other'),
        ),
      ],
    );
  }

  Widget _stageField(BuildContext context) {""")
edit(DG, "          alignment: Alignment.centerLeft,\n          child: StageChip(stage: c.initial!.stage),",
     "          alignment: AlignmentDirectional.centerStart,\n          child: StageChip(stage: c.initial!.stage),")
edit(DG, "import '../../data/models/prospect.dart';",
     "import '../../data/models/prospect.dart';\nimport '../../data/models/prospect_catalogs.dart';\nimport '../widgets/catalog_text_field.dart';")
print('ui2 ok')
