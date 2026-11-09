import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../network/api_exceptions.dart';

/// Toast-style feedback. Success is only shown after the API confirmed.
class AppFeedback {
  const AppFeedback._();

  static void success(String message) =>
      _show(message, icon: Icons.check_circle_outline, tone: _Tone.success);

  static void warning(String message) =>
      _show(message, icon: Icons.warning_amber_rounded, tone: _Tone.warning);

  static void error(Object error, {String? prefix}) {
    final message = error is ApiException ? _describe(error) : error.toString();
    _show(
      prefix == null ? message : '$prefix\n$message',
      icon: Icons.error_outline,
      tone: _Tone.error,
      duration: const Duration(seconds: 7),
    );
  }

  static String _describe(ApiException e) {
    if (e is ValidationException && e.allMessages.isNotEmpty) {
      return '${e.message}\n• ${e.allMessages.take(4).join('\n• ')}';
    }
    return e.message;
  }

  static void _show(
    String message, {
    required IconData icon,
    required _Tone tone,
    Duration duration = const Duration(seconds: 4),
  }) {
    final context = Get.context;
    if (context == null) return;
    final crm = context.crm;
    final (bg, fg) = switch (tone) {
      _Tone.success => (crm.successContainer, crm.success),
      _Tone.warning => (crm.warningContainer, crm.warning),
      _Tone.error => (crm.dangerContainer, crm.danger),
    };
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          style: TextStyle(color: context.colors.onSurface, fontSize: 13.5),
        ),
        icon: Icon(icon, color: fg),
        backgroundColor: bg,
        borderColor: fg.withValues(alpha: 0.35),
        borderWidth: 1,
        borderRadius: 10,
        maxWidth: 520,
        margin: const EdgeInsets.all(20),
        snackPosition: SnackPosition.BOTTOM,
        duration: duration,
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 220),
      ),
    );
  }
}

enum _Tone { success, warning, error }
