import 'package:flutter/material.dart';

import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/localization/localization_meta.dart';
import 'employee_enums.dart';

class EmployeeAssignmentModel {
  final String? projectId;
  final String? phaseId;
  final String project;
  final String address;
  final EmployeeActivityType activity;
  final String schedule;
  final TimeOfDay? startTimeOfDay;
  final TimeOfDay? endTimeOfDay;
  final String scaffoldArea;
  final String siteManager;
  final String? totalProjectHours;
  final double? latitude;
  final double? longitude;
  final LocalizationMeta? localization;

  const EmployeeAssignmentModel({
    this.projectId,
    this.phaseId,
    required this.project,
    required this.address,
    required this.activity,
    required this.schedule,
    this.startTimeOfDay,
    this.endTimeOfDay,
    required this.scaffoldArea,
    required this.siteManager,
    this.totalProjectHours = '142.5h',
    this.latitude,
    this.longitude,
    this.localization,
  });

  String get formattedSchedule {
    if (startTimeOfDay != null && endTimeOfDay != null) {
      return '${startTimeOfDay!.formatLocalized()} – ${endTimeOfDay!.formatLocalized()}';
    }
    return schedule;
  }
}

//

class EmployeeProjectModel {
  final String id;
  final String? phaseId;
  final String name;
  final String address;
  final EmployeeActivityType activity;
  final String startTime;
  final String endTime;
  final TimeOfDay? startTimeOfDay;
  final TimeOfDay? endTimeOfDay;
  final String siteManager;
  final LocalizationMeta? localization;

  const EmployeeProjectModel({
    required this.id,
    this.phaseId,
    required this.name,
    this.address = '',
    this.activity = EmployeeActivityType.erection,
    this.startTime = '07:30 am',
    this.endTime = '04:15 pm',
    this.startTimeOfDay,
    this.endTimeOfDay,
    this.siteManager = '',
    this.localization,
  });

  String get effectivePhaseId =>
      (phaseId != null && phaseId!.trim().isNotEmpty) ? phaseId!.trim() : id.trim();

  String get fullName => name;

  String get displayName => fullName;

  EmployeeProjectModel copyWith({
    String? id,
    String? phaseId,
    String? name,
    String? address,
    EmployeeActivityType? activity,
    String? startTime,
    String? endTime,
    TimeOfDay? startTimeOfDay,
    TimeOfDay? endTimeOfDay,
    String? siteManager,
    LocalizationMeta? localization,
  }) {
    return EmployeeProjectModel(
      id: id ?? this.id,
      phaseId: phaseId ?? this.phaseId,
      name: name ?? this.name,
      address: address ?? this.address,
      activity: activity ?? this.activity,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startTimeOfDay: startTimeOfDay ?? this.startTimeOfDay,
      endTimeOfDay: endTimeOfDay ?? this.endTimeOfDay,
      siteManager: siteManager ?? this.siteManager,
      localization: localization ?? this.localization,
    );
  }

  String get formattedStartTime {
    if (startTimeOfDay != null) {
      return startTimeOfDay!.formatLocalized();
    }
    return startTime;
  }

  String get formattedEndTime {
    if (endTimeOfDay != null) {
      return endTimeOfDay!.formatLocalized();
    }
    return endTime;
  }

  String get formattedTimeRange => '$formattedStartTime – $formattedEndTime';
}

class EmployeeTimeLogModel {
  final String date;
  final DateTime? timestamp;
  final EmployeeProjectModel project;
  final String duration;
  final double? durationHours;
  final String breakTime;
  final Duration? breakDuration;
  final bool synced;
  final LocalizationMeta? localization;

  const EmployeeTimeLogModel({
    this.date = '',
    this.timestamp,
    required this.project,
    this.duration = '8.0',
    this.durationHours,
    this.breakTime = '45m',
    this.breakDuration,
    required this.synced,
    this.localization,
  });

  String get formattedDate {
    if (timestamp != null) {
      return timestamp!.formatRelative(includeTime: false);
    }
    return date;
  }

  String get formattedBreakTime {
    if (breakDuration != null) {
      return breakDuration!.formatCompactLocalized();
    }
    return breakTime;
  }

  String get formattedDuration {
    if (durationHours != null) {
      return durationHours.toString();
    }
    return duration;
  }
}

class EmployeeCalendarEventModel {
  final DateTime date;
  final EmployeeProjectModel project;

  const EmployeeCalendarEventModel({required this.date, required this.project});
}

final List<EmployeeAssignmentModel> fakeAssignments = [
  const EmployeeAssignmentModel(
    project: 'Skyline Tower',
    address: 'Gulshan Avenue, Dhaka',
    activity: EmployeeActivityType.dismantling,
    schedule: '08:00 AM - 05:00 PM',
    startTimeOfDay: TimeOfDay(hour: 8, minute: 0),
    endTimeOfDay: TimeOfDay(hour: 17, minute: 0),
    scaffoldArea: 'North Wing - Level 8',
    siteManager: 'Rahim Ahmed',
  ),
  const EmployeeAssignmentModel(
    project: 'Green Valley Complex',
    address: 'Banani, Dhaka',
    activity: EmployeeActivityType.erection,
    schedule: '09:00 AM - 04:00 PM',
    startTimeOfDay: TimeOfDay(hour: 9, minute: 0),
    endTimeOfDay: TimeOfDay(hour: 16, minute: 0),
    scaffoldArea: 'Building B - Level 5',
    siteManager: 'Tanvir Hasan',
  ),
  const EmployeeAssignmentModel(
    project: 'Riverside Plaza',
    address: 'Uttara, Dhaka',
    activity: EmployeeActivityType.others,
    schedule: '07:30 AM - 03:30 PM',
    startTimeOfDay: TimeOfDay(hour: 7, minute: 30),
    endTimeOfDay: TimeOfDay(hour: 15, minute: 30),
    scaffoldArea: 'East Block - Level 3',
    siteManager: 'Karim Hossain',
  ),
  const EmployeeAssignmentModel(
    project: 'City Center Mall',
    address: 'Dhanmondi, Dhaka',
    activity: EmployeeActivityType.dismantling,
    schedule: '10:00 AM - 06:00 PM',
    startTimeOfDay: TimeOfDay(hour: 10, minute: 0),
    endTimeOfDay: TimeOfDay(hour: 18, minute: 0),
    scaffoldArea: 'Main Entrance - Level 2',
    siteManager: 'Sabbir Rahman',
  ),
  const EmployeeAssignmentModel(
    project: 'Lakeview Residences',
    address: 'Mirpur, Dhaka',
    activity: EmployeeActivityType.erection,
    schedule: '08:30 AM - 05:30 PM',
    startTimeOfDay: TimeOfDay(hour: 8, minute: 30),
    endTimeOfDay: TimeOfDay(hour: 17, minute: 30),
    scaffoldArea: 'Tower A - Level 12',
    siteManager: 'Nayeem Islam',
  ),
];
