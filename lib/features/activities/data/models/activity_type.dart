import '../../../../app/l10n/l10n.dart';

/// Activity kinds defined by the business rules (§4.3).
enum ActivityType {
  call('call'),

  /// Legacy code of rows created before `appointment` existed. Same meaning.
  meeting('meeting'),
  appointment('appointment'),
  message('message'),
  note('note'),
  other('other');

  const ActivityType(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    call => tr.activityTypeCall,
    meeting || appointment => tr.activityTypeAppointment,
    message => tr.activityTypeMessage,
    note => tr.activityTypeNote,
    other => tr.optionOther,
  };

  /// The three types offered when creating an activity or a follow-up.
  static const selectable = [call, appointment, message];

  /// `meeting` rows are appointments.
  ActivityType get canonical => this == meeting ? appointment : this;

  static ActivityType fromApi(Object? value) {
    final text = value?.toString().trim().toLowerCase();
    return ActivityType.values.firstWhere(
      (t) => t.apiValue == text,
      orElse: () => ActivityType.other,
    );
  }
}
