import '../../domain/entities/customer_entity.dart';

class CustomerListState {
  final List<CustomerEntity> customers;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String searchQuery;
  final String? categoryFilter;

  const CustomerListState({
    this.customers = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.searchQuery = '',
    this.categoryFilter,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get isEmpty => !isLoading && customers.isEmpty;

  CustomerListState copyWith({
    List<CustomerEntity>? customers,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    String? categoryFilter,
    bool clearCategory = false,
  }) {
    return CustomerListState(
      customers: customers ?? this.customers,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
    );
  }
}
