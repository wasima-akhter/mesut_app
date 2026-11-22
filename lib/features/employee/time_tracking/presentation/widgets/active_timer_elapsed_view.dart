import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import '../providers/employee_timer_provider.dart';

class ActiveTimerElapsedView extends ConsumerWidget {
  const ActiveTimerElapsedView({super.key, required this.isOnBreak});

  final bool isOnBreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatted = ref.watch(
      employeeTimerProvider.select((s) => s.formattedElapsed),
    );

    return RepaintBoundary(
      child: Text(
        formatted,
        style: TextStyle(
          fontSize: 44.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: isOnBreak ? const Color(0xFFC47A0A) : AppColors.success,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
