import '../../../../../core/enums/backend_enums.dart';
import '../../../../shared/mobile_dashboard/domain/entities/mobile_project_entity.dart';

class MobileTimeLogUserEntity {
  const MobileTimeLogUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  final String id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName'.trim();
}

class MobileTimeLogEntity {
  const MobileTimeLogEntity({
    required this.id,
    required this.phaseId,
    required this.activityType,
    this.startTime,
    this.endTime,
    this.isManual = false,
    this.status = 'PENDING_APPROVAL',
    this.clientSyncId,
    this.breakMinutes = 0,
    this.netHours = 0,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  final String id;
  final String phaseId;
  final BackendActivityType activityType;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isManual;
  final String status;
  final String? clientSyncId;
  final int breakMinutes;
  final double netHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final MobileTimeLogUserEntity? user;

  MobileTimeLogEntity copyWith({
    String? id,
    String? phaseId,
    BackendActivityType? activityType,
    DateTime? startTime,
    DateTime? endTime,
    bool? isManual,
    String? status,
    String? clientSyncId,
    int? breakMinutes,
    double? netHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    MobileTimeLogUserEntity? user,
  }) {
    return MobileTimeLogEntity(
      id: id ?? this.id,
      phaseId: phaseId ?? this.phaseId,
      activityType: activityType ?? this.activityType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isManual: isManual ?? this.isManual,
      status: status ?? this.status,
      clientSyncId: clientSyncId ?? this.clientSyncId,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      netHours: netHours ?? this.netHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}

class MobileTimerStartResultEntity {
  const MobileTimerStartResultEntity({required this.timeLog, this.project});

  final MobileTimeLogEntity timeLog;
  final MobileProjectEntity? project;
}

class MobileCrewActivityHoursEntity {
  const MobileCrewActivityHoursEntity({
    required this.activityType,
    required this.hours,
  });

  final BackendActivityType activityType;
  final double hours;
}

class MobileCrewMemberSummaryEntity {
  const MobileCrewMemberSummaryEntity({
    required this.user,
    required this.totalHours,
    required this.synced,
  });

  final MobileTimeLogUserEntity user;
  final double totalHours;
  final bool synced;
}

class MobileCrewTimeEntity {
  const MobileCrewTimeEntity({
    this.totalProjectHours = 0,
    this.hoursByActivity = const [],
    this.crewBreakdown = const [],
    this.logs = const [],
  });

  final double totalProjectHours;
  final List<MobileCrewActivityHoursEntity> hoursByActivity;
  final List<MobileCrewMemberSummaryEntity> crewBreakdown;
  final List<MobileTimeLogEntity> logs;
}
