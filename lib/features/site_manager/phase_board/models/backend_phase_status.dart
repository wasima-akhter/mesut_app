import 'package:flutter/material.dart';

import '../../../../core/localization/context_extensions.dart';

enum BackendPhaseStatus {
  enquiry('ENQUIRY'),
  orderConfirmed('ORDER_CONFIRMED'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  postponed('POSTPONED');

  final String value;
  const BackendPhaseStatus(this.value);

  static BackendPhaseStatus fromString(String raw) {
    final upper = raw.trim().toUpperCase();
    return BackendPhaseStatus.values.firstWhere(
      (e) => e.value == upper || e.name.toUpperCase() == upper,
      orElse: () => BackendPhaseStatus.enquiry,
    );
  }

  String localizedName(BuildContext context) {
    switch (this) {
      case BackendPhaseStatus.enquiry:
        return context.loc.enquiry;
      case BackendPhaseStatus.orderConfirmed:
        return context.loc.orderConfirmed;
      case BackendPhaseStatus.inProgress:
        return context.loc.inProgress;
      case BackendPhaseStatus.completed:
        return context.loc.completed;
      case BackendPhaseStatus.postponed:
        return context.loc.postponed;
    }
  }

  Color get color {
    switch (this) {
      case BackendPhaseStatus.enquiry:
        return const Color(0xFF6B7280);
      case BackendPhaseStatus.orderConfirmed:
        return const Color(0xFF2563EB);
      case BackendPhaseStatus.inProgress:
        return const Color(0xFF00A651);
      case BackendPhaseStatus.completed:
        return const Color(0xFF10B981);
      case BackendPhaseStatus.postponed:
        return const Color(0xFFF59E0B);
    }
  }

  IconData get icon {
    switch (this) {
      case BackendPhaseStatus.enquiry:
        return Icons.help_outline_rounded;
      case BackendPhaseStatus.orderConfirmed:
        return Icons.verified_outlined;
      case BackendPhaseStatus.inProgress:
        return Icons.sync_rounded;
      case BackendPhaseStatus.completed:
        return Icons.check_circle_outline_rounded;
      case BackendPhaseStatus.postponed:
        return Icons.pause_circle_outline_rounded;
    }
  }
}
