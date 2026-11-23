import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/file_access.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/workflow_widgets.dart';
import '../../data/models/intervention.dart';
import '../controllers/interventions_controllers.dart';

import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/huge_data.dart';
import '../../../../core/widgets/animated_entrance.dart';
/// Avatar of a chat sender: the account picture when the API gives an https
/// one, otherwise the initials.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key, required this.name, this.url, this.size = 32});

  final String? name;
  final String? url;
  final double size;

  static String initials(String? name) {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts.last.characters.first : '';
    return (first + second).toUpperCase();
  }

  /// Only https pictures are loaded (never an arbitrary scheme).
  static bool isSafeUrl(String? url) {
    final uri = url == null ? null : Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: context.colors.secondaryContainer,
      child: Text(
        initials(name),
        style: context.text.labelMedium?.copyWith(
          color: context.colors.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: isSafeUrl(url)
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              )
            : fallback,
      ),
    );
  }
}

/// One conversation entry.
///
/// * Employee messages: right side, brand colour, "Support" badge.
/// * Client messages: left side, neutral colours, avatar and name.
/// * Internal notes stay employee-side but wear a warning tint and a lock
///   badge, so a note is never mistaken for a reply the customer can read.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.controller});

  final InterventionMessage message;
  final InterventionDetailController controller;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    final scheme = context.colors;
    final employee = message.isFromEmployee;
    final internal = message.isInternal;

    final Color background;
    final Color foreground;
    final BorderSide border;
    if (!employee) {
      background = scheme.surfaceContainerLowest;
      foreground = scheme.onSurface;
      border = BorderSide(color: scheme.outlineVariant);
    } else if (internal) {
      background = crm.warning.withValues(alpha: 0.12);
      foreground = scheme.onSurface;
      border = BorderSide(color: crm.warning.withValues(alpha: 0.6));
    } else {
      background = scheme.primary;
      foreground = scheme.onPrimary;
      border = BorderSide(color: scheme.primary);
    }

    final name =
        message.displayName ??
        (employee ? tr.wfSourceEmployee : tr.wfSourceCustomer);
    final meta = foreground.withValues(alpha: 0.75);

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadiusDirectional.only(
          topStart: const Radius.circular(AppRadius.lg),
          topEnd: const Radius.circular(AppRadius.lg),
          bottomStart: Radius.circular(employee ? AppRadius.lg : 4),
          bottomEnd: Radius.circular(employee ? 4 : AppRadius.lg),
        ),
        border: Border.fromBorderSide(border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                name,
                style: context.text.labelLarge?.copyWith(color: foreground),
              ),
              if (employee && !internal) _SupportBadge(color: foreground),
              if (internal) VisibilityBadge(internal: true),
              Text(
                Formatters.dateTime(message.createdAt),
                style: context.text.bodySmall?.copyWith(color: meta),
              ),
            ],
          ),
          if (message.body.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            DefaultTextStyle.merge(
              style: TextStyle(color: foreground),
              child: SelectableText(message.body),
            ),
          ],
          if (message.attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in message.attachments)
                  AttachmentTile(attachment: a, controller: controller),
              ],
            ),
          ],
        ],
      ),
    );

    final avatar = ChatAvatar(
      name: name,
      url: message.sender?.avatarUrl,
      size: 32,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: employee
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!employee) ...[avatar, const SizedBox(width: 8)],
            Flexible(child: bubble),
            if (employee) ...[const SizedBox(width: 8), avatar],
          ],
        ),
      ),
    );
  }
}

class _SupportBadge extends StatelessWidget {
  const _SupportBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: HugeIcons.strokeRoundedHeadset, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          tr.ivSupport,
          style: context.text.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

/// Timeline event (status change, reopening) as a centred, subtle pill.
class ChatEventPill extends StatelessWidget {
  const ChatEventPill({super.key, required this.message});

  final InterventionMessage message;

  /// The sentence shown in the pill.
  static String label(InterventionMessage m) {
    final event = m.event;
    if (event == null) return m.body;
    final actor = event.actorName ?? m.displayName ?? tr.ivSystem;
    final time = Formatters.dateTime(event.at ?? m.createdAt);
    if (event.isReopen) return tr.ivEventReopened(actor, time);
    final to = event.newStatus?.name ?? '—';
    final from = event.oldStatus?.name;
    // Generated signatures list their parameters alphabetically.
    return from == null
        ? tr.ivEventStatusTo(actor, time, to)
        : tr.ivEventStatusFull(actor, from, time, to);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final reopened = message.event?.isReopen ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(icon: 
                reopened ? HugeIcons.strokeRoundedLockOpen : HugeIcons.strokeRoundedArrowLeftRight,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label(message),
                  textAlign: TextAlign.center,
                  style: context.text.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner replacing the composer when `can_reply` is false.
class ClosedInterventionBanner extends StatelessWidget {
  const ClosedInterventionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final warning = context.crm.warning;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          HugeIcon(icon: HugeIcons.strokeRoundedLock, size: 20, color: warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(tr.ivClosedBanner, style: context.text.bodyMedium),
          ),
        ],
      ),
    );
  }
}

