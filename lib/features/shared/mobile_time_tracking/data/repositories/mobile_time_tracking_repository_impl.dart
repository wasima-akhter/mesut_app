import '../../../../../core/enums/backend_enums.dart';
import '../../domain/entities/mobile_time_log_entity.dart';
import '../../domain/repositories/mobile_time_tracking_repository.dart';
import '../datasources/mobile_time_tracking_datasource.dart';

class MobileTimeTrackingRepositoryImpl implements MobileTimeTrackingRepository {
  MobileTimeTrackingRepositoryImpl(this.remoteDataSource);

  final MobileTimeTrackingRemoteDataSource remoteDataSource;

  @override
  Future<MobileTimerStartResultEntity> startTimer({
    required String phaseId,
    required BackendActivityType activityType,
    double? gpsStartLat,
    double? gpsStartLng,
  }) => remoteDataSource.startTimer(
    phaseId: phaseId,
    activityType: activityType,
    gpsStartLat: gpsStartLat,
    gpsStartLng: gpsStartLng,
  );

  @override
  Future<MobileTimeLogEntity> stopTimer({
    required String timeLogId,
    double? gpsEndLat,
    double? gpsEndLng,
  }) => remoteDataSource.stopTimer(
    timeLogId: timeLogId,
    gpsEndLat: gpsEndLat,
    gpsEndLng: gpsEndLng,
  );

  @override
  Future<MobileTimeLogEntity> logManualTime({
    required String phaseId,
    required BackendActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  }) => remoteDataSource.logManualTime(
    phaseId: phaseId,
    activityType: activityType,
    startTime: startTime,
    endTime: endTime,
    breakMinutes: breakMinutes,
  );

  @override
  Future<List<MobileTimeLogEntity>> getTimeLogs({String period = 'TODAY'}) =>
      remoteDataSource.getTimeLogs(period: period);

  @override
  Future<MobileCrewTimeEntity> getCrewTime({
    required String projectId,
    DateTime? date,
  }) => remoteDataSource.getCrewTime(projectId: projectId, date: date);
}
