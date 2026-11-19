import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/crm_data_table.dart';
import '../../../../core/widgets/filter_widgets.dart';
import '../../../../core/widgets/layout_widgets.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../data/models/product_release.dart';
import '../controllers/releases_controllers.dart';
import '../dialogs/release_form_dialog.dart';

/// Staff management of product releases (versions, installers, audience).
class ReleasesPage extends GetView<ReleasesController> {
  const ReleasesPage({super.key});

  Future<void> _edit([ProductRelease? release]) async {
    final saved = await showReleaseFormDialog(release: release);
    if (saved == null) return;
    AppFeedback.success(tr.rlSaved);
    await controller.load();
  }

  Future<void> _delete(ProductRelease r) async {
    final ok = await showConfirmDialog(
      title: tr.rlDeleteTitle,
      message: tr.rlDeleteBody,
      destructive: true,
    );
    if (!ok) return;
    final result = await controller.delete(r);
    result.isSuccess
        ? AppFeedback.success(tr.rlDeleted)
        : AppFeedback.error(result.error!.message);
  }

  Future<void> _download(ProductRelease r) async {
    final result = await controller.saveInstaller(r);
    result.isSuccess
        ? AppFeedback.success(tr.ivFileSaved(result.value ?? ''))
        : AppFeedback.error(result.error!.message);
  }

  @override
  Widget build(BuildContext context) {
    final lookups = Get.find<LookupService>();
    return AppShell(
      route: Routes.releases,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: tr.navReleases,
            subtitle: tr.rlSubtitle,
            actions: [
              FilledButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.add, size: 18),
                label: Text(tr.rlNew),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Obx(
              () => Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilterDropdown<int>(
                  label: tr.fieldProduct,
                  width: 240,
                  allLabel: tr.rlAllProducts,
                  value: controller.productId.value,
                  items: lookups.activeProducts.map((p) => p.id).toList(),
                  itemLabel: (id) =>
                      lookups.products.firstWhereOrNull((p) => p.id == id)?.name ??
                      '$id',
                  onChanged: controller.setProduct,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 24),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Obx(() {
                  final page = controller.page.value;
                  final rows = controller.releases;
                  return Column(
                    children: [
                      RefreshingBar(
                        visible: controller.state.isLoading && rows.isNotEmpty,
                      ),
                      Expanded(
                        child: LoadStateView(
                          state: controller.state,
                          isEmpty: rows.isEmpty,
                          onRetry: controller.load,
                          empty: EmptyView(
                            icon: Icons.system_update_alt,
                            title: tr.rlNoReleases,
                            message: tr.rlNoReleasesHint,
                          ),
                          builder: (_) => CrmDataTable<ProductRelease>(
                            rows: rows,
                            rowHeight: 60,
                            onRowTap: _edit,
                            columns: [
                              CrmColumn(
                                label: tr.fieldProduct,
                                flex: 3,
                                cell: (r) =>
                                    CellText(r.product?.name ?? '', bold: true),
                              ),
                              CrmColumn(
                                label: tr.rlVersion,
                                width: 120,
                                cell: (r) => CellText(r.versionNumber),
                              ),
                              CrmColumn(
                                label: tr.rlDate,
                                width: 130,
                                cell: (r) =>
                                    CellText(Formatters.date(r.releaseDate)),
                              ),
                              CrmColumn(
                                label: tr.rlAudience,
                                flex: 2,
                                cell: (r) => CellText(switch (r.audience) {
                                  ReleaseAudience.owned => tr.rlAudienceOwned,
                                  ReleaseAudience.specific =>
                                    tr.rlAudienceSpecific,
                                  _ => tr.rlAudienceAll,
                                }),
                              ),
                              CrmColumn(
                                label: tr.rlInstaller,
                                flex: 2,
                                cell: (r) => CellText(
                                  r.installer?.name ??
                                      (r.hasExternalLink ? tr.rlExternalUrl : ''),
                                  secondary: r.installer == null
                                      ? null
                                      : Formatters.fileSize(r.installer!.size),
                                ),
                              ),
                              CrmColumn(
                                label: tr.colStatus,
                                width: 120,
                                cell: (r) => StatusBadge(
                                  label: r.isPublished
                                      ? tr.rlPublished
                                      : tr.rlDraft,
                                  color: r.isPublished
                                      ? context.crm.success
                                      : context.crm.warning,
                                ),
                              ),
                              CrmColumn(
                                label: '',
                                width: 100,
                                cell: (r) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (r.hasInstaller)
                                      IconButton(
                                        tooltip: tr.ivDownload,
                                        icon: const Icon(
                                          Icons.download_outlined,
                                          size: 20,
                                        ),
                                        onPressed: () => _download(r),
                                      ),
                                    IconButton(
                                      tooltip: tr.actionDelete,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                      ),
                                      onPressed: controller.busyIds.contains(r.id)
                                          ? null
                                          : () => _delete(r),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (rows.isNotEmpty)
                        PaginationBar(
                          page: page,
                          onPageChanged: controller.goToPage,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
