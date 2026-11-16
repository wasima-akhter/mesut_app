import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../localization/context_extensions.dart';
import '../widgets/lists/app_pagination_loader.dart';

class AppPaginationFooter extends StatelessWidget {
  const AppPaginationFooter({
    super.key,
    required this.hasMore,
    required this.isLoadingMore,
    this.itemCount = 0,
    this.endText,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final int itemCount;
  final String? endText;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const AppPaginationLoader(height: 52);
    }

    if (!hasMore && itemCount > 0) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32.w,
                height: 1,
                color: AppColors.border,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  endText ?? context.loc.noOtherItemsAvailable,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 32.w,
                height: 1,
                color: AppColors.border,
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
