import '../../../../core/utils/json_utils.dart';

/// A configuration row (`/config/{entity}`) kept as typed accessors over its
/// JSON. The generic settings screens edit any entity through this class;
/// strongly typed views ([AppointmentType], [InterventionStatus], ...) are
/// derived from it where the business logic needs them.
class ConfigRow {
  const ConfigRow(this.data);

  final JsonMap data;

  int get id => asInt(data['id']);
  bool get isActive => asBool(data['is_active'], fallback: true);
  String get name => asString(data['name'], fallback: asString(data['title']));
  String? str(String key) => asStringOrNull(data[key]);
  int? intValue(String key) => asIntOrNull(data[key]);
  bool boolValue(String key) => asBool(data[key]);

  factory ConfigRow.fromJson(JsonMap json) => ConfigRow(json);
}

/// A type of meeting (demo, training, accompaniment ...). The `group` decides
/// the workflow: `accompaniment` creates a series, `demo` is customer-bookable.
class AppointmentType {
  const AppointmentType({
    required this.id,
    required this.code,
    required this.name,
    required this.group,
    this.defaultDurationMinutes = 60,
    this.color,
    this.customerBookable = false,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final int id;
  final String code;
  final String name;
  final String group;
  final int defaultDurationMinutes;
  final String? color;
  final bool customerBookable;
  final int sortOrder;
  final bool isActive;

  bool get isTraining => group == 'training';
  bool get isAccompaniment => group == 'accompaniment';

  @override
  bool operator ==(Object other) => other is AppointmentType && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory AppointmentType.fromJson(JsonMap json) => AppointmentType(
    id: asInt(json['id']),
    code: asString(json['code']),
    name: asString(json['name']),
    group: asString(json['group']),
    defaultDurationMinutes: asInt(
      json['default_duration_minutes'],
      fallback: 60,
    ),
    color: asStringOrNull(json['color']),
    customerBookable: asBool(json['customer_bookable']),
    sortOrder: asInt(json['sort_order']),
    isActive: asBool(json['is_active'], fallback: true),
  );
}

/// Bug / question / remark / fix / release ... (configurable).
class InterventionType {
  const InterventionType({
    required this.id,
    required this.code,
    required this.name,
    this.source = 'both',
    this.color,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final int id;
  final String code;
  final String name;

  /// `customer`, `employee` or `both`: who may create this type.
  final String source;
  final String? color;
  final int sortOrder;
  final bool isActive;

  bool get allowsEmployee => source == 'employee' || source == 'both';

  @override
  bool operator ==(Object other) => other is InterventionType && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory InterventionType.fromJson(JsonMap json) => InterventionType(
    id: asInt(json['id']),
    code: asString(json['code']),
    name: asString(json['name']),
    source: asString(json['source'], fallback: 'both'),
    color: asStringOrNull(json['color']),
    sortOrder: asInt(json['sort_order']),
    isActive: asBool(json['is_active'], fallback: true),
  );
}

/// Workflow status of an intervention. [customerLabel] is what the customer
/// sees; [name] is the internal label.
class InterventionStatus {
  const InterventionStatus({
    required this.id,
    required this.code,
    required this.name,
    required this.customerLabel,
    this.color,
    this.isInitial = false,
    this.isClosed = false,
    this.awaitsCustomer = false,
    this.isDelivered = false,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final int id;
  final String code;
  final String name;
  final String customerLabel;
  final String? color;
  final bool isInitial;
  final bool isClosed;
  final bool awaitsCustomer;
  final bool isDelivered;
  final int sortOrder;
  final bool isActive;

  factory InterventionStatus.fromJson(JsonMap json) => InterventionStatus(
    id: asInt(json['id']),
    code: asString(json['code']),
    name: asString(json['name']),
    customerLabel: asString(
      json['customer_label'],
      fallback: asString(json['name']),
    ),
    color: asStringOrNull(json['color']),
    isInitial: asBool(json['is_initial']),
    isClosed: asBool(json['is_closed']),
    awaitsCustomer: asBool(json['awaits_customer']),
    isDelivered: asBool(json['is_delivered']),
    sortOrder: asInt(json['sort_order']),
    isActive: asBool(json['is_active'], fallback: true),
  );
}

class InterventionPriority {
  const InterventionPriority({
    required this.id,
    required this.code,
    required this.name,
    this.color,
    this.responseTargetHours,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final int id;
  final String code;
  final String name;
  final String? color;

  /// Response target in hours (null = none).
  final int? responseTargetHours;
  final int sortOrder;
  final bool isActive;

  factory InterventionPriority.fromJson(JsonMap json) => InterventionPriority(
    id: asInt(json['id']),
    code: asString(json['code']),
    name: asString(json['name']),
    color: asStringOrNull(json['color']),
    responseTargetHours: asIntOrNull(json['response_target_hours']),
    sortOrder: asInt(json['sort_order']),
    isActive: asBool(json['is_active'], fallback: true),
  );
}

/// A customer-facing training / documentation link of a product.
class ProductResource {
  const ProductResource({
    required this.id,
    required this.productId,
    required this.title,
    required this.url,
    this.kind = 'link',
    this.customerVisible = false,
    this.isTrainingMaterial = false,
    this.isActive = true,
  });

  final int id;
  final int productId;
  final String title;
  final String url;
  final String kind;
  final bool customerVisible;
  final bool isTrainingMaterial;
  final bool isActive;

  factory ProductResource.fromJson(JsonMap json) => ProductResource(
    id: asInt(json['id']),
    productId: asInt(json['product_id']),
    title: asString(json['title']),
    url: asString(json['url']),
    kind: asString(json['kind'], fallback: 'link'),
    customerVisible: asBool(json['customer_visible']),
    isTrainingMaterial: asBool(json['is_training_material']),
    isActive: asBool(json['is_active'], fallback: true),
  );
}
