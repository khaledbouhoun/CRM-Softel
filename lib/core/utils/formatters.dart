import 'package:intl/intl.dart';

import '../../app/l10n/l10n.dart';

/// Display formatting in the current UI language (Arabic uses the Algerian
/// variant, which keeps Latin digits).
class Formatters {
  const Formatters._();

  static String get locale => AppLocales.intlName(L10n.current);

  // Formats are cached per locale: creating them is comparatively slow.
  static final _cache = <String, Object>{};

  static T _of<T>(String pattern, T Function(String locale) create) =>
      (_cache['$locale|$pattern'] ??= create(locale)!) as T;

  static DateFormat get _date => _of('d', (l) => DateFormat('dd/MM/yyyy', l));
  static DateFormat get _dateTime =>
      _of('dt', (l) => DateFormat('dd/MM/yyyy HH:mm', l));
  static DateFormat get _time => _of('t', (l) => DateFormat('HH:mm', l));
  static DateFormat get _longDate =>
      _of('ld', (l) => DateFormat('EEEE d MMMM yyyy', l));
  static NumberFormat get _number => _of('n', NumberFormat.decimalPattern);

  static String date(DateTime? value) =>
      value == null ? '—' : _date.format(value.toLocal());

  static String dateTime(DateTime? value) =>
      value == null ? '—' : _dateTime.format(value.toLocal());

  static String time(DateTime? value) =>
      value == null ? '—' : _time.format(value.toLocal());

  static String longDate(DateTime value) {
    final text = _longDate.format(value.toLocal());
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }

  static String number(num value) => _number.format(value);

  static String percent(num part, num total) {
    if (total == 0) return '0 %';
    return '${(part * 100 / total).toStringAsFixed(0)} %';
  }

  /// "aujourd'hui 14:30", "demain 09:00", "il y a 3 j", "dans 5 j"...
  static String relative(DateTime? value, {DateTime? now}) {
    if (value == null) return '—';
    final reference = now ?? DateTime.now();
    final local = value.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final today = DateTime(reference.year, reference.month, reference.day);
    final diff = day.difference(today).inDays;
    switch (diff) {
      case 0:
        return tr.relToday(time(local));
      case 1:
        return tr.relTomorrow(time(local));
      case -1:
        return tr.relYesterday(time(local));
    }
    return diff > 0 ? tr.relInDays(diff) : tr.relDaysAgo(-diff);
  }

  static String plural(int count, String singular, [String? pluralForm]) =>
      '$count ${count > 1 ? (pluralForm ?? '${singular}s') : singular}';
}
