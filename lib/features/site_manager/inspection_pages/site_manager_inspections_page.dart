import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../presentation/providers/site_manager_inspections_provider.dart';

// ============================================================
// MODELS
// ============================================================

enum InspectionStatus { pending, completed }

class SiteInspectionModel {
  final String projectId;
  final String projectName;
  final String company;
  final String type;
  final String address;
  final String inspector;
  final String appointment;
  final InspectionStatus status;

  const SiteInspectionModel({
    required this.projectId,
    required this.projectName,
    required this.company,
    required this.type,
    required this.address,
    required this.inspector,
    required this.appointment,
    required this.status,
  });
}

class CalendarEventModel {
  final String projectId;
  final String title;
  final String address;
  final String type;
  final String dateRange;
  final String time;
  final String assignee;
  final Color color;

  const CalendarEventModel({
    required this.projectId,
    required this.title,
    required this.address,
    required this.type,
    required this.dateRange,
    required this.time,
    required this.assignee,
    required this.color,
  });
}

// ============================================================
// 1. SITE INSPECTION - PENDING
// ============================================================

class SiteInspectionPage extends ConsumerWidget {
  const SiteInspectionPage({
    super.key,
    this.initialStatus = InspectionStatus.pending,
  });

  final InspectionStatus initialStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionState = ref.watch(siteInspectionProvider);
    final items = inspectionState.filteredInspections;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            InspectionHeader(title: context.loc.siteInspection),

            SizedBox(height: 12.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: InspectionStatusTabs(
                selected: inspectionState.selectedStatus,
                onChanged: (status) {
                  ref.read(siteInspectionProvider.notifier).setStatus(status);
                },
              ),
            ),

            SizedBox(height: 12.h),

            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 20.h),
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return SiteInspectionCard(
                    inspection: item,
                    onPrimaryAction: () {
                      if (item.status == InspectionStatus.pending) {
                        context.push(
                          RouteConstants.siteManagerInspectionSurveyPage,
                        );
                      } else {
                        context.push(RouteConstants.siteManagerProjectDetail);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COMMON HEADER
// ============================================================

class InspectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const InspectionHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 18.h, 12.w, 0),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack ?? () => context.pop(),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 19.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          ...actions,
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 24.sp, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ============================================================
// PENDING / COMPLETED TABS
// ============================================================

class InspectionStatusTabs extends StatelessWidget {
  final InspectionStatus selected;
  final ValueChanged<InspectionStatus> onChanged;

  const InspectionStatusTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _tab(context, context.loc.pending, InspectionStatus.pending),
          _tab(context, context.loc.completed, InspectionStatus.completed),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String title, InspectionStatus value) {
    final selectedValue = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selectedValue ? AppColors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: selectedValue ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SITE INSPECTION CARD
// ============================================================

class SiteInspectionCard extends StatelessWidget {
  final SiteInspectionModel inspection;
  final VoidCallback? onPrimaryAction;

  const SiteInspectionCard({
    super.key,
    required this.inspection,
    this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final completed = inspection.status == InspectionStatus.completed;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBadge(
            text: completed ? context.loc.completed : inspection.appointment,
            color: completed ? AppColors.success : AppColors.warning,
          ),

          SizedBox(height: 12.h),

          Text(
            inspection.projectName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 9.h),

          _InfoRow(
            icon: Icons.business_outlined,
            text: '${inspection.company} • ${inspection.type}',
          ),

          SizedBox(height: 8.h),

          _InfoRow(icon: Icons.location_on_outlined, text: inspection.address),

          SizedBox(height: 14.h),

          Divider(height: 1, color: AppColors.border),

          SizedBox(height: 11.h),

          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 19.sp,
                color: AppColors.textSecondary,
              ),

              SizedBox(width: 7.w),

              Expanded(
                child: Text(
                  inspection.inspector,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              if (onPrimaryAction != null)
                SmallRedButton(
                  text: completed
                      ? context.loc.openProject
                      : context.loc.startSurvey,
                  onTap: onPrimaryAction!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 16.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.textSecondary),

        SizedBox(width: 7.w),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SMALL RED BUTTON
// ============================================================

class SmallRedButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SmallRedButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 16.sp,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
