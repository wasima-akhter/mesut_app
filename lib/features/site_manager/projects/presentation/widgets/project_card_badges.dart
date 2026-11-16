import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';

class PhaseBadge extends StatelessWidget {
  final String type;

  const PhaseBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type.trim().isEmpty) return const SizedBox.shrink();
    final color = MobilePhaseLocalizer.phaseColor(type);
    final label = MobilePhaseLocalizer.phaseType(context, type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    if (priority.trim().isEmpty) return const SizedBox.shrink();
    final color = MobilePhaseLocalizer.priorityColor(priority);
    final label = MobilePhaseLocalizer.priority(context, priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class StatusLabel extends StatelessWidget {
  final String status;

  const StatusLabel({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status.trim().isEmpty) return const SizedBox.shrink();
    final color = MobilePhaseLocalizer.statusColor(status);
    final label = MobilePhaseLocalizer.status(context, status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            color: color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final clean = text.trim();
    if (clean.isEmpty || clean == '--') return const SizedBox.shrink();
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8C8C8C)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            clean,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15.5.sp, color: const Color(0xFF858585)),
          ),
        ),
      ],
    );
  }
}
