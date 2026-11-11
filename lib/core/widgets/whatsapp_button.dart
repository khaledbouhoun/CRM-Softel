import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../utils/whatsapp_launcher.dart';

/// Modern pill-shaped button to open WhatsApp.
///
/// Typically placed next to phone numbers on detail pages.
class WhatsAppButton extends StatefulWidget {
  const WhatsAppButton({super.key, required this.phone, this.label = 'WhatsApp', this.message, this.dense = false});

  final String? phone;
  final String label;
  final String? message;
  final bool dense;

  @override
  State<WhatsAppButton> createState() => _WhatsAppButtonState();
}

class _WhatsAppButtonState extends State<WhatsAppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final valid = WhatsAppLauncher.isValid(widget.phone);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseGreen = isDark ? const Color(0xFF22C55E) : const Color(0xFF25D366);
    final textGreen = isDark ? const Color(0xFF4ADE80) : const Color(0xFF0F7A3E);

    final tooltip = valid ? '${WhatsAppLauncher.tooltip} (${widget.phone})' : WhatsAppLauncher.noPhoneMessage;

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: valid ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: !valid
                ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04))
                : (_isHovered
                      ? baseGreen.withValues(alpha: isDark ? 0.28 : 0.22)
                      : baseGreen.withValues(alpha: isDark ? 0.16 : 0.12)),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: !valid
                  ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.12))
                  : (_isHovered ? baseGreen.withValues(alpha: 0.7) : baseGreen.withValues(alpha: 0.35)),
              width: 1,
            ),
            boxShadow: (valid && _isHovered)
                ? [BoxShadow(color: baseGreen.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: valid ? () => WhatsAppLauncher.launch(widget.phone, text: widget.message) : null,
              splashColor: baseGreen.withValues(alpha: 0.3),
              highlightColor: baseGreen.withValues(alpha: 0.15),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.dense ? 8 : 10, vertical: widget.dense ? 3 : 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.whatsapp,
                      size: widget.dense ? 13 : 15,
                      color: valid ? baseGreen : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: widget.dense ? 11.5 : 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: valid ? textGreen : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern compact icon button to open WhatsApp.
///
/// Designed for table rows and action toolbars (prospects list, follow-ups list).
class WhatsAppIconButton extends StatefulWidget {
  const WhatsAppIconButton({
    super.key,
    required this.phone,
    this.message,
    this.size = 32,
    this.iconSize = 16,
    this.tooltip,
  });

  final String? phone;
  final String? message;
  final double size;
  final double iconSize;
  final String? tooltip;

  @override
  State<WhatsAppIconButton> createState() => _WhatsAppIconButtonState();
}

class _WhatsAppIconButtonState extends State<WhatsAppIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final valid = WhatsAppLauncher.isValid(widget.phone);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseGreen = isDark ? const Color(0xFF22C55E) : const Color(0xFF25D366);

    final tooltip =
        widget.tooltip ?? (valid ? '${WhatsAppLauncher.tooltip} (${widget.phone})' : WhatsAppLauncher.noPhoneMessage);

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: valid ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: !valid
                ? Colors.transparent
                : (_isHovered ? baseGreen.withValues(alpha: isDark ? 0.24 : 0.16) : Colors.transparent),
            shape: BoxShape.circle,
            border: (valid && _isHovered) ? Border.all(color: baseGreen.withValues(alpha: 0.4), width: 1) : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: valid ? () => WhatsAppLauncher.launch(widget.phone, text: widget.message) : null,
              splashColor: baseGreen.withValues(alpha: 0.25),
              highlightColor: baseGreen.withValues(alpha: 0.12),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.whatsapp,
                  size: widget.iconSize,
                  color: valid ? baseGreen : theme.colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
