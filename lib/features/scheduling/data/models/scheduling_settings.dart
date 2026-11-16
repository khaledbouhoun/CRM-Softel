import '../../../../core/utils/json_utils.dart';

/// Business-hours and booking policy stored in the CRM (`/settings/scheduling`).
/// Nothing here is hard-coded in the client: defaults of the forms come from
/// these values.
class SchedulingSettings {
  const SchedulingSettings({
    required this.workingDays,
    required this.workStart,
    required this.workEnd,
    required this.slotMinutes,
    required this.holdExpiryMinutes,
    required this.bookingHorizonDays,
    required this.minNoticeHours,
    required this.demoCapacity,
    required this.accompanimentOccurrences,
    required this.accompanimentIntervalDays,
    required this.trialDefaultDays,
    required this.whatsappCountryCode,
  });

  /// 0 = Sunday ... 6 = Saturday.
  final List<int> workingDays;

  /// `HH:mm`.
  final String workStart;
  final String workEnd;
  final int slotMinutes;
  final int holdExpiryMinutes;
  final int bookingHorizonDays;
  final int minNoticeHours;
  final int demoCapacity;
  final int accompanimentOccurrences;
  final int accompanimentIntervalDays;
  final int trialDefaultDays;
  final String whatsappCountryCode;

  factory SchedulingSettings.fromJson(JsonMap json) {
    final days = json['working_days'];
    return SchedulingSettings(
      workingDays: days is List
          ? days.map(asIntOrNull).whereType<int>().toList()
          : const [],
      workStart: asString(json['work_start'], fallback: '09:00'),
      workEnd: asString(json['work_end'], fallback: '17:00'),
      slotMinutes: asInt(json['slot_minutes'], fallback: 60),
      holdExpiryMinutes: asInt(json['hold_expiry_minutes'], fallback: 1440),
      bookingHorizonDays: asInt(json['booking_horizon_days'], fallback: 30),
      minNoticeHours: asInt(json['min_notice_hours']),
      demoCapacity: asInt(json['demo_capacity'], fallback: 1),
      accompanimentOccurrences: asInt(
        json['accompaniment_occurrences'],
        fallback: 4,
      ),
      accompanimentIntervalDays: asInt(
        json['accompaniment_interval_days'],
        fallback: 7,
      ),
      trialDefaultDays: asInt(json['trial_default_days'], fallback: 14),
      whatsappCountryCode: asString(json['whatsapp_country_code']),
    );
  }

  JsonMap toJson() => {
    'working_days': workingDays,
    'work_start': workStart,
    'work_end': workEnd,
    'slot_minutes': slotMinutes,
    'hold_expiry_minutes': holdExpiryMinutes,
    'booking_horizon_days': bookingHorizonDays,
    'min_notice_hours': minNoticeHours,
    'demo_capacity': demoCapacity,
    'accompaniment_occurrences': accompanimentOccurrences,
    'accompaniment_interval_days': accompanimentIntervalDays,
    'trial_default_days': trialDefaultDays,
    'whatsapp_country_code': whatsappCountryCode,
  };
}
