import '../../app/l10n/l10n.dart';

/// Client-side form validators. They exist for usability only; the Laravel
/// backend remains the authority and its 422 messages are always displayed.
///
/// Each validator returns `null` when valid, otherwise a French message.
class Validators {
  const Validators._();

  static final _emailRegex = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );
  static final _phoneAllowed = RegExp(r'^[0-9+().\-\s/]+$');
  static final _hexColor = RegExp(r'^#[0-9A-Fa-f]{6}$');

  static String? required(String? value, {String? field}) {
    if (value == null || value.trim().isEmpty) {
      return tr.validRequired(field ?? tr.validThisField);
    }
    return null;
  }

  static String? minLength(String? value, int min) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || text.length >= min) return null;
    return tr.validMinLength(min);
  }

  static String? maxLength(String? value, int max) {
    if (value != null && value.trim().length > max) {
      return tr.validMaxLength(max);
    }
    return null;
  }

  /// Optional email: empty is valid.
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > 255 || !_emailRegex.hasMatch(v)) {
      return tr.validEmailInvalid;
    }
    return null;
  }

  /// Optional phone number: digits with common separators, 6 to 20 digits.
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_phoneAllowed.hasMatch(v)) {
      return tr.validPhoneChars;
    }
    final digits = v.replaceAll(RegExp(r'\D'), '').length;
    if (digits < 6 || digits > 20) {
      return tr.validPhoneLength;
    }
    return null;
  }

  static String? hexColor(String? value) {
    if (value == null || !_hexColor.hasMatch(value.trim())) {
      return tr.validColorInvalid;
    }
    return null;
  }

  /// API base URL such as `http://192.168.1.100:8000/api/v1`.
  static String? apiBaseUrl(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return tr.validServerRequired;
    final withScheme = v.contains('://') ? v : 'http://$v';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) {
      return tr.validServerInvalid;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return tr.validServerScheme;
    }
    return null;
  }

  /// Runs validators in order and returns the first error.
  static String? combine(List<String? Function()> validators) {
    for (final validate in validators) {
      final error = validate();
      if (error != null) return error;
    }
    return null;
  }
}
