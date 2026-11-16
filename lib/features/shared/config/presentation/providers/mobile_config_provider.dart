import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/app_language.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../../../core/storage/storage_provider.dart';
import '../../data/datasources/mobile_config_datasource.dart';
import '../../data/repositories/mobile_config_repository_impl.dart';
import '../../domain/entities/mobile_config_entity.dart';
import '../../domain/repositories/mobile_config_repository.dart';

final mobileConfigDataSourceProvider = Provider<MobileConfigDataSource>((ref) {
  return MobileConfigRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

final mobileConfigRepositoryProvider = Provider<MobileConfigRepository>((ref) {
  return MobileConfigRepositoryImpl(ref.watch(mobileConfigDataSourceProvider));
});

class MobileConfigNotifier extends AsyncNotifier<MobileConfigEntity> {
  @override
  Future<MobileConfigEntity> build() async {
    final repo = ref.watch(mobileConfigRepositoryProvider);
    final cached = repo.getCachedConfig();
    final storage = ref.read(storageServiceProvider);

    // Avoid firing authenticated /mobile/config before a session exists.
    final hasValidToken = await storage.hasValidAccessToken();
    if (!hasValidToken) {
      return cached ?? const MobileConfigEntity();
    }

    try {
      final remote = await repo.fetchConfig();
      await _applyDefaultLanguageIfUnset(remote);
      return remote;
    } catch (_) {
      return cached ?? const MobileConfigEntity();
    }
  }

  Future<MobileConfigEntity> refresh() async {
    final repo = ref.read(mobileConfigRepositoryProvider);
    try {
      final remote = await repo.fetchConfig();
      await _applyDefaultLanguageIfUnset(remote);
      state = AsyncValue.data(remote);
      return remote;
    } catch (e) {
      final cached = repo.getCachedConfig() ?? const MobileConfigEntity();
      state = AsyncValue.data(cached);
      return cached;
    }
  }

  Future<void> _applyDefaultLanguageIfUnset(MobileConfigEntity config) async {
    final storage = ref.read(storageServiceProvider);
    if (storage.hasUserSelectedLanguage) return;

    final defaultLang = AppLanguage.fromCode(config.defaultLanguage);
    await ref
        .read(appLanguageProvider.notifier)
        .applyServerDefault(defaultLang);
  }
}

final mobileConfigProvider =
    AsyncNotifierProvider<MobileConfigNotifier, MobileConfigEntity>(
      MobileConfigNotifier.new,
    );

/// Languages enabled by backend `/mobile/config` (falls back to all AppLanguage values).
final enabledLanguagesProvider = Provider<List<AppLanguage>>((ref) {
  final configAsync = ref.watch(mobileConfigProvider);
  return configAsync.maybeWhen(
    data: (config) => config.supportedAppLanguages,
    orElse: () => AppLanguage.values,
  );
});

/// Backend flag `CompanyProfile.allowEmployeeManualTime` from `/mobile/config`.
final allowEmployeeManualTimeProvider = Provider<bool>((ref) {
  final configAsync = ref.watch(mobileConfigProvider);
  return configAsync.maybeWhen(
    data: (config) => config.allowEmployeeManualTime,
    orElse: () => true,
  );
});

final privacyPolicyHtmlProvider = Provider<String?>((ref) {
  final configAsync = ref.watch(mobileConfigProvider);
  return configAsync.maybeWhen(
    data: (config) => config.privacyPolicyHtml,
    orElse: () => null,
  );
});

final termsConditionsHtmlProvider = Provider<String?>((ref) {
  final configAsync = ref.watch(mobileConfigProvider);
  return configAsync.maybeWhen(
    data: (config) => config.termsAndConditionsHtml,
    orElse: () => null,
  );
});
