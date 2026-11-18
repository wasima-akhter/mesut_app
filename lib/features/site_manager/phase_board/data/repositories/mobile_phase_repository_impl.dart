import '../../domain/entities/mobile_phase_entity.dart';
import '../../domain/repositories/mobile_phase_repository.dart';
import '../datasources/mobile_phase_datasource.dart';

class MobilePhaseRepositoryImpl implements MobilePhaseRepository {
  MobilePhaseRepositoryImpl(this.remoteDataSource);

  final MobilePhaseRemoteDataSource remoteDataSource;

  @override
  Future<List<MobilePhaseEntity>> getManagedPhases({
    String? column,
    int page = 1,
    int limit = 50,
  }) =>
      remoteDataSource.getManagedPhases(
        column: column,
        page: page,
        limit: limit,
      );

  @override
  Future<MobilePhaseEntity> updatePhaseStatus(String phaseId, String status) =>
      remoteDataSource.updatePhaseStatus(phaseId, status);
}
