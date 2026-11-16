import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/app_enum.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/providers/common_provider.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../data/datasources/mobile_inspection_datasource.dart';
import '../../data/repositories/mobile_inspection_repository_impl.dart';
import '../../domain/entities/mobile_inspection_entity.dart';
import '../../domain/repositories/mobile_inspection_repository.dart';

final mobileInspectionDataSourceProvider =
    Provider<MobileInspectionRemoteDataSource>((ref) {
      return MobileInspectionRemoteDataSourceImpl(
        apiClient: ref.watch(apiClientProvider),
      );
    });

final mobileInspectionRepositoryProvider = Provider<MobileInspectionRepository>(
  (ref) {
    return MobileInspectionRepositoryImpl(
      ref.watch(mobileInspectionDataSourceProvider),
    );
  },
);

class MobileInspectionsNotifier
    extends AsyncNotifier<List<MobileInspectionEntity>> {
  @override
  Future<List<MobileInspectionEntity>> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.watch(userRoleProvider);
    if (!hasToken || role != UserRole.siteManager) return const [];
    return ref.watch(mobileInspectionRepositoryProvider).getInspections();
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
      () => ref.read(mobileInspectionRepositoryProvider).getInspections(),
    );
  }

  Future<MobileInspectionEntity> completeInspection(
    String id, {
    required double scaffoldArea,
    required double scaffoldHeight,
    required String scaffoldType,
  }) async {
    final updated = await ref
        .read(mobileInspectionRepositoryProvider)
        .completeInspection(
          id,
          scaffoldArea: scaffoldArea,
          scaffoldHeight: scaffoldHeight,
          scaffoldType: scaffoldType,
        );
    final current = state.asData?.value ?? const <MobileInspectionEntity>[];
    final next = current.map((e) => e.id == id ? updated : e).toList();
    state = AsyncValue.data(next);
    return updated;
  }
}

final mobileInspectionsProvider =
    AsyncNotifierProvider<
      MobileInspectionsNotifier,
      List<MobileInspectionEntity>
    >(MobileInspectionsNotifier.new);

final mobileInspectionDetailProvider =
    FutureProvider.family<MobileInspectionEntity, String>((ref, id) {
      return ref
          .watch(mobileInspectionRepositoryProvider)
          .getInspectionById(id);
    });

class _SelectedInspectionIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedInspectionIdProvider =
    NotifierProvider<_SelectedInspectionIdNotifier, String?>(
      _SelectedInspectionIdNotifier.new,
    );
