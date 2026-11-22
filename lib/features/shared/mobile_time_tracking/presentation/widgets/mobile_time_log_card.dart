import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/translation/translation_status_badge.dart';
import '../../../mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../domain/entities/mobile_time_log_entity.dart';

class MobileTimeLogCard extends StatelessWidget {
  const MobileTimeLogCard({super.key, required this.log});

  final MobileTimeLogEntity log;

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final activityColor = MobilePhaseLocalizer.phaseColor(
      log.activityType.serializedName,
    );
    final statusColor = log.status == 'APPROVED'
        ? const Color(0xFF16A34A)
        : (log.status == 'REJECTED'
              ? const Color(0xFFDC2626)
              : const Color(0xFFD97706));

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Tag(
                        label: MobilePhaseLocalizer.phaseType(
                          context,
                          log.activityType.serializedName,
                        ),
                        color: activityColor,
                      ),
                      _Tag(
                        label: log.isManual
                            ? context.loc.manualLabel
                            : context.loc.timerLabel,
                        color: const Color(0xFF475569),
                      ),
                      if (log.localization != null)
                        TranslationStatusBadge.fromMeta(log.localization),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '${log.netHours.toStringAsFixed(2)} h',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${_formatTime(log.startTime)} – ${_formatTime(log.endTime)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (log.breakMinutes > 0) ...[
                  SizedBox(width: 12.w),
                  Text(
                    '• ${context.loc.breakLabel}: ${log.breakMinutes}m',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  log.status,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            if (log.user != null && log.user!.fullName.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                log.user!.fullName,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
