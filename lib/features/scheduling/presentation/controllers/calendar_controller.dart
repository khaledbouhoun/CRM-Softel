import 'package:get/get.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../core/models/named_ref.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/load_state.dart';
import '../../../activities/data/models/activity.dart';
import '../../../activities/domain/activities_repository.dart';
import '../../data/models/calendar_item.dart';
import '../../domain/scheduling_repository.dart';

enum CalendarView { month, week, day }

/// Client-side quick filter chips over the loaded items (no reload).
enum CalendarQuick { all, demos, trainings, support, followUps }

/// Unified calendar: scheduled appointments, follow-ups and interventions
/// from the CRM, plus (optionally) the *completed* activities already
/// recorded, drawn differently so plans and history are never confused.
class CalendarController extends GetxController {
  CalendarController({
    required SchedulingRepository repository,
    required ActivitiesRepository activities,
    DateTime Function()? clock,
    int? weekStartsOn,
  }) : _repository = repository,
       _activities = activities,
       _clock = clock ?? DateTime.now,
       weekStartsOn =
           weekStartsOn ?? (L10n.isRtl ? DateTime.sunday : DateTime.monday) {
    final now = _clock();
    anchor.value = DateTime(now.year, now.month, now.day);
  }

  final SchedulingRepository _repository;
  final ActivitiesRepository _activities;
  final DateTime Function() _clock;

  /// `DateTime.monday`..`DateTime.sunday`.
  final int weekStartsOn;

  final view = CalendarView.month.obs;
  final anchor = Rx<DateTime>(DateTime.now());
  final filter = const CalendarFilter().obs;
  final showActivities = true.obs;
  final quick = CalendarQuick.all.obs;
  final items = <CalendarItem>[].obs;
  final state = LoadState();

  /// Set when the completed-activities overlay could not be loaded, so the
  /// calendar still shows plans while telling the user the history is missing.
  final activitiesError = RxnString();

  int _requestId = 0;

  DateTime get today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime startOfWeek(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final diff = (d.weekday - weekStartsOn + 7) % 7;
    return d.subtract(Duration(days: diff));
  }

  /// First and last visible day for [view] around [anchor] (inclusive).
  (DateTime, DateTime) get range {
    final a = anchor.value;
    switch (view.value) {
      case CalendarView.day:
        return (a, a);
      case CalendarView.week:
        final start = startOfWeek(a);
        return (start, start.add(const Duration(days: 6)));
      case CalendarView.month:
        final start = startOfWeek(DateTime(a.year, a.month, 1));
        return (start, start.add(const Duration(days: 41)));
    }
  }

  /// Days shown in the month grid (6 weeks), week (7) or day (1).
  List<DateTime> get days {
    final (from, to) = range;
    final count = to.difference(from).inDays + 1;
    return [
      for (var i = 0; i < count; i++)
        DateTime(from.year, from.month, from.day + i),
    ];
  }

  List<CalendarItem> itemsOn(DateTime day) {
    final list = items.where((i) => i.overlapsDay(day) && _matchesQuick(i)).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return list;
  }

  bool _matchesQuick(CalendarItem i) => switch (quick.value) {
    CalendarQuick.all => true,
    CalendarQuick.demos => i.kind == CalendarKind.appointment && i.group == 'demo',
    CalendarQuick.trainings =>
      i.kind == CalendarKind.appointment && (i.group == 'training' || i.group == 'accompaniment'),
    CalendarQuick.support => i.kind == CalendarKind.intervention,
    CalendarQuick.followUps => i.kind == CalendarKind.followUp,
  };

  void setQuick(CalendarQuick value) => quick.value = value;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final id = ++_requestId;
    final (from, to) = range;
    final current = filter.value;
    final wantsActivities =
        showActivities.value &&
        current.employee == null &&
        current.productId == null &&
        current.type == null &&
        current.status == null;
    await state.run(() async {
      final merged = <CalendarItem>[];
      final serverKinds = current.kinds
          .where(CalendarKind.serverKinds.contains)
          .toList();
      if (serverKinds.isNotEmpty) {
        merged.addAll(
          await _repository.getCalendar(
            from,
            to,
            current.copyWith(kinds: serverKinds),
          ),
        );
      }
      activitiesError.value = null;
      if (wantsActivities) {
        try {
          final page = await _activities.getActivities(
            ActivityFilter(
              dateFrom: from,
              dateTo: to,
              prospectId: current.prospectId,
              perPage: AppConfig.largePageSize,
            ),
          );
          merged.addAll(page.items.map(activityToItem));
        } catch (e) {
          activitiesError.value = ApiException.from(e).message;
        }
      }
      if (id != _requestId) return; // a newer request superseded this one
      merged.sort((a, b) => a.startsAt.compareTo(b.startsAt));
      items.assignAll(merged);
    });
  }

  /// A recorded activity shown as completed work on the calendar.
  static CalendarItem activityToItem(Activity a) {
    final at = a.occurredAt ?? DateTime.now();
    final line = a.headline.split('\n').first;
    return CalendarItem(
      kind: CalendarKind.activity,
      id: a.id,
      title: line.isEmpty ? a.type.label : line,
      startsAt: at,
      endsAt: at,
      status: 'recorded',
      typeCode: a.type.apiValue,
      group: 'activity',
      prospect: a.prospect == null
          ? null
          : NamedRef(id: a.prospect!.id, name: a.prospect!.companyName),
    );
  }

  // --- navigation ---

  Future<void> setView(CalendarView value) {
    if (view.value == value) return Future.value();
    view.value = value;
    return load();
  }

  Future<void> goToday() {
    anchor.value = today;
    return load();
  }

  Future<void> next() => _shift(1);
  Future<void> previous() => _shift(-1);

  Future<void> _shift(int direction) {
    final a = anchor.value;
    anchor.value = switch (view.value) {
      CalendarView.month => DateTime(a.year, a.month + direction, 1),
      CalendarView.week => a.add(Duration(days: 7 * direction)),
      CalendarView.day => a.add(Duration(days: direction)),
    };
    return load();
  }

  /// Opens the day view on [day] (month cell click).
  Future<void> openDay(DateTime day) {
    anchor.value = DateTime(day.year, day.month, day.day);
    view.value = CalendarView.day;
    return load();
  }

  Future<void> setFilter(CalendarFilter value) {
    filter.value = value;
    return load();
  }

  Future<void> toggleActivities(bool value) {
    showActivities.value = value;
    return load();
  }

  Future<void> toggleKind(CalendarKind kind, bool enabled) {
    final kinds = filter.value.kinds.toList();
    if (enabled) {
      if (!kinds.contains(kind)) kinds.add(kind);
    } else {
      kinds.remove(kind);
    }
    return setFilter(filter.value.copyWith(kinds: kinds));
  }
}
