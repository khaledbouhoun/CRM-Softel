import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/l10n/l10n.dart';
import '../../../app/services/workflow_lookup_service.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/workflow_widgets.dart';
import '../../products/data/models/product.dart';
import '../data/models/config_models.dart';
import 'config_schema.dart';
import 'workflow_settings_controllers.dart';
import 'workflow_settings_page.dart';

/// Customer-facing links of one product (training material, documentation).
/// Links are deactivated, never deleted; "customer visible" decides whether
/// the portal may show them (a hidden URL is not authorization).
Future<void> showProductResourcesDialog(Product product) async {
  final list = ConfigEntityController(
    schema: ConfigSchemas.productResources,
    repository: Get.find(),
    workflow: Get.find<WorkflowLookupService>(),
  );
  final tag = 'product-resources-${product.id}';
  Get.put(list, tag: tag);
  try {
    await Get.dialog<void>(_ResourcesDialog(product: product, list: list));
  } finally {
    Get.delete<ConfigEntityController>(tag: tag, force: true);
  }
}

class _ResourcesDialog extends StatelessWidget {
  const _ResourcesDialog({required this.product, required this.list});

  final Product product;
  final ConfigEntityController list;

  Future<void> _edit([ConfigRow? row]) async {
    final saved = await showControllerDialog<ConfigFormController, ConfigRow>(
      controller: ConfigFormController(
        schema: ConfigSchemas.productResources,
        list: list,
        existing: row,
        defaults: {'product_id': product.id},
      ),
      builder: (f) => ConfigFormDialog(f),
    );
    if (saved != null) AppFeedback.success(tr.wfSaved);
  }

  Future<void> _toggle(ConfigRow row) async {
    if (row.isActive) {
      final ok = await showConfirmDialog(
        title: tr.wfDeactivateTitle,
        message: tr.wfDeactivateBody,
        confirmLabel: tr.actionDeactivate,
      );
      if (!ok) return;
    }
    final result = await list.toggleActive(row);
    if (!result.isSuccess) AppFeedback.error(result.error!);
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 680,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tr.wfProductResourcesTitle(product.name),
                    style: context.text.titleLarge,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _edit,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(tr.actionAdd),
                ),
                IconButton(
                  tooltip: tr.actionClose,
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tr.wfCfgProductResourcesHint,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Obx(() {
                final rows = list.rows
                    .where((r) => r.intValue('product_id') == product.id)
                    .toList();
                return LoadStateView(
                  state: list.state,
                  isEmpty: rows.isEmpty,
                  compact: true,
                  onRetry: list.load,
                  empty: EmptyView(
                    compact: true,
                    icon: Icons.link_off,
                    title: tr.wfNoResources,
                  ),
                  builder: (_) => ListView.separated(
                    shrinkWrap: true,
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final r = rows[i];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.link),
                        title: Text(
                          r.name,
                          style: TextStyle(
                            color: r.isActive ? null : context.colors.outline,
                          ),
                        ),
                        subtitle: Text(
                          joinNonEmpty([
                            r.str('url'),
                            if (r.boolValue('customer_visible'))
                              tr.wfCustomerVisible,
                            if (r.boolValue('is_training_material'))
                              tr.wfTrainingMaterial,
                          ]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: r.isActive,
                              onChanged: (_) => _toggle(r),
                            ),
                            IconButton(
                              tooltip: tr.actionEdit,
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _edit(r),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ),
  );
}
