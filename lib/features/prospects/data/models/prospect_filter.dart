import '../../../../app/config/app_config.dart';
import '../../../../core/utils/json_utils.dart';

/// Sortable columns of the prospects table (API `sort` values). The API
/// sorts only on these fields.
enum ProspectSort {
  companyName('name'),
  city('city'),
  createdAt('created_at'),
  updatedAt('updated_at');

  const ProspectSort(this.apiValue);
  final String apiValue;

  /// Text columns read naturally A→Z; dates newest first.
  bool get defaultsToAscending => this == companyName || this == city;
}

/// Query of GET `/prospects`. Immutable; controllers replace it on change.
class ProspectFilter {
  const ProspectFilter({
    this.search = '',
    this.stageId,
    this.productId,
    this.lossReasonId,
    this.source,
    this.businessActivity,
    this.previousSoftware,
    this.createdFrom,
    this.createdTo,
    this.sort = ProspectSort.createdAt,
    this.ascending = false,
    this.page = 1,
    this.perPage = AppConfig.defaultPageSize,
  });

  final String search;
  final int? stageId;
  final int? productId;
  final int? lossReasonId;
  final String? source;
  final String? businessActivity;
  final String? previousSoftware;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final ProspectSort sort;
  final bool ascending;
  final int page;
  final int perPage;

  bool get hasActiveFilters =>
      search.trim().isNotEmpty ||
      stageId != null ||
      productId != null ||
      lossReasonId != null ||
      source != null ||
      businessActivity != null ||
      previousSoftware != null ||
      createdFrom != null ||
      createdTo != null;

  Map<String, dynamic> toQuery() => {
    'search': search.trim(),
    'sales_stage_id': stageId,
    'product_id': productId,
    'loss_reason_id': lossReasonId,
    'source': source,
    'business_activity': businessActivity,
    'previous_software': previousSoftware,
    'created_from': createdFrom == null ? null : toApiDate(createdFrom!),
    'created_to': createdTo == null ? null : toApiDate(createdTo!),
    'sort': sort.apiValue,
    'direction': ascending ? 'asc' : 'desc',
    'page': page,
    'per_page': perPage,
  };

  static const _keep = Object();

  /// [_keep] distinguishes "not provided" from an explicit `null` so that
  /// nullable filters can be cleared.
  ProspectFilter copyWith({
    String? search,
    Object? stageId = _keep,
    Object? productId = _keep,
    Object? lossReasonId = _keep,
    Object? source = _keep,
    Object? businessActivity = _keep,
    Object? previousSoftware = _keep,
    Object? createdFrom = _keep,
    Object? createdTo = _keep,
    ProspectSort? sort,
    bool? ascending,
    int? page,
    int? perPage,
  }) => ProspectFilter(
    search: search ?? this.search,
    stageId: identical(stageId, _keep) ? this.stageId : stageId as int?,
    productId: identical(productId, _keep) ? this.productId : productId as int?,
    lossReasonId: identical(lossReasonId, _keep)
        ? this.lossReasonId
        : lossReasonId as int?,
    source: identical(source, _keep) ? this.source : source as String?,
    businessActivity: identical(businessActivity, _keep)
        ? this.businessActivity
        : businessActivity as String?,
    previousSoftware: identical(previousSoftware, _keep)
        ? this.previousSoftware
        : previousSoftware as String?,
    createdFrom: identical(createdFrom, _keep)
        ? this.createdFrom
        : createdFrom as DateTime?,
    createdTo: identical(createdTo, _keep)
        ? this.createdTo
        : createdTo as DateTime?,
    sort: sort ?? this.sort,
    ascending: ascending ?? this.ascending,
    page: page ?? this.page,
    perPage: perPage ?? this.perPage,
  );
}
