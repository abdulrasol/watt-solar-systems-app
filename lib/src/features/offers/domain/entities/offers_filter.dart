class OffersFilter {
  final int page;
  final int pageSize;
  final String? status;

  OffersFilter({
    this.page = 1,
    this.pageSize = 12,
    this.status,
  });

  OffersFilter copyWith({
    int? page,
    int? pageSize,
    String? status,
  }) {
    return OffersFilter(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> query() {
    final Map<String, dynamic> query = {
      'page': page,
      'page_size': pageSize,
    };
    if (status != null) query['status'] = status;
    return query;
  }
}
