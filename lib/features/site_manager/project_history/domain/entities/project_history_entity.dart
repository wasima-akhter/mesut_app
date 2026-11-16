import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectHistoryUserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String role;

  const ProjectHistoryUserEntity({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.role = '',
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'User';
  }

  String get roleFormatted {
    if (role.isEmpty) return '';
    return role.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

class ProjectHistoryEntity {
  final String id;
  final String action;
  final String details;
  final DateTime? createdAt;
  final ProjectHistoryUserEntity? user;

  const ProjectHistoryEntity({
    required this.id,
    required this.action,
    required this.details,
    this.createdAt,
    this.user,
  });

  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('MMM d, yyyy • hh:mm a').format(createdAt!.toLocal());
  }

  String get userDescription {
    if (user == null) return 'System';
    final role = user!.roleFormatted;
    if (role.isNotEmpty) {
      return '${user!.fullName} ($role)';
    }
    return user!.fullName;
  }

  String get displayTitle {
    var raw = action.trim();
    if (raw.startsWith('MOBILE_')) {
      raw = raw.substring(7);
    }
    final words = raw.split('_').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).toList();
    return words.join(' ');
  }

  bool get hasDetails => details.trim().isNotEmpty && details.trim() != '{}';

  List<MapEntry<String, String>> get formattedDetailEntries {
    if (!hasDetails) return [];

    try {
      final decoded = jsonDecode(details);
      if (decoded is Map<String, dynamic>) {
        final entries = <MapEntry<String, String>>[];

        // Handle phase change transition
        if (decoded.containsKey('oldPhase') && decoded.containsKey('phase')) {
          entries.add(MapEntry(
            'Phase',
            '${decoded['oldPhase']} → ${decoded['phase']}',
          ));
        }

        // Handle duration transition
        if (decoded.containsKey('oldDuration') &&
            decoded.containsKey('duration')) {
          entries.add(MapEntry(
            'Duration',
            '${decoded['oldDuration']} → ${decoded['duration']}',
          ));
        }

        decoded.forEach((key, val) {
          if (val == null) return;
          final strVal = val.toString().trim();
          if (strVal.isEmpty) return;

          // Ignore raw internal IDs
          final lowerKey = key.toLowerCase();
          if (lowerKey == 'id' ||
              lowerKey.endsWith('id') ||
              lowerKey == 'uuid' ||
              key == 'oldPhase' ||
              key == 'phase' ||
              key == 'oldDuration' ||
              key == 'duration') {
            return;
          }

          final formattedKey = _humanizeKey(key);
          entries.add(MapEntry(formattedKey, strVal));
        });

        if (entries.isNotEmpty) return entries;
      }
    } catch (_) {
      // Not a JSON string
    }

    return [MapEntry('', details.trim())];
  }

  static String _humanizeKey(String key) {
    if (key == 'name') return 'Project Name';
    final result = StringBuffer();
    for (int i = 0; i < key.length; i++) {
      final char = key[i];
      if (i > 0 &&
          char.toUpperCase() == char &&
          char.toLowerCase() != char &&
          key[i - 1] != '_') {
        result.write(' ');
      }
      result.write(char == '_' ? ' ' : char);
    }
    final words = result.toString().trim().split(' ').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    });
    return words.join(' ');
  }

  IconData get iconData {
    final lowerAction = action.toLowerCase();
    final lowerDetails = details.toLowerCase();

    if (lowerAction.contains('create') || lowerDetails.contains('created')) {
      return Icons.add_circle_outline_rounded;
    }
    if (lowerAction.contains('phase') || lowerDetails.contains('phase')) {
      return Icons.swap_horiz_rounded;
    }
    if (lowerAction.contains('duration') || lowerDetails.contains('duration')) {
      return Icons.access_time_rounded;
    }
    if (lowerAction.contains('photo') ||
        lowerAction.contains('attachment') ||
        lowerDetails.contains('photo')) {
      return Icons.camera_alt_outlined;
    }
    if (lowerAction.contains('delete') || lowerDetails.contains('deleted')) {
      return Icons.delete_outline_rounded;
    }
    if (lowerAction.contains('status') || lowerDetails.contains('status')) {
      return Icons.flag_outlined;
    }
    return Icons.history_rounded;
  }

  Color get actionColor {
    final lowerAction = action.toLowerCase();
    if (lowerAction.contains('create')) return const Color(0xFF12B76A);
    if (lowerAction.contains('phase')) return const Color(0xFF4F7CFF);
    if (lowerAction.contains('photo') || lowerAction.contains('attachment')) {
      return const Color(0xFFF79009);
    }
    if (lowerAction.contains('delete')) return const Color(0xFFF04438);
    if (lowerAction.contains('status')) return const Color(0xFF7B61FF);
    return const Color(0xFF026AA2);
  }
}

class ProjectHistoryMetaEntity {
  final int total;
  final int totalPages;
  final int currentPage;

  const ProjectHistoryMetaEntity({
    this.total = 0,
    this.totalPages = 1,
    this.currentPage = 1,
  });
}

class ProjectHistoryResponseEntity {
  final List<ProjectHistoryEntity> items;
  final ProjectHistoryMetaEntity meta;

  const ProjectHistoryResponseEntity({
    this.items = const [],
    this.meta = const ProjectHistoryMetaEntity(),
  });
}
