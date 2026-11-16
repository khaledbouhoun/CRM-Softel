# -*- coding: utf-8 -*-
"""Prospect list filters and details page for the new profile fields."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import edit  # noqa: E402

P = 'lib/features/prospects/presentation/'

edit(P + 'controllers/prospects_list_controller.dart', "  void setLossReason(int? reasonId) =>",
     "  void setSource(String? code) =>\n      _apply(filter.value.copyWith(source: code, page: 1));\n\n"
     "  void setBusinessActivity(String? code) =>\n      _apply(filter.value.copyWith(businessActivity: code, page: 1));\n\n"
     "  void setPreviousSoftware(String? code) =>\n      _apply(filter.value.copyWith(previousSoftware: code, page: 1));\n\n"
     "  void setLossReason(int? reasonId) =>")

edit(P + 'pages/prospects_page.dart', """          DateRangeFilterButton(
            label: tr.filterCreatedDate,""", """          FilterDropdown<CatalogOption>(
            label: tr.fieldSource,
            value: ProspectCatalogs.sources.firstWhereOrNull((o) => o.code == f.source),
            items: ProspectCatalogs.sources,
            itemLabel: (o) => o.label,
            allLabel: tr.allSources,
            onChanged: (o) => c.setSource(o?.code),
          ),
          FilterDropdown<CatalogOption>(
            label: tr.fieldBusinessActivity,
            value: ProspectCatalogs.businessActivities.firstWhereOrNull((o) => o.code == f.businessActivity),
            items: ProspectCatalogs.businessActivities,
            itemLabel: (o) => o.label,
            onChanged: (o) => c.setBusinessActivity(o?.code),
          ),
          FilterDropdown<CatalogOption>(
            label: tr.fieldPreviousSoftware,
            value: ProspectCatalogs.previousSoftware.firstWhereOrNull((o) => o.code == f.previousSoftware),
            items: ProspectCatalogs.previousSoftware,
            itemLabel: (o) => o.label,
            onChanged: (o) => c.setPreviousSoftware(o?.code),
          ),
          DateRangeFilterButton(
            label: tr.filterCreatedDate,""")
edit(P + 'pages/prospects_page.dart', "import '../../data/models/prospect.dart';",
     "import '../../data/models/prospect.dart';\nimport '../../data/models/prospect_catalogs.dart';")

edit(P + 'pages/prospect_details_page.dart', """        InfoRow(label: tr.fieldCity, value: p.city, icon: Icons.location_city_outlined),
        InfoRow(label: tr.fieldNotes, value: p.notes, icon: Icons.notes),""", """        InfoRow(label: tr.fieldCity, value: p.city, icon: Icons.location_city_outlined),
        InfoRow(
          label: tr.fieldBusinessActivity,
          value: ProspectCatalogs.labelOf(ProspectCatalogs.businessActivities, p.businessActivity),
          icon: Icons.storefront_outlined,
        ),
        InfoRow(
          label: tr.fieldSource,
          value: ProspectCatalogs.sourceDisplay(p.source, p.sourceOther) ?? tr.notSpecified,
          icon: Icons.campaign_outlined,
        ),
        InfoRow(
          label: tr.fieldPreviousSoftware,
          value: ProspectCatalogs.labelOf(ProspectCatalogs.previousSoftware, p.previousSoftware),
          icon: Icons.apps_outlined,
        ),
        InfoRow(label: tr.fieldNotes, value: p.notes, icon: Icons.notes),""")
edit(P + 'pages/prospect_details_page.dart', "import '../../data/models/prospect.dart';",
     "import '../../data/models/prospect.dart';\nimport '../../data/models/prospect_catalogs.dart';")
print('ui3 ok')
