import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/app_enum.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/providers/common_provider.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../data/datasources/mobile_phase_datasource.dart';
import '../../data/repositories/mobile_phase_repository_impl.dart';
import '../../domain/entities/mobile_phase_entity.dart';
import '../../domain/repositories/mobile_phase_repository.dart';

final mobilePhaseDataSourceProvider = Provider<MobilePhaseRemoteDataSource>((
  ref,
) {
  return MobilePhaseRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
  );
});

final mobilePhaseRepositoryProvider = Provider<MobilePhaseRepository>((ref) {
  return MobilePhaseRepositoryImpl(ref.watch(mobilePhaseDataSourceProvider));
});

class MobilePhasesNotifier extends AsyncNotifier<List<MobilePhaseEntity>> {
  @override
  Future<List<MobilePhaseEntity>> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.watch(userRoleProvider);
    if (!hasToken || role != UserRole.siteManager) return const [];
    return ref.watch(mobilePhaseRepositoryProvider).getManagedPhases();
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
      () => ref.read(mobilePhaseRepositoryProvider).getManagedPhases(),
    );
  }

  Future<MobilePhaseEntity> updateStatus(String phaseId, String status) async {
    final updated = await ref
        .read(mobilePhaseRepositoryProvider)
        .updatePhaseStatus(phaseId, status);
    final current = state.asData?.value ?? const <MobilePhaseEntity>[];
    final next = current.map((e) => e.id == phaseId ? updated : e).toList();
    state = AsyncValue.data(next);
    return updated;
  }
}

final mobilePhasesProvider =
    AsyncNotifierProvider<MobilePhasesNotifier, List<MobilePhaseEntity>>(
      MobilePhasesNotifier.new,
    );
