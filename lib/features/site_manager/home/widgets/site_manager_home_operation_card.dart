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

  String _localizeOperationType(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'erection':
        return context.loc.erectionPhase;
      case 'dismantling':
        return context.loc.dismantlingPhase;
      case 'standing':
      case 'standing scaffold':
        return context.loc.standingScaffold;
      default:
        return MobilePhaseLocalizer.phaseType(context, type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = MobilePhaseLocalizer.phaseColor(task.type);
    final priorityColor = MobilePhaseLocalizer.priorityColor(task.priority);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _localizeOperationType(context, task.type),
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (task.startDate != null)
                Text(
                  MobilePhaseLocalizer.formatDateRange(
                    task.startDate,
                    task.endDate,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF888888),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            task.project.name.isNotEmpty ? task.project.name : task.phaseId,
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF171717),
            ),
          ),
          if (task.project.address.isNotEmpty) ...[
            const SizedBox(height: 7),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Color(0xFF999999),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    task.project.address,
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: const Color(0xFF8A8A8A),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (task.priority.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                MobilePhaseLocalizer.priority(context, task.priority),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: priorityColor,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: onOpenRoute,
                  leadingIcon: Icons.location_on_outlined,
                  text: context.loc.route,
                  foregroundColor: const Color(0xFF777777),
                  borderColor: const Color(0xFFD9D9D9),
                  borderRadius: 7.r,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AppButton(
                  onPressed: onOpenProject,
                  text: context.loc.openProject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
