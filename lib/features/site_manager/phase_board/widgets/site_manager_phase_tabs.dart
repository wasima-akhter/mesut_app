import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';

class SiteManagerPhaseTabs extends StatelessWidget {
  const SiteManagerPhaseTabs({
    super.key,
    required this.tabs,
    required this.selectedColumn,
    required this.onTabSelected,
  });

  final List<(String, String)> tabs;
  final String selectedColumn;
  final ValueChanged<String> onTabSelected;

  Color _tabColor(String code) {
    switch (code) {
      case 'ERECTION':
        return AppColors.success;
      case 'DISMANTLING':
        return AppColors.warning;
      case 'STANDING':
        return AppColors.info;
      case 'ENQUIRY':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => SizedBox(width: 6.w),
        itemBuilder: (context, index) {
          final (code, label) = tabs[index];
          final selected = code == selectedColumn;

          return Material(
            color: selected ? AppColors.black : AppColors.surface,
            borderRadius: BorderRadius.circular(7.r),
            child: InkWell(
              onTap: () => onTabSelected(code),
              borderRadius: BorderRadius.circular(7.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Row(
                  children: [
                    if (code != 'ALL')
                      Container(
                        width: 7.w,
                        height: 7.w,
                        margin: EdgeInsets.only(right: 6.w),
                        decoration: BoxDecoration(
                          color: _tabColor(code),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: selected
                                ? AppColors.white
                                : AppColors.textSecondary,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
