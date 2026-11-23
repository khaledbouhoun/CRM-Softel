import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/l10n/l10n.dart';
import '../../app/theme/app_theme.dart';
import 'app_feedback.dart';
import 'whatsapp_button.dart';

/// The one way a phone number is shown in tables and detail headers: the
/// number (tap to copy) followed by the green WhatsApp shortcut. Shows `—`
/// when there is no number.
class PhoneCell extends StatelessWidget {
  const PhoneCell(this.phone, {super.key, this.message, this.compact = false});

  final String? phone;

  /// Optional first WhatsApp message.
  final String? message;

  /// Smaller button, for dense rows and headers.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final value = phone?.trim();
    if (value == null || value.isEmpty) {
      return Text('—', style: context.text.bodyMedium);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Tooltip(
            message: tr.phoneTapToCopy,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: value));
                AppFeedback.success(tr.phoneCopied);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        WhatsAppIconButton(
          phone: value,
          message: message,
          size: compact ? 24 : 28,
          iconSize: compact ? 16 : 20,
        ),
      ],
    );
  }
}
