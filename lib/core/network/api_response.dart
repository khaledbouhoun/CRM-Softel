import '../utils/json_utils.dart';
import 'api_exceptions.dart';
import '../../app/l10n/l10n.dart';

/// Unwraps Laravel API Resource envelopes.
///
/// See docs/API_CONTRACT.md §1. Both `{ "data": ... }` and bare payloads are
/// accepted so that small differences in the backend do not break the client.
class ApiResponse {
  const ApiResponse._();

  /// Extracts a single object from `{ "data": {...} }` or a bare object.
  static JsonMap object(Object? body) {
    final map = asMapOrNull(body);
    if (map == null) {
      throw UnexpectedResponseException(tr.errExpectedObject);
    }
    final inner = asMapOrNull(map['data']);
    return inner ?? map;
  }

  /// Extracts a list from `{ "data": [...] }` or a bare array.
  static List<T> list<T>(Object? body, T Function(JsonMap json) fromJson) {
    if (body is List) return asList(body, fromJson);
    final map = asMapOrNull(body);
    if (map != null && map['data'] is List) {
      return asList(map['data'], fromJson);
    }
    throw UnexpectedResponseException(tr.errExpectedList);
  }

  static Paginated<T> paginated<T>(
    Object? body,
    T Function(JsonMap json) fromJson,
  ) => Paginated.fromJson(body, fromJson);
}

/// One page of a Laravel `LengthAwarePaginator` result.
class Paginated<T> {
  const Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  const Paginated.empty({this.perPage = 25})
    : items = const [],
      currentPage = 1,
      lastPage = 1,
      total = 0;

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Paginated<T> copyWith({List<T>? items}) => Paginated(
    items: items ?? this.items,
    currentPage: currentPage,
    lastPage: lastPage,
    perPage: perPage,
    total: total,
  );

  bool get hasNext => currentPage < lastPage;
  bool get hasPrevious => currentPage > 1;
  bool get isEmpty => items.isEmpty;

  /// Index (1-based) of the first item on this page, 0 when empty.
  int get from => items.isEmpty ? 0 : (currentPage - 1) * perPage + 1;
  int get to => items.isEmpty ? 0 : from + items.length - 1;

  factory Paginated.fromJson(Object? body, T Function(JsonMap json) fromJson) {
    // A non-paginated list is treated as a single page.
    if (body is List) {
      final items = asList(body, fromJson);
      return Paginated(
        items: items,
        currentPage: 1,
        lastPage: 1,
        perPage: items.length,
        total: items.length,
      );
    }
    final map = asMapOrNull(body);
    if (map == null || map['data'] is! List) {
      throw UnexpectedResponseException(tr.errExpectedPaged);
    }
    final items = asList(map['data'], fromJson);
    // Laravel Resource collections put paging in `meta`; a raw paginator puts
    // it at the top level.
    final meta = asMapOrNull(map['meta']) ?? map;
    final perPage = asInt(meta['per_page'], fallback: items.length);
    return Paginated(
      items: items,
      currentPage: asInt(meta['current_page'], fallback: 1),
      lastPage: asInt(meta['last_page'], fallback: 1),
      perPage: perPage == 0 ? items.length : perPage,
      total: asInt(meta['total'], fallback: items.length),
    );
  }

  Paginated<T> copyWithItems(List<T> newItems) => Paginated(
    items: newItems,
    currentPage: currentPage,
    lastPage: lastPage,
    perPage: perPage,
    total: total,
  );
}
