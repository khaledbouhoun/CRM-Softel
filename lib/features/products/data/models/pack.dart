import '../../../../core/utils/json_utils.dart';

class Pack {
  const Pack({
    required this.id,
    required this.name,
    required this.code,
    this.description,
  });

  final int id;
  final String name;
  final String code;
  final String? description;

  factory Pack.fromJson(JsonMap json) => Pack(
    id: asInt(json['id']),
    name: asString(json['name']),
    code: asString(json['code']),
    description: asStringOrNull(json['description']),
  );

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'description': description,
  };

  @override
  bool operator ==(Object other) => other is Pack && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Pack($id, $name)';
}

class PackPayload {
  const PackPayload({
    required this.name,
    required this.code,
    this.description,
  });

  final String name;
  final String code;
  final String? description;

  JsonMap toJson() {
    final desc = description?.trim();
    return {
      'name': name.trim(),
      'code': code.trim().toLowerCase(),
      'description': (desc == null || desc.isEmpty) ? null : desc,
    };
  }
}
