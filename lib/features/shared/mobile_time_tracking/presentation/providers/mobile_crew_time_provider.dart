import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums/app_enum.dart';
import '../../../../../core/providers/common_provider.dart';
import '../../../../../core/storage/storage_provider.dart';
import '../../domain/entities/mobile_time_log_entity.dart';
import 'mobile_time_tracking_provider.dart';

class MobileCrewTimeNotifier extends AsyncNotifier<MobileCrewTimeEntity?> {
  String? _projectId;
  DateTime? _date;
  int _page = 1;
  int _limit = 10;

  String? get projectId => _projectId;
  DateTime? get date => _date;
  int get page => _page;
  int get limit => _limit;

  @override
  Future<MobileCrewTimeEntity?> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.watch(userRoleProvider);
    if (!hasToken || role != UserRole.siteManager || _projectId == null) {
      return null;
    }
    return ref.watch(mobileTimeTrackingRepositoryProvider).getCrewTime(
          projectId: _projectId!,
          date: _date,
          page: _page,
          limit: _limit,
        );
  }

  Future<void> load({
    required String projectId,
    DateTime? date,
    int page = 1,
    int limit = 10,
  }) async {
    _projectId = projectId;
    _date = date;
    _page = page;
    _limit = limit;
    await refresh();
  }

  Future<void> setPage(int page) async {
    if (_projectId == null || page == _page) return;
    _page = page;
    await refresh();
  }

  Future<void> refresh() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.read(userRoleProvider);
    final pid = _projectId;
    if (!hasToken ||
        role != UserRole.siteManager ||
        pid == null ||
        pid.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(mobileTimeTrackingRepositoryProvider).getCrewTime(
            projectId: pid,
            date: _date,
            page: _page,
            limit: _limit,
          ),
    );
  }
}

final mobileCrewTimeProvider =
    AsyncNotifierProvider<MobileCrewTimeNotifier, MobileCrewTimeEntity?>(
      MobileCrewTimeNotifier.new,
    );
