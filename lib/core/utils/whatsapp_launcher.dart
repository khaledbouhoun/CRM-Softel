import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/l10n/l10n.dart';
import '../widgets/app_feedback.dart';

/// Helper to sanitize phone numbers and launch WhatsApp chats.
class WhatsAppLauncher {
  const WhatsAppLauncher._();

  static const Color brandColor = Color(0xFF25D366);

  /// Cleans and formats a phone number into WhatsApp international format.
  ///
  /// Removes separators (spaces, dashes, parentheses, slashes).
  /// Converts domestic Algerian numbers (starting with 0, 9-10 digits) by
  /// prepending the Algerian country code (+213) and removing the leading 0.
  /// Handles numbers starting with '+' or '00' by stripping those prefixes.
  static String? sanitize(String? phone) {
    if (phone == null) return null;
    var cleaned = phone.replaceAll(RegExp(r'[\s\-()./]+'), '');
    if (cleaned.isEmpty) return null;

    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    } else if (cleaned.startsWith('00')) {
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length >= 9 && cleaned.length <= 10) {
      cleaned = '213${cleaned.substring(1)}';
    }

    cleaned = cleaned.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 6) return null;
    return cleaned;
  }

  /// Whether [phone] contains a usable phone number for WhatsApp.
  static bool isValid(String? phone) => sanitize(phone) != null;

  /// Builds the `https://wa.me/<number>` URI.
  static Uri? getUri(String? phone, {String? text}) {
    final sanitized = sanitize(phone);
    if (sanitized == null) return null;
    final query = (text != null && text.trim().isNotEmpty)
        ? {'text': text.trim()}
        : null;
    return Uri.https('wa.me', '/$sanitized', query);
  }

  /// Launches WhatsApp in an external application or browser.
  static Future<bool> launch(String? phone, {String? text}) async {
    final uri = getUri(phone, text: text);
    if (uri == null) {
      AppFeedback.warning(invalidPhoneMessage);
      return false;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppFeedback.error(errorLaunchMessage);
        return false;
      }
      return true;
    } catch (e) {
      AppFeedback.error(errorLaunchMessage);
      return false;
    }
  }

  static String get tooltip => switch (L10n.current.languageCode) {
    'ar' => 'مراسلة عبر واتساب',
    'en' => 'Chat on WhatsApp',
    _ => 'Discuter sur WhatsApp',
  };

  static String get noPhoneMessage => switch (L10n.current.languageCode) {
    'ar' => 'لا يوجد رقم هاتف',
    'en' => 'No phone number available',
    _ => 'Aucun numéro de téléphone',
  };

  static String get invalidPhoneMessage => switch (L10n.current.languageCode) {
    'ar' => 'رقم الهاتف غير صالح لواتساب',
    'en' => 'Invalid phone number for WhatsApp',
    _ => 'Numéro de téléphone non valide pour WhatsApp',
  };

  static String get errorLaunchMessage => switch (L10n.current.languageCode) {
    'ar' => 'تعذر فتح واتساب',
    'en' => 'Could not open WhatsApp',
    _ => 'Impossible d’ouvrir WhatsApp',
  };
}
