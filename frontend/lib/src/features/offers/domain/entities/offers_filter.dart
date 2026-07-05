class OffersFilter {
  final int page;
  final int pageSize;
  final String? status;
  final String? search;

  OffersFilter({
    this.page = 1,
    this.pageSize = 12,
    this.status,
    this.search,
  });

  OffersFilter copyWith({
    int? page,
    int? pageSize,
    String? status,
    String? search,
  }) {
    return OffersFilter(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      status: status ?? this.status,
      search: search ?? this.search,
    );
  }

  Map<String, dynamic> query() {
    final Map<String, dynamic> query = {
      'page': page,
      'page_size': pageSize,
    };
    if (status != null) query['status'] = status;
    if (search != null && search!.isNotEmpty) query['search'] = search;
    return query;
  }
}
