class PaginationMeta {
  final int total;
  final int totalPages;
  final int currentPage;

  const PaginationMeta({
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  bool get hasMore => currentPage < totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json, int requestedPage) {
    final total = json['total'] is int ? json['total'] as int : int.tryParse(json['total']?.toString() ?? '') ?? 0;
    final totalPages = json['totalPages'] is int ? json['totalPages'] as int : int.tryParse(json['totalPages']?.toString() ?? '') ?? 1;

    return PaginationMeta(
      total: total,
      totalPages: totalPages,
      currentPage: requestedPage,
    );
  }
}

class PaginatedListResponse<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedListResponse({
    required this.items,
    required this.meta,
  });

  bool get hasMore => meta.hasMore;
  int get total => meta.total;
  int get totalPages => meta.totalPages;
  int get currentPage => meta.currentPage;
}
