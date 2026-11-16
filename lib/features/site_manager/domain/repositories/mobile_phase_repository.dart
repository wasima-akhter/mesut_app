import '../entities/mobile_phase_entity.dart';

abstract class MobilePhaseRepository {
  Future<List<MobilePhaseEntity>> getManagedPhases();

  Future<MobilePhaseEntity> updatePhaseStatus(String phaseId, String status);
}
