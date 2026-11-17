import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/enums/app_enum.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/providers/common_provider.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../data/datasources/mobile_phase_datasource.dart';
import '../../data/repositories/mobile_phase_repository_impl.dart';
import '../../domain/entities/mobile_phase_entity.dart';
import '../../domain/repositories/mobile_phase_repository.dart';
import '../../offline_sync/models/site_manager_sync_action.dart';
import '../../offline_sync/providers/site_manager_sync_provider.dart';

final mobilePhaseDataSourceProvider = Provider<MobilePhaseRemoteDataSource>((
  ref,
) {
  return MobilePhaseRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
    cacheService: ref.watch(siteManagerCacheServiceProvider),
  );
});

final mobilePhaseRepositoryProvider = Provider<MobilePhaseRepository>((ref) {
  return MobilePhaseRepositoryImpl(ref.watch(mobilePhaseDataSourceProvider));
});

class MobilePhasesNotifier extends AsyncNotifier<List<MobilePhaseEntity>> {
  String? _column;

  String? get currentColumn => _column;

  @override
  Future<List<MobilePhaseEntity>> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.watch(userRoleProvider);
    if (!hasToken || role != UserRole.siteManager) return const [];
    return ref.watch(mobilePhaseRepositoryProvider).getManagedPhases(
      column: _column,
    );
  }

  Future<void> setColumn(String? column) async {
    _column = (column == null || column == 'ALL') ? null : column;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(mobilePhaseRepositoryProvider).getManagedPhases(
        column: _column,
      ),
    );
  }

  Future<void> refresh({String? column}) async {
    if (column != null) {
      _column = column == 'ALL' ? null : column;
    }
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
      () => ref.read(mobilePhaseRepositoryProvider).getManagedPhases(
        column: _column,
      ),
    );
  }

  Future<MobilePhaseEntity> updateStatus(String phaseId, String status) async {
    try {
      final updated = await ref
          .read(mobilePhaseRepositoryProvider)
          .updatePhaseStatus(phaseId, status);
      final current = state.asData?.value ?? const <MobilePhaseEntity>[];
      final next = current.map((e) => e.id == phaseId ? updated : e).toList();
      state = AsyncValue.data(next);
      return updated;
    } catch (_) {
      final current = state.asData?.value ?? const <MobilePhaseEntity>[];
      final item = current.firstWhere(
        (e) => e.id == phaseId,
        orElse: () => current.first,
      );
      final updated = item.copyWith(status: status);
      final next = current.map((e) => e.id == phaseId ? updated : e).toList();
      state = AsyncValue.data(next);

      final action = SiteManagerSyncAction(
        id: 'phase_status_${DateTime.now().millisecondsSinceEpoch}',
        actionType: SiteManagerSyncActionType.updatePhaseStatus,
        endpoint: ApiConstants.mobilePhaseStatus(phaseId),
        httpMethod: 'PATCH',
        displayTitle: 'Phase Status: $status',
        createdAt: DateTime.now(),
        payload: {'status': status},
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);
      return updated;
    }
  }
}

final mobilePhasesProvider =
    AsyncNotifierProvider<MobilePhasesNotifier, List<MobilePhaseEntity>>(
      MobilePhasesNotifier.new,
    );
