import 'package:flutter/material.dart';

import '../../../../../core/localization/localization_meta.dart';

class ProjectPhaseDateItemEntity {
  final String id;
  final String projectId;
  final String type;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final int durationDays;
  final bool safetyInspectionComplete;

  const ProjectPhaseDateItemEntity({
    required this.id,
    required this.projectId,
    required this.type,
    this.status = 'ENQUIRY',
    this.priority = 'MEDIUM',
    this.startDate,
    this.endDate,
    this.durationDays = 1,
    this.safetyInspectionComplete = false,
    this.localization,
  });

  final LocalizationMeta? localization;

  String get displayTitle {
    final cleanType = type.replaceAll('_', ' ').toLowerCase();
    if (cleanType.isEmpty) return 'Phase Schedule';
    final capitalized = cleanType.split(' ').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
    return '$capitalized Schedule';
  }

  IconData get iconData {
    final lower = type.toLowerCase();
    if (lower.contains('erection')) return Icons.construction_rounded;
    if (lower.contains('dismantl')) return Icons.handyman_rounded;
    if (lower.contains('standing')) return Icons.apartment_rounded;
    return Icons.event_note_rounded;
  }

  Color get color {
    final lower = type.toLowerCase();
    if (lower.contains('erection')) return const Color(0xFFC8102E);
    if (lower.contains('dismantl')) return const Color(0xFFF79009);
    if (lower.contains('standing')) return const Color(0xFF12B76A);
    return const Color(0xFF4F7CFF);
  }

  ProjectPhaseDateItemEntity copyWith({
    String? id,
    String? projectId,
    String? type,
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    bool? safetyInspectionComplete,
  }) {
    return ProjectPhaseDateItemEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      safetyInspectionComplete:
          safetyInspectionComplete ?? this.safetyInspectionComplete,
    );
  }
}
