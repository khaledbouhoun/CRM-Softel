import 'dart:io';

/// Who is using this workstation. There is no employee login in the CRM (all
/// employees share the same access level), so the Windows user name is the
/// audit label sent in `X-Employee-Name` on write requests and the
/// `assigned_employee` value of assignments.
class EmployeeIdentity {
  EmployeeIdentity({String? username, String? deviceName})
    : username = _clean(username ?? _detectUser()),
      deviceName = _clean(deviceName ?? _detectDevice());

  final String username;
  final String deviceName;

  /// Stable id for the heartbeat (`user@computer`, max 50 characters).
  String get employeeId {
    final id = deviceName.isEmpty ? username : '$username@$deviceName';
    return id.length > 50 ? id.substring(0, 50) : id;
  }

  /// Header value, or null when no usable (ASCII) name is known. HTTP headers
  /// cannot carry arbitrary Unicode, so other characters are dropped.
  String? get headerValue {
    final ascii = username.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
    if (ascii.isEmpty) return null;
    return ascii.length > 100 ? ascii.substring(0, 100) : ascii;
  }

  static String _clean(String value) => value.trim();

  static String _detectUser() {
    try {
      return Platform.environment['USERNAME'] ??
          Platform.environment['USER'] ??
          '';
    } catch (_) {
      return '';
    }
  }

  static String _detectDevice() {
    try {
      return Platform.environment['COMPUTERNAME'] ??
          Platform.environment['HOSTNAME'] ??
          '';
    } catch (_) {
      return '';
    }
  }
}
