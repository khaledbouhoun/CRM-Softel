import '../../../app/l10n/l10n.dart';
import '../domain/workflow_config_repository.dart';

enum ConfigFieldKind {
  text,
  multiline,
  integer,
  boolean,
  color,
  choice,

  /// Intervention status picker (id).
  status,

  /// Product picker (id).
  product,

  /// Calendar date (`YYYY-MM-DD`).
  date,
  url,
}

/// One selectable value of a [ConfigFieldKind.choice] field. The wire value
/// is fixed by the API; the label is localized.
class ConfigOption {
  const ConfigOption(this.value, this.label);

  final String value;
  final String Function() label;
}

/// Describes one editable column of a configuration row so a single generic
/// screen can manage every configurable list.
class ConfigField {
  const ConfigField(
    this.key,
    this.label,
    this.kind, {
    this.required = false,
    this.options = const [],
    this.inTable = true,
    this.immutable = false,
    this.maxLength,
    this.hint,
    this.isCode = false,
    this.nullable = false,
    this.initial,
  });

  final String key;
  final String Function() label;
  final ConfigFieldKind kind;
  final bool required;
  final List<ConfigOption> options;
  final bool inTable;

  /// Cannot change after creation (codes are referenced by other records).
  final bool immutable;
  final int? maxLength;
  final String Function()? hint;

  /// Lower-case identifier (`^[a-z][a-z0-9_]*$`).
  final bool isCode;

  /// Empty value is sent as null.
  final bool nullable;

  /// Default for new rows (string for text/choice, bool, int as string).
  final Object? initial;
}

/// A configurable list served by `/config/{entity}`.
class ConfigSchema {
  const ConfigSchema({
    required this.entity,
    required this.title,
    required this.hint,
    required this.fields,
  });

  final String entity;
  final String Function() title;
  final String Function() hint;
  final List<ConfigField> fields;

  List<ConfigField> get tableFields =>
      fields.where((f) => f.inTable).toList(growable: false);
}

List<ConfigOption> _groups() => [
  ConfigOption('demo', () => tr.wfGroupDemo),
  ConfigOption('meeting', () => tr.wfGroupMeeting),
  ConfigOption('training', () => tr.wfGroupTraining),
  ConfigOption('accompaniment', () => tr.wfGroupAccompaniment),
];

/// Every configurable list. Lists, labels and colors live in the CRM; this
/// only describes their columns. Rows are deactivated, never deleted.
abstract final class ConfigSchemas {
  static final appointmentTypes = ConfigSchema(
    entity: ConfigEntities.appointmentTypes,
    title: () => tr.wfCfgAppointmentTypes,
    hint: () => tr.wfCfgAppointmentTypesHint,
    fields: [
      ConfigField(
        'name',
        () => tr.fieldNameRequired,
        ConfigFieldKind.text,
        required: true,
        maxLength: 120,
      ),
      ConfigField(
        'code',
        () => tr.wfCode,
        ConfigFieldKind.text,
        required: true,
        isCode: true,
        immutable: true,
        maxLength: 40,
      ),
      ConfigField(
        'group',
        () => tr.wfGroup,
        ConfigFieldKind.choice,
        required: true,
        options: _groups(),
        initial: 'meeting',
      ),
      ConfigField(
        'default_duration_minutes',
        () => tr.wfDurationMinutes,
        ConfigFieldKind.integer,
        initial: '60',
      ),
      ConfigField(
        'color',
        () => tr.color,
        ConfigFieldKind.color,
        initial: '#3B82F6',
      ),
      ConfigField(
        'customer_bookable',
        () => tr.wfCustomerBookable,
        ConfigFieldKind.boolean,
        initial: false,
      ),
      ConfigField(
        'sort_order',
        () => tr.wfSortOrder,
        ConfigFieldKind.integer,
        inTable: false,
        initial: '0',
      ),
    ],
  );

