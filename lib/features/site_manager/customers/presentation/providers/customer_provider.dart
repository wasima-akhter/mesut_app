import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import 'customer_state.dart';

export 'customer_state.dart';

class CustomerListNotifier extends Notifier<CustomerListState> {
  CustomerRepository get _repository => ref.read(customerRepositoryProvider);
  Timer? _debounceTimer;

  @override
  CustomerListState build() {
    // Auto-fetch page 1 on build
    Future.microtask(() => loadCustomers(isRefresh: true));
    return const CustomerListState(isLoading: true);
  }

  Future<void> loadCustomers({bool isRefresh = false}) async {
    final page = isRefresh ? 1 : state.currentPage;

    if (isRefresh) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final result = await _repository.getCustomers(
        page: page,
        limit: 10,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        category: state.categoryFilter,
      );

      state = state.copyWith(
        customers: result.items,
        currentPage: result.meta.currentPage,
        totalPages: result.meta.totalPages,
        total: result.meta.total,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _repository.getCustomers(
        page: nextPage,
        limit: 10,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        category: state.categoryFilter,
      );

      // Deduplicate by ID
      final existingIds = state.customers.map((c) => c.id).toSet();
      final newItems = result.items.where((c) => !existingIds.contains(c.id));

      state = state.copyWith(
        customers: [...state.customers, ...newItems],
        currentPage: result.meta.currentPage,
        totalPages: result.meta.totalPages,
        total: result.meta.total,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  void onSearchChanged(String query) {
    if (state.searchQuery == query.trim()) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      state = state.copyWith(
        searchQuery: query.trim(),
        currentPage: 1,
      );
      loadCustomers(isRefresh: true);
    });
  }

  void onCategoryFilterChanged(String? category) {
    if (state.categoryFilter == category) return;

    state = state.copyWith(
      categoryFilter: category,
      clearCategory: category == null,
      currentPage: 1,
    );
    loadCustomers(isRefresh: true);
  }
}

final customerListProvider =
    NotifierProvider<CustomerListNotifier, CustomerListState>(() {
  return CustomerListNotifier();
});
