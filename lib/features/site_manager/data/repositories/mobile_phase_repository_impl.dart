import '../../domain/entities/mobile_phase_entity.dart';
import '../../domain/repositories/mobile_phase_repository.dart';
import '../datasources/mobile_phase_datasource.dart';

class MobilePhaseRepositoryImpl implements MobilePhaseRepository {
  MobilePhaseRepositoryImpl(this.remoteDataSource);

  final MobilePhaseRemoteDataSource remoteDataSource;

  @override
  Future<List<MobilePhaseEntity>> getManagedPhases() =>
      remoteDataSource.getManagedPhases();

  @override
  Future<MobilePhaseEntity> updatePhaseStatus(String phaseId, String status) =>
      remoteDataSource.updatePhaseStatus(phaseId, status);
}
