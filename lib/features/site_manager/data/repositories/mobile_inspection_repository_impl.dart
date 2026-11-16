import '../../domain/entities/mobile_inspection_entity.dart';
import '../../domain/repositories/mobile_inspection_repository.dart';
import '../datasources/mobile_inspection_datasource.dart';

class MobileInspectionRepositoryImpl implements MobileInspectionRepository {
  MobileInspectionRepositoryImpl(this.remoteDataSource);

  final MobileInspectionRemoteDataSource remoteDataSource;

  @override
  Future<List<MobileInspectionEntity>> getInspections() =>
      remoteDataSource.getInspections();

  @override
  Future<MobileInspectionEntity> getInspectionById(String id) =>
      remoteDataSource.getInspectionById(id);

  @override
  Future<MobileInspectionEntity> completeInspection(
    String id, {
    required double scaffoldArea,
    required double scaffoldHeight,
    required String scaffoldType,
  }) =>
      remoteDataSource.completeInspection(
        id,
        scaffoldArea: scaffoldArea,
        scaffoldHeight: scaffoldHeight,
        scaffoldType: scaffoldType,
      );
}
