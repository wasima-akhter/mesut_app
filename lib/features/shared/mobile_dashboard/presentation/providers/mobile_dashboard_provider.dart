import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums/app_enum.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../../../core/providers/common_provider.dart';
import '../../../../../core/storage/storage_provider.dart';
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
  @override
  Future<List<MobileProjectEntity>> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) return const [];
    return ref.watch(mobileDashboardRepositoryProvider).getProjects();
  }

  Future<void> refresh() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) {
      state = const AsyncValue.data([]);
      return;
    }
    state = await AsyncValue.guard(
      () => ref.read(mobileDashboardRepositoryProvider).getProjects(),
    );
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
    return ref
        .watch(mobileDashboardRepositoryProvider)
        .getSchedule(startDate: _startDate, endDate: _endDate);
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
