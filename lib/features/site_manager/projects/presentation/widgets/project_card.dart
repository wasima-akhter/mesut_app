import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../domain/entities/project_phase_card_entity.dart';
import 'project_card_badges.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});

  final ProjectPhaseCardEntity project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = project.projectName.trim().isNotEmpty
        ? project.projectName.trim()
        : project.phaseId;

    final customerText = project.customer.name.trim().isNotEmpty
        ? (project.customer.category.trim().isNotEmpty
            ? '${project.customer.name.trim()} · ${project.customer.category.trim()}'
            : project.customer.name.trim())
        : '';

    final dateRange = MobilePhaseLocalizer.formatDateRange(
      project.startDate,
      project.endDate,
    );
    final durationText = project.durationDays > 0
        ? '$dateRange (${project.durationDays} d)'
        : dateRange;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TAG ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PhaseBadge(type: project.type),
                  const SizedBox(width: 7),
                  StatusLabel(status: project.status),
                  const Spacer(),
                  PriorityBadge(priority: project.priority),
                ],
              ),

              const SizedBox(height: 9),

              // PROJECT TITLE
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF151515),
                ),
              ),

              if (customerText.isNotEmpty) ...[
                const SizedBox(height: 7),
                InfoRow(icon: Icons.business_outlined, text: customerText),
              ],

              if (project.formattedAddress.isNotEmpty &&
                  project.formattedAddress != '--') ...[
                const SizedBox(height: 5),
                InfoRow(
                  icon: Icons.location_on_outlined,
                  text: project.formattedAddress,
                ),
              ],

              if (durationText != '--') ...[
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Color(0xFF8A8A8A),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          durationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: project.type.toUpperCase() == 'STANDING'
                                ? const Color(0xFFFF7A00)
                                : const Color(0xFF888888),
                            fontWeight: project.type.toUpperCase() == 'STANDING'
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // TOTAL LOGGED HOURS & BUDGET STATUS
              if (project.hasHoursLogged) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: project.isProfitable
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: project.isProfitable
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFFECACA),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: 20.sp,
                        color: project.isProfitable
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                      ),
                      SizedBox(width: 7.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.loc.totalProjectHours,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                Text(
                                  '${project.formattedLoggedHours} hrs',
                                  style: TextStyle(
                                    fontSize: 15.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                if (project.hasBudget) ...[
                                  Flexible(
                                    child: Text(
                                      ' / ${project.formattedBudgetHours} hrs',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (project.hasBudget) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: project.isProfitable
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            project.isProfitable
                                ? context.loc.profitable
                                : context.loc.lossRisk,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: project.isProfitable
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // ASSIGNEE
              if (project.assigneeName.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                InfoRow(
                  icon: Icons.person_outline,
                  text: project.assigneeName,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
