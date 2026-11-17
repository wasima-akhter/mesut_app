import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums/app_enum.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../../../core/providers/common_provider.dart';
import '../../../../../core/storage/storage_provider.dart';
import '../../../../site_manager/offline_sync/providers/site_manager_sync_provider.dart';
import '../../data/datasources/mobile_dashboard_datasource.dart';
import '../../data/repositories/mobile_dashboard_repository_impl.dart';
import '../../domain/entities/mobile_dashboard_entity.dart';
import '../../domain/entities/mobile_profile_entity.dart';
import '../../domain/entities/mobile_project_entity.dart';
import '../../domain/entities/mobile_schedule_entity.dart';
import '../../domain/repositories/mobile_dashboard_repository.dart';

final mobileDashboardDataSourceProvider =
    Provider<MobileDashboardRemoteDataSource>((ref) {
      return MobileDashboardRemoteDataSourceImpl(
        apiClient: ref.watch(apiClientProvider),
        cacheService: ref.watch(siteManagerCacheServiceProvider),
      );
    });

final mobileDashboardRepositoryProvider = Provider<MobileDashboardRepository>((
  ref,
) {
  return MobileDashboardRepositoryImpl(
    ref.watch(mobileDashboardDataSourceProvider),
  );
});

class MobileDashboardNotifier extends AsyncNotifier<MobileDashboardEntity> {
  @override
  Future<MobileDashboardEntity> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) return const MobileDashboardEntity();
    return ref.watch(mobileDashboardRepositoryProvider).getDashboard();
  }

  Future<void> refresh() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) {
      state = const AsyncValue.data(MobileDashboardEntity());
      return;
    }
    state = await AsyncValue.guard(
      () => ref.read(mobileDashboardRepositoryProvider).getDashboard(),
    );
  }
}

final mobileDashboardProvider =
    AsyncNotifierProvider<MobileDashboardNotifier, MobileDashboardEntity>(
      MobileDashboardNotifier.new,
    );

class MobileProjectsNotifier extends AsyncNotifier<List<MobileProjectEntity>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  int get currentPage => _page;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<MobileProjectEntity>> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) return const [];
    _page = 1;
    final items = await ref
        .watch(mobileDashboardRepositoryProvider)
        .getProjects(page: 1, limit: 20);
    _hasMore = items.length >= 20;
    return items;
  }

  Future<void> refresh() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) {
      state = const AsyncValue.data([]);
      return;
    }
    _page = 1;
    state = await AsyncValue.guard(() async {
      final items = await ref
          .read(mobileDashboardRepositoryProvider)
          .getProjects(page: 1, limit: 20);
      _hasMore = items.length >= 20;
      return items;
    });
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    final currentList = state.asData?.value ?? [];
    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final nextItems = await ref
          .read(mobileDashboardRepositoryProvider)
          .getProjects(page: nextPage, limit: 20);
      _page = nextPage;
      _hasMore = nextItems.length >= 20;
      state = AsyncValue.data([...currentList, ...nextItems]);
    } finally {
      _isLoadingMore = false;
    }
  }
}

final mobileProjectsProvider =
    AsyncNotifierProvider<MobileProjectsNotifier, List<MobileProjectEntity>>(
      MobileProjectsNotifier.new,
    );

class MobileProfileNotifier extends AsyncNotifier<MobileProfileEntity?> {
  @override
  Future<MobileProfileEntity?> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) return null;
    return ref.watch(mobileDashboardRepositoryProvider).getProfile();
  }

  Future<void> refresh() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) {
      state = const AsyncValue.data(null);
      return;
    }
    state = await AsyncValue.guard(
      () => ref.read(mobileDashboardRepositoryProvider).getProfile(),
    );
  }

  Future<MobileProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? language,
  }) async {
    final repository = ref.read(mobileDashboardRepositoryProvider);
    final updated = await repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatarUrl: avatarUrl,
      language: language,
    );
    state = AsyncValue.data(updated);
    return updated;
  }
}

final mobileProfileProvider =
    AsyncNotifierProvider<MobileProfileNotifier, MobileProfileEntity?>(
      MobileProfileNotifier.new,
    );

class MobileScheduleNotifier
    extends AsyncNotifier<List<MobileScheduleDayEntity>> {
  DateTime _startDate = _startOfUtcDay(DateTime.now().toUtc());
  DateTime _endDate = _startOfUtcDay(
    DateTime.now().toUtc(),
  ).add(const Duration(days: 7, hours: 23, minutes: 59, seconds: 59));

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  static DateTime _startOfUtcDay(DateTime dt) =>
      DateTime.utc(dt.year, dt.month, dt.day);

  @override
  Future<List<MobileScheduleDayEntity>> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.watch(userRoleProvider);
    if (!hasToken || role != UserRole.siteManager) return const [];
    final now = DateTime.now().toUtc();
    final firstDay = DateTime.utc(now.year, now.month, 1);
    final lastDay = DateTime.utc(now.year, now.month + 1, 0, 23, 59, 59);
    _startDate = firstDay.subtract(const Duration(days: 7));
    _endDate = lastDay.add(const Duration(days: 7));
    return ref
        .watch(mobileDashboardRepositoryProvider)
        .getSchedule(startDate: _startDate, endDate: _endDate);
  }

  Future<void> loadMonth(DateTime month) async {
    final firstDay = DateTime.utc(month.year, month.month, 1);
    final lastDay = DateTime.utc(month.year, month.month + 1, 0, 23, 59, 59);
    _startDate = firstDay.subtract(const Duration(days: 7));
    _endDate = lastDay.add(const Duration(days: 7));
    await refresh();
  }

  Future<void> loadRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _startDate = startDate.toUtc();
    _endDate = endDate.toUtc();
    await refresh();
  }

  Future<void> refresh() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.read(userRoleProvider);
    if (!hasToken || role != UserRole.siteManager) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(mobileDashboardRepositoryProvider)
          .getSchedule(startDate: _startDate, endDate: _endDate),
    );
  }
}

final mobileScheduleProvider =
    AsyncNotifierProvider<
      MobileScheduleNotifier,
      List<MobileScheduleDayEntity>
    >(MobileScheduleNotifier.new);

class MobileMapPinsNotifier extends AsyncNotifier<List<MobileMapPinEntity>> {
  String? _selectedType;
  String? get selectedType => _selectedType;

  @override
  Future<List<MobileMapPinEntity>> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.watch(userRoleProvider);
    if (!hasToken || role != UserRole.siteManager) return const [];
    return ref
        .watch(mobileDashboardRepositoryProvider)
        .getMapPins(type: _selectedType);
  }

  Future<void> filterByType(String? type) async {
    _selectedType = (type == null || type.trim().isEmpty)
        ? null
        : type.trim().toUpperCase();
    await refresh();
  }

  Future<void> refresh() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.read(userRoleProvider);
    if (!hasToken || role != UserRole.siteManager) {
      state = const AsyncValue.data([]);
      return;
    }
    state = await AsyncValue.guard(
      () => ref
          .read(mobileDashboardRepositoryProvider)
          .getMapPins(type: _selectedType),
    );
  }
}

final mobileMapPinsProvider =
    AsyncNotifierProvider<MobileMapPinsNotifier, List<MobileMapPinEntity>>(
      MobileMapPinsNotifier.new,
    );
