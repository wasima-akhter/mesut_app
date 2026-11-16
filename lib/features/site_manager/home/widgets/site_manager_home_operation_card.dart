import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_dashboard_entity.dart';
import '../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';

class SiteManagerHomeOperationCard extends StatelessWidget {
  const SiteManagerHomeOperationCard({
    super.key,
    required this.task,
    required this.onOpenProject,
    required this.onOpenRoute,
  });

  final UpcomingTaskEntity task;
  final VoidCallback onOpenProject;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final typeColor = MobilePhaseLocalizer.phaseColor(task.type);
    final priorityColor = MobilePhaseLocalizer.priorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pill(
                text: MobilePhaseLocalizer.phaseType(context, task.type),
                color: typeColor,
              ),
              const SizedBox(width: 8),
              _Pill(
                text: MobilePhaseLocalizer.priority(context, task.priority),
                color: priorityColor,
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  MobilePhaseLocalizer.formatDateRange(
                    task.startDate,
                    task.endDate,
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.project.name.isEmpty ? task.phaseId : task.project.name,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          if (task.project.address.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.project.address,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: onOpenRoute,
                  leadingIcon: Icons.directions_outlined,
                  text: context.loc.navigation,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  onPressed: onOpenProject,
                  text: context.loc.mapOpenProject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
