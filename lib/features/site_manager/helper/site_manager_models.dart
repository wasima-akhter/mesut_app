import 'site_manager_enums.dart';

class MapLocation {
  final String id;
  final String type;
  final String priority;
  final String title;
  final String company;
  final String address;
  final String date;
  final String image;

  /// Percentage-like position on the map.
  final double x;
  final double y;

  const MapLocation({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.company,
    required this.address,
    required this.date,
    required this.image,
    required this.x,
    required this.y,
  });
}

class TimeEntryModel {
  const TimeEntryModel({
    required this.id,
    required this.project,
    required this.activity,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.breakTime,
    required this.employee,
    this.isSynced = true,
  });

  final String id;
  final String project;
  final ActivityType activity;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String breakTime;
  final String employee;
  final bool isSynced;

  String get duration => '7h 30min';
}

//

class CrewMemberModel {
  const CrewMemberModel({
    required this.name,
    required this.activity,
    required this.startTime,
    required this.endTime,
    required this.breakTime,
    required this.totalHours,
    this.avatar,
    this.isSynced = true,
  });

  final String name;
  final ActivityType activity;

  final String startTime;
  final String endTime;
  final String breakTime;
  final String totalHours;

  final String? avatar;
  final bool isSynced;

  CrewMemberModel copyWith({
    String? name,
    ActivityType? activity,
    String? startTime,
    String? endTime,
    String? breakTime,
    String? totalHours,
    String? avatar,
    bool? isSynced,
  }) {
    return CrewMemberModel(
      name: name ?? this.name,
      activity: activity ?? this.activity,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      breakTime: breakTime ?? this.breakTime,
      totalHours: totalHours ?? this.totalHours,
      avatar: avatar ?? this.avatar,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
