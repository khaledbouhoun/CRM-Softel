import '../utils/json_utils.dart';

/// Minimal `{id, name}` reference embedded in many API payloads (product,
/// customer, prospect).
class NamedRef {
  const NamedRef({required this.id, required this.name});

  final int id;
  final String name;

  static NamedRef? fromJsonOrNull(Object? value) {
    final json = asMapOrNull(value);
    return json == null ? null : NamedRef.fromJson(json);
  }

  factory NamedRef.fromJson(JsonMap json) =>
      NamedRef(id: asInt(json['id']), name: asString(json['name']));

  JsonMap toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) => other is NamedRef && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
