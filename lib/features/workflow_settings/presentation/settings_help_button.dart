import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/l10n/l10n.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/api_response.dart';
import '../data/models/settings_help.dart';

/// Info icon that opens the explanation (with examples) of a settings
/// section. [section] is the backend key, e.g. `scheduling` or
/// `appointment_types`.
class SettingsHelpButton extends StatelessWidget {
  const SettingsHelpButton({super.key, required this.section});

  final String section;

  static Future<SettingsHelp> _fetch(String section) async => SettingsHelp.fromJson(
    ApiResponse.object(
      await Get.find<ApiClient>().get(ApiEndpoints.settingsHelp(section)),
    ),
  );

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tr.helpTooltip,
    icon: const Icon(Icons.info_outline),
    onPressed: () => Get.dialog<void>(_HelpDialog(future: _fetch(section))),
  );
}

class _HelpDialog extends StatelessWidget {
  const _HelpDialog({required this.future});

  final Future<SettingsHelp> future;

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 560,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: FutureBuilder<SettingsHelp>(
        future: future,
        builder: (context, snapshot) {
          final help = snapshot.data;
          Widget body;
          if (help != null) {
            body = _content(context, help);
          } else if (snapshot.hasError) {
            final e = ApiException.from(snapshot.error!);
            body = Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                e is NotFoundException ? tr.helpUnavailable : e.message,
              ),
            );
          } else {
            body = const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 12, 0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: context.colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        help?.title ?? tr.helpTooltip,
                        style: context.text.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: tr.actionClose,
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back<void>(),
                    ),
                  ],
                ),
              ),
              Flexible(child: body),
            ],
          );
        },
      ),
    ),
  );

  Widget _content(BuildContext context, SettingsHelp help) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (help.help != null) Text(help.help!, style: context.text.bodyLarge),
        if (help.fields.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(tr.helpFields, style: context.text.titleSmall),
          const SizedBox(height: 8),
          for (final f in help.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.label, style: context.text.labelLarge),
                  if (f.help != null) Text(f.help!),
                  if (f.example != null)
                    Text(
                      '${tr.helpExample} : ${f.example}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ],
    ),
  );
}
