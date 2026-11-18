import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/enums/app_enum.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../../../core/providers/common_provider.dart';
import '../../../../../core/storage/storage_provider.dart';
import '../../../offline_sync/models/site_manager_sync_action.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../data/datasources/mobile_inspection_datasource.dart';
import '../../data/repositories/mobile_inspection_repository_impl.dart';
import '../../domain/entities/mobile_inspection_entity.dart';
import '../../domain/repositories/mobile_inspection_repository.dart';

final mobileInspectionDataSourceProvider =
    Provider<MobileInspectionRemoteDataSource>((ref) {
      return MobileInspectionRemoteDataSourceImpl(
        apiClient: ref.watch(apiClientProvider),
        cacheService: ref.watch(siteManagerCacheServiceProvider),
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
    final payload = {
      'scaffoldArea': scaffoldArea,
      'scaffoldHeight': scaffoldHeight,
      'scaffoldType': scaffoldType,
    };

    try {
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
    } catch (_) {
      final current = state.asData?.value ?? const <MobileInspectionEntity>[];
      final item = current.firstWhere(
        (e) => e.id == id,
        orElse: () => current.first,
      );
      final updated = item.copyWith(
        status: 'SURVEY_DONE',
        scaffoldArea: scaffoldArea,
        scaffoldHeight: scaffoldHeight,
        scaffoldType: scaffoldType,
      );
      final next = current.map((e) => e.id == id ? updated : e).toList();
      state = AsyncValue.data(next);

      final action = SiteManagerSyncAction(
        id: 'inspection_$id',
        actionType: SiteManagerSyncActionType.completeInspection,
        endpoint: ApiConstants.mobileInspectionComplete(id),
        httpMethod: 'PATCH',
        displayTitle: 'Inspection: ${item.siteTitle}',
        createdAt: DateTime.now(),
        payload: payload,
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);
      return updated;
    }
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