  static final holidays = ConfigSchema(
    entity: ConfigEntities.holidays,
    title: () => tr.wfCfgHolidays,
    hint: () => tr.wfCfgHolidaysHint,
    fields: [
      ConfigField(
        'date',
        () => tr.wfDate,
        ConfigFieldKind.date,
        required: true,
      ),
      ConfigField(
        'name',
        () => tr.fieldNameRequired,
        ConfigFieldKind.text,
        required: true,
        maxLength: 150,
      ),
    ],
  );

  static final interventionTypes = ConfigSchema(
    entity: ConfigEntities.interventionTypes,
    title: () => tr.wfCfgInterventionTypes,
    hint: () => tr.wfCfgInterventionTypesHint,
    fields: [
      ConfigField(
        'name',
        () => tr.fieldNameRequired,
        ConfigFieldKind.text,
        required: true,
        maxLength: 120,
      ),
      ConfigField(
        'code',
        () => tr.wfCode,
        ConfigFieldKind.text,
        required: true,
        isCode: true,
        immutable: true,
        maxLength: 40,
      ),
      ConfigField(
        'source',
        () => tr.wfSource,
        ConfigFieldKind.choice,
        required: true,
        initial: 'both',
        options: [
          ConfigOption('customer', () => tr.wfSourceCustomer),
          ConfigOption('employee', () => tr.wfSourceEmployee),
          ConfigOption('both', () => tr.wfSourceBoth),
        ],
      ),
      ConfigField(
        'color',
        () => tr.color,
        ConfigFieldKind.color,
        initial: '#3B82F6',
      ),
      ConfigField(
        'sort_order',
        () => tr.wfSortOrder,
        ConfigFieldKind.integer,
        inTable: false,
        initial: '0',
      ),
    ],
  );

  static final interventionStatuses = ConfigSchema(
    entity: ConfigEntities.interventionStatuses,
    title: () => tr.wfCfgInterventionStatuses,
    hint: () => tr.wfCfgInterventionStatusesHint,
    fields: [
      ConfigField(
        'name',
        () => tr.fieldNameRequired,
        ConfigFieldKind.text,
        required: true,
        maxLength: 120,
      ),
      ConfigField(
        'code',
        () => tr.wfCode,
        ConfigFieldKind.text,
        required: true,
        isCode: true,
        immutable: true,
        maxLength: 40,
      ),
      ConfigField(
        'customer_label',
        () => tr.wfCustomerLabel,
        ConfigFieldKind.text,
        required: true,
        maxLength: 120,
        hint: () => tr.wfCustomerLabelHint,
      ),
      ConfigField(
        'color',
        () => tr.color,
        ConfigFieldKind.color,
        initial: '#3B82F6',
      ),
      ConfigField(
        'is_initial',
        () => tr.wfIsInitial,
        ConfigFieldKind.boolean,
        initial: false,
      ),
      ConfigField(
        'is_closed',
        () => tr.wfIsClosed,
        ConfigFieldKind.boolean,
        initial: false,
      ),
      ConfigField(
        'awaits_customer',
        () => tr.wfAwaitsCustomer,
        ConfigFieldKind.boolean,
        initial: false,
      ),
      ConfigField(
        'is_delivered',
        () => tr.wfIsDelivered,
        ConfigFieldKind.boolean,
        initial: false,
      ),
      ConfigField(
        'sort_order',
        () => tr.wfSortOrder,
        ConfigFieldKind.integer,
        inTable: false,
        initial: '0',
      ),
    ],
  );

  static final interventionTransitions = ConfigSchema(
    entity: ConfigEntities.interventionTransitions,
    title: () => tr.wfCfgTransitions,
    hint: () => tr.wfCfgTransitionsHint,
    fields: [
      ConfigField(
        'from_status_id',
        () => tr.wfFromStatus,
        ConfigFieldKind.status,
        required: true,
      ),
      ConfigField(
        'to_status_id',
        () => tr.wfToStatus,
        ConfigFieldKind.status,
        required: true,
      ),
      ConfigField(
        'customer_allowed',
        () => tr.wfCustomerAllowed,
        ConfigFieldKind.boolean,
        initial: false,
      ),
    ],
  );

