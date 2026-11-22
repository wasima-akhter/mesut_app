import 'package:flutter/material.dart';

import '../../../../../core/localization/context_extensions.dart';

abstract final class MobilePhaseLocalizer {
  static String phaseType(BuildContext context, String rawType) {
    switch (rawType.trim().toUpperCase()) {
      case 'ERECTION':
        return context.loc.erectionPhase;
      case 'DISMANTLING':
        return context.loc.dismantlingPhase;
      case 'STANDING':
      case 'STANDING_SCAFFOLD':
      case 'STANDING SCAFFOLD':
        return context.loc.standing;
      case 'MAINTENANCE':
        return context.loc.maintenancePhase;
      case 'TRANSPORT':
        return context.loc.get('activity.transport', 'Transport');
      case 'OTHER':
      case 'OTHERS':
        return context.loc.otherActivity;
      default:
        return rawType;
    }
  }

  static String priority(BuildContext context, String rawPriority) {
    switch (rawPriority.trim().toUpperCase()) {
      case 'HIGH':
        return context.loc.priorityHigh;
      case 'MEDIUM':
        return context.loc.priorityMedium;
      case 'LOW':
        return context.loc.priorityLow;
      default:
        return rawPriority;
    }
  }

  static Color phaseColor(String rawType) {
    switch (rawType.trim().toUpperCase()) {
      case 'ERECTION':
        return const Color(0xFF00A651);
      case 'DISMANTLING':
        return const Color(0xFFFF9800);
      case 'STANDING':
      case 'STANDING_SCAFFOLD':
      case 'STANDING SCAFFOLD':
        return const Color(0xFF2563EB);
      case 'MAINTENANCE':
        return const Color(0xFF7C3AED);
      case 'TRANSPORT':
        return const Color(0xFF0284C7);
      default:
        return const Color(0xFF475569);
    }
  }

  static Color priorityColor(String rawPriority) {
    switch (rawPriority.trim().toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFDC2626);
      case 'MEDIUM':
        return const Color(0xFFD97706);
      case 'LOW':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF64748B);
    }
  }

  static String status(BuildContext context, String rawStatus) {
    switch (rawStatus.trim().toUpperCase()) {
      case 'ENQUIRY':
        return context.loc.preconstruction;
      case 'ORDER_CONFIRMED':
        return context.loc.orderConfirmed;
      case 'PLANNED':
      case 'NOT_STARTED':
      case 'NOT STARTED':
        return context.loc.notStarted;
      case 'IN_PROGRESS':
      case 'IN PROGRESS':
        return context.loc.inProgress;
      case 'ON_HOLD':
      case 'ON HOLD':
        return context.loc.onHold;
      case 'POSTPONED':
        return context.loc.postponed;
      case 'COMPLETED':
        return context.loc.completed;
      case 'PENDING_APPROVAL':
      case 'PENDING':
        return context.loc.pending;
      case 'APPROVED':
        return context.loc.get('status.approved', 'Approved');
      case 'REJECTED':
        return context.loc.get('status.rejected', 'Rejected');
      case 'RUNNING':
        return context.loc.running;
      case 'SUBMITTED':
        return context.loc.get('status.submitted', 'Submitted');
      default:
        return rawStatus;
    }
  }

  static Color statusColor(String rawStatus) {
    switch (rawStatus.trim().toUpperCase()) {
      case 'ENQUIRY':
        return const Color(0xFF6B7280);
      case 'ORDER_CONFIRMED':
        return const Color(0xFF2563EB);
      case 'PLANNED':
      case 'NOT_STARTED':
      case 'NOT STARTED':
        return const Color(0xFF3B82F6);
      case 'IN_PROGRESS':
      case 'IN PROGRESS':
        return const Color(0xFF00A651);
      case 'ON_HOLD':
      case 'ON HOLD':
        return const Color(0xFFE53935);
      case 'POSTPONED':
        return const Color(0xFFF59E0B);
      case 'COMPLETED':
        return const Color(0xFF0D9488);
      case 'PENDING_APPROVAL':
      case 'PENDING':
        return const Color(0xFFD97706);
      case 'APPROVED':
        return const Color(0xFF16A34A);
      case 'REJECTED':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }

  static String formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '--';
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    if (start != null && end != null) {
      return '${fmt(start.toLocal())} – ${fmt(end.toLocal())}';
    }
    return fmt((start ?? end)!.toLocal());
  }
}
