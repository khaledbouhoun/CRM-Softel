import '../../../../core/utils/json_utils.dart';

/// One documented field of a settings section.
class HelpField {
  const HelpField({required this.key, required this.label, this.help, this.example});

  final String key;
  final String label;
  final String? help;
  final String? example;

  factory HelpField.fromJson(String key, JsonMap json) => HelpField(
    key: key,
    label: asString(json['label'], fallback: key),
    help: asStringOrNull(json['help']),
    example: asStringOrNull(json['example']),
  );
}

/// Explanation of a settings/parameters section (`GET /settings/help/{section}`).
class SettingsHelp {
  const SettingsHelp({required this.title, this.help, this.fields = const []});

  final String title;
  final String? help;
  final List<HelpField> fields;

  factory SettingsHelp.fromJson(JsonMap json) {
    final raw = asMapOrNull(json['fields']) ?? const <String, dynamic>{};
    return SettingsHelp(
      title: asString(json['title']),
      help: asStringOrNull(json['help']),
      fields: [
        for (final e in raw.entries)
          if (asMapOrNull(e.value) != null)
            HelpField.fromJson(e.key, asMapOrNull(e.value)!),
      ],
    );
  }

  /// Backend section keys use underscores (`appointment_types`) while config
  /// entities use dashes (`appointment-types`).
  static String sectionKey(String entity) => entity.replaceAll('-', '_');
}