  static final interventionPriorities = ConfigSchema(
    entity: ConfigEntities.interventionPriorities,
    title: () => tr.wfCfgPriorities,
    hint: () => tr.wfCfgPrioritiesHint,
    fields: [
      ConfigField(
        'name',
        () => tr.fieldNameRequired,
        ConfigFieldKind.text,
        required: true,
        maxLength: 120,
      ),
      ConfigField(
        'code',
        () => tr.wfCode,
        ConfigFieldKind.text,
        required: true,
        isCode: true,
        immutable: true,
        maxLength: 40,
      ),
      ConfigField(
        'color',
        () => tr.color,
        ConfigFieldKind.color,
        initial: '#F59E0B',
      ),
      ConfigField(
        'response_target_hours',
        () => tr.wfResponseTarget,
        ConfigFieldKind.integer,
        nullable: true,
        hint: () => tr.wfResponseTargetHint,
      ),
      ConfigField(
        'sort_order',
        () => tr.wfSortOrder,
        ConfigFieldKind.integer,
        initial: '0',
        hint: () => tr.wfSortOrderHint,
      ),
    ],
  );

  static final messageTemplates = ConfigSchema(
    entity: ConfigEntities.messageTemplates,
    title: () => tr.wfCfgTemplates,
    hint: () => tr.wfCfgTemplatesHint,
    fields: [
      ConfigField(
        'code',
        () => tr.wfTemplate,
        ConfigFieldKind.choice,
        required: true,
        immutable: true,
        initial: 'training_first',
        options: [
          ConfigOption('training_first', () => tr.wfTemplateTrainingFirst),
          ConfigOption('training_review', () => tr.wfTemplateTrainingReview),
        ],
      ),
      ConfigField(
        'locale',
        () => tr.wfLanguage,
        ConfigFieldKind.choice,
        required: true,
        immutable: true,
        initial: 'fr',
        options: [
          ConfigOption('ar', () => 'العربية'),
          ConfigOption('en', () => 'English'),
          ConfigOption('fr', () => 'Français'),
        ],
      ),
      ConfigField(
        'body',
        () => tr.wfTemplateBody,
        ConfigFieldKind.multiline,
        required: true,
        maxLength: 2000,
        hint: () => tr.wfTemplatePlaceholders,
      ),
    ],
  );

  static final productResources = ConfigSchema(
    entity: ConfigEntities.productResources,
    title: () => tr.wfCfgProductResources,
    hint: () => tr.wfCfgProductResourcesHint,
    fields: [
      ConfigField(
        'product_id',
        () => tr.fieldProduct,
        ConfigFieldKind.product,
        required: true,
      ),
      ConfigField(
        'title',
        () => tr.wfTitle,
        ConfigFieldKind.text,
        required: true,
        maxLength: 200,
      ),
      ConfigField(
        'kind',
        () => tr.colType,
        ConfigFieldKind.choice,
        initial: 'link',
        options: [
          ConfigOption('pdf', () => 'PDF'),
          ConfigOption('video', () => tr.wfKindVideo),
          ConfigOption('link', () => tr.wfKindLink),
          ConfigOption('other', () => tr.optionOther),
        ],
      ),
      ConfigField(
        'url',
        () => tr.wfUrl,
        ConfigFieldKind.url,
        required: true,
        maxLength: 500,
      ),
      ConfigField(
        'customer_visible',
        () => tr.wfCustomerVisible,
        ConfigFieldKind.boolean,
        initial: false,
      ),
      ConfigField(
        'is_training_material',
        () => tr.wfTrainingMaterial,
        ConfigFieldKind.boolean,
        initial: false,
      ),
      ConfigField(
        'sort_order',
        () => tr.wfSortOrder,
        ConfigFieldKind.integer,
        inTable: false,
        initial: '0',
      ),
    ],
  );

  static List<ConfigSchema> get all => [
    appointmentTypes,
    holidays,
    interventionTypes,
    interventionStatuses,
    interventionTransitions,
    interventionPriorities,
    messageTemplates,
    productResources,
  ];
}
