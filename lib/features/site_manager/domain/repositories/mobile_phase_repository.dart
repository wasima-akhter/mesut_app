import '../entities/mobile_phase_entity.dart';

abstract class MobilePhaseRepository {
  Future<List<MobilePhaseEntity>> getManagedPhases({
    String? column,
    int page = 1,
    int limit = 50,
  });

  Future<MobilePhaseEntity> updatePhaseStatus(String phaseId, String status);
}
