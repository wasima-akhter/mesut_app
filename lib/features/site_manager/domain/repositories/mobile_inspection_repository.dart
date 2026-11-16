import '../entities/mobile_inspection_entity.dart';

abstract class MobileInspectionRepository {
  Future<List<MobileInspectionEntity>> getInspections();

  Future<MobileInspectionEntity> getInspectionById(String id);

  Future<MobileInspectionEntity> completeInspection(
    String id, {
    required double scaffoldArea,
    required double scaffoldHeight,
    required String scaffoldType,
  });
}