HugeData _iconFor(String name) => switch (FileAccess.extensionOf(name)) {
  'exe' => HugeIcons.strokeRoundedSettings02,
  'zip' || 'rar' => HugeIcons.strokeRoundedFileZip,
  'docx' || 'doc' => HugeIcons.strokeRoundedFile01,
  'txt' => HugeIcons.strokeRoundedFile01,
  'pdf' => HugeIcons.strokeRoundedPdf01,
  _ => HugeIcons.strokeRoundedFile01,
};

/// An attachment: thumbnail for images, PDF tile (view / download) and a
/// plain file tile (name, icon, size, Download) for everything else.
class AttachmentTile extends StatelessWidget {
  const AttachmentTile({
    super.key,
    required this.attachment,
    required this.controller,
  });

  final InterventionAttachment attachment;
  final InterventionDetailController controller;

  bool get _isImage =>
      attachment.isPreviewable &&
      FileAccess.isImage(mime: attachment.mime, name: attachment.name);

  bool get _isPdf =>
      attachment.isPreviewable &&
      FileAccess.isPdf(mime: attachment.mime, name: attachment.name);

  Future<void> _save() async {
    final result = await controller.saveAttachment(attachment);
    result.isSuccess
        ? AppFeedback.success(tr.ivFileSaved(result.value ?? ''))
        : AppFeedback.error(result.error!);
  }

  Future<void> _openPdf() async {
    final result = await controller.openAttachment(attachment);
    if (!result.isSuccess) AppFeedback.error(result.error!);
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return _ImageThumb(attachment: attachment, controller: controller);
    }
    final scheme = context.colors;
    final crm = context.crm;
    final hotfix = attachment.isHotfix;
    final accent = hotfix ? crm.warning : scheme.primary;
    final meta = [
      FileAccess.extensionOf(attachment.name).toUpperCase(),
      Formatters.fileSize(attachment.size),
    ].where((e) => e.isNotEmpty).join(' · ');
    return Container(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hotfix ? crm.warningContainer : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hotfix ? crm.warning.withValues(alpha: 0.6) : scheme.outlineVariant,
          width: hotfix ? 1.5 : 1,
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: scheme.onSurface),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hotfix) ...[
              HotfixChip(label: tr.ivHotfixLabel),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: HugeIcon(icon: _iconFor(attachment.name), size: 24, color: accent),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        attachment.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelLarge,
                      ),
                      if (meta.isNotEmpty)
                        Text(
                          meta,
                          style: context.text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (_isPdf)
                  OutlinedButton.icon(
                    style: _compactButton,
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedView, size: 16),
                    label: Text(tr.ivViewPdf),
                    onPressed: _openPdf,
                  ),
                FilledButton.icon(
                  style: _compactButton,
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedDownload04, size: 16),
                  label: Text(tr.ivDownload),
                  onPressed: _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const _compactButton = ButtonStyle(
  visualDensity: VisualDensity.compact,
  padding: WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  textStyle: WidgetStatePropertyAll(
    TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
  ),
);

/// Distinct chip marking a private hotfix / patch file.
class HotfixChip extends StatelessWidget {
  const HotfixChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final warning = context.crm.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: warning.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: HugeIcons.strokeRoundedFirstAidKit, size: 14, color: warning),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: warning,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.attachment, required this.controller});

  final InterventionAttachment attachment;
  final InterventionDetailController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return FutureBuilder<Uint8List>(
      future: controller.previewOf(attachment),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        Widget content;
        if (bytes != null) {
          content = Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _ThumbMessage(tr.ivImageError),
          );
        } else if (snapshot.hasError) {
          content = _ThumbMessage(tr.ivImageError);
        } else {
          content = const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return Tooltip(
          message: attachment.name,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: bytes == null
                ? null
                : () => showImageViewer(
                    controller: controller,
                    attachment: attachment,
                    bytes: bytes,
                  ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: 190,
                height: 130,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThumbMessage extends StatelessWidget {
  const _ThumbMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.text.bodySmall,
      ),
    ),
  );
}

/// Full-screen viewer (pinch / wheel zoom) with a download button.
Future<void> showImageViewer({
  required InterventionDetailController controller,
  required InterventionAttachment attachment,
  required Uint8List bytes,
}) => showAppDialog<void>(
  Dialog.fullscreen(
    backgroundColor: Colors.black,
    child: Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 6,
            child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
          ),
        ),
        PositionedDirectional(
          top: 12,
          start: 12,
          end: 12,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  attachment.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              IconButton(
                tooltip: tr.ivDownload,
                color: Colors.white,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedDownload04),
                onPressed: () async {
                  final result = await controller.saveAttachment(attachment);
                  result.isSuccess
                      ? AppFeedback.success(tr.ivFileSaved(result.value ?? ''))
                      : AppFeedback.error(result.error!);
                },
              ),
              IconButton(
                tooltip: tr.actionClose,
                color: Colors.white,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01),
                onPressed: () => Get.back<void>(),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);

/// Files queued in the composer, removable one by one.
class PendingFilesBar extends StatelessWidget {
  const PendingFilesBar({super.key, required this.controller});

  final InterventionDetailController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final files = controller.pendingFiles.toList();
    if (files.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          for (final f in files)
            InputChip(
              avatar: HugeIcon(icon: _iconFor(f.name), size: 18),
              label: Text('${f.name} · ${Formatters.fileSize(f.size)}'),
              deleteButtonTooltipMessage: tr.ivRemoveFile,
              onDeleted: () => controller.removeFile(f),
            ),
        ],
      ),
    );
  });
}
