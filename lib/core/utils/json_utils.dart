/// Tolerant readers for JSON values coming from the Laravel API.
///
/// Laravel / MySQL may serialize booleans as `0`/`1`, ids as strings, etc.
/// These helpers normalize such values so models stay simple.
library;

typedef JsonMap = Map<String, dynamic>;

int? asIntOrNull(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

int asInt(Object? value, {int fallback = 0}) => asIntOrNull(value) ?? fallback;

String? asStringOrNull(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

String asString(Object? value, {String fallback = ''}) =>
    asStringOrNull(value) ?? fallback;

bool asBool(Object? value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case '1':
      case 'true':
      case 'yes':
        return true;
      case '0':
      case 'false':
      case 'no':
        return false;
    }
  }
  return fallback;
}

/// Parses an ISO-8601 value and converts it to local time.
DateTime? asDateTimeOrNull(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value.toLocal();
  final parsed = DateTime.tryParse(value.toString().trim());
  return parsed?.toLocal();
}

JsonMap? asMapOrNull(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return null;
}

List<T> asList<T>(Object? value, T Function(JsonMap json) fromJson) {
  if (value is! List) return <T>[];
  return value
      .map(asMapOrNull)
      .whereType<JsonMap>()
      .map(fromJson)
      .toList(growable: false);
}

/// Serializes a local date-time with its UTC offset, e.g.
/// `2026-11-01T14:30:00+01:00`, so the server never has to guess the zone.
String toApiDateTime(DateTime value) {
  final local = value.toLocal();
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-${two(local.day)}'
      'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}'
      '$sign$hours:$minutes';
}

/// Serializes a calendar date as `YYYY-MM-DD`.
String toApiDate(DateTime value) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-${two(value.day)}';
}

/// Parses a `#RRGGBB` (or `RRGGBB`, `#AARRGGBB`) color into an ARGB int.
int? parseHexColor(String? hex) {
  if (hex == null) return null;
  var cleaned = hex.trim().replaceFirst('#', '');
  if (cleaned.length == 6) cleaned = 'FF$cleaned';
  if (cleaned.length != 8) return null;
  return int.tryParse(cleaned, radix: 16);
}

/// Formats an ARGB int as `#RRGGBB` (alpha is dropped).
String toHexColor(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
