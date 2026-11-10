import '../../../../app/l10n/l10n.dart';

/// Activity kinds defined by the business rules: Call, Meeting, Message, Other.
enum ActivityType {
  call('call'),
  meeting('meeting'),
  message('message'),
  other('other');

  const ActivityType(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    call => tr.activityTypeCall,
    meeting => tr.activityTypeAppointment,
    message => tr.activityTypeMessage,
    other => tr.optionOther,
  };

  /// The four types offered when creating an activity or a follow-up.
  static const selectable = [call, meeting, message, other];

  ActivityType get canonical => this;

  static ActivityType fromApi(Object? value) {
    final text = value?.toString().trim().toLowerCase();
    if (text == 'appointment') return meeting;
    if (text == 'note') return other;
    return ActivityType.values.firstWhere(
      (t) => t.apiValue == text,
      orElse: () => ActivityType.other,
    );
  }
}
