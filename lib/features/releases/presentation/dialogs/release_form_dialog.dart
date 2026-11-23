import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/named_ref.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../prospects/presentation/dialogs/prospect_search_dialog.dart';
import '../../data/models/product_release.dart';
import '../controllers/releases_controllers.dart';

import 'package:hugeicons/hugeicons.dart';
/// Create / edit a release. Resolves with the saved release or null.
Future<ProductRelease?> showReleaseFormDialog({ProductRelease? release}) =>
    showControllerDialog<ReleaseFormController, ProductRelease>(
      controller: ReleaseFormController(
        repository: Get.find(),
        existing: release,
      ),
      builder: (c) => _ReleaseFormDialog(c: c),
    );

class _ReleaseFormDialog extends StatelessWidget {
  const _ReleaseFormDialog({required this.c});

  final ReleaseFormController c;

  Future<void> _submit() async {
    final saved = await c.submit();
    if (saved != null) Get.back(result: saved);
  }

  Future<void> _addCustomer() async {
    final picked = await showProspectSearchDialog(
      productId: c.productId.value,
    );
    if (picked != null) {
      c.addCustomer(NamedRef(id: picked.id, name: picked.companyName));
    }
  }

  String _audienceLabel(String a) => switch (a) {
    ReleaseAudience.owned => tr.rlAudienceOwned,
    ReleaseAudience.specific => tr.rlAudienceSpecific,
    _ => tr.rlAudienceAll,
  };

  @override
  Widget build(BuildContext context) {
    final lookups = Get.find<LookupService>();
    return Obx(
      () => FormDialog(
        title: c.isEdit ? tr.rlEdit : tr.rlNew,
        icon: HugeIcons.strokeRoundedDownload04,
        width: 640,
        busy: c.isSubmitting.value,
        errorMessage: c.errorMessage.value,
        onSubmit: _submit,
        onCancel: () => Get.back(),
        child: Form(
          key: c.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                initialValue: c.productId.value,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: tr.fieldProduct,
                  errorText: c.productError,
                ),
                items: [
                  for (final p in lookups.activeProducts)
                    DropdownMenuItem(value: p.id, child: Text(p.name)),
                ],
                onChanged: c.isSubmitting.value
                    ? null
                    : (v) => c.productId.value = v,
              ),
              const SizedBox(height: 14),
              FormRow(
                children: [
                  TextFormField(
                    controller: c.version,
                    enabled: !c.isSubmitting.value,
                    decoration: InputDecoration(labelText: tr.rlVersion),
                    validator: c.validateVersion,
                  ),
                  DateTimeField(
                    label: tr.rlDate,
                    value: c.date.value,
                    errorText: c.dateError,
                    enabled: !c.isSubmitting.value,
                    onChanged: (v) => c.date.value = v,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: c.changelog,
                enabled: !c.isSubmitting.value,
                minLines: 4,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: tr.rlChangelog,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: c.audience.value,
                isExpanded: true,
                decoration: InputDecoration(labelText: tr.rlAudience),
                items: [
                  for (final a in ReleaseAudience.values)
                    DropdownMenuItem(value: a, child: Text(_audienceLabel(a))),
                ],
                onChanged: c.isSubmitting.value
                    ? null
                    : (v) => c.audience.value = v ?? ReleaseAudience.all,
              ),
              if (c.audience.value == ReleaseAudience.specific) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final cu in c.customers)
                      InputChip(
                        label: Text(cu.name),
                        onDeleted: () => c.removeCustomer(cu),
                      ),
                    ActionChip(
                      avatar: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 16),
                      label: Text(tr.rlCustomers),
                      onPressed: _addCustomer,
                    ),
                  ],
                ),
                if (c.customersError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      c.customersError!,
                      style: TextStyle(color: context.colors.error),
                    ),
                  ),
              ],
              const SizedBox(height: 18),
              FormSectionLabel(tr.rlInstaller),
              _InstallerPicker(c: c),
              const SizedBox(height: 14),
              TextFormField(
                controller: c.downloadUrl,
                enabled: !c.isSubmitting.value,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: tr.rlExternalUrl,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(8),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedLink01, size: 18),
                  ),
                ),
                validator: c.validateUrl,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr.rlPublished),
                value: c.isPublished.value,
                onChanged: c.isSubmitting.value
                    ? null
                    : (v) => c.isPublished.value = v,
              ),
              if (c.isSubmitting.value && c.newInstaller.value != null) ...[
                const SizedBox(height: 8),
                Text(tr.rlUploading),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: c.progress.value),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InstallerPicker extends StatelessWidget {
  const _InstallerPicker({required this.c});

  final ReleaseFormController c;

  @override
  Widget build(BuildContext context) {
    final current = c.currentInstaller;
    final busy = c.isSubmitting.value;
    return Row(
      children: [
        Expanded(
          child: Text(
            current == null
                ? tr.rlInstallerHint
                : '${current.name} · ${Formatters.fileSize(current.size)}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: busy ? null : c.pickInstaller,
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedAttachment, size: 18),
          label: Text(tr.rlPickInstaller),
        ),
        if (current != null)
          IconButton(
            tooltip: tr.rlRemoveInstaller,
            onPressed: busy ? null : c.clearInstaller,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02),
          ),
      ],
    );
  }
}
