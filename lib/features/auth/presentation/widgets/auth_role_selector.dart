import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/enums/app_enum.dart';
import '../../../../core/localization/context_extensions.dart';

class AuthRoleSelector extends StatelessWidget {
  const AuthRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return Row(
      children: [
        Expanded(
          child: _RoleOptionCard(
            label: loc.roleEmployee,
            icon: Icons.person_outline_rounded,
            isSelected: selectedRole == UserRole.employee,
            onTap: () => onChanged(UserRole.employee),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _RoleOptionCard(
            label: loc.roleSiteManager,
            icon: Icons.engineering_outlined,
            isSelected: selectedRole == UserRole.siteManager,
            onTap: () => onChanged(UserRole.siteManager),
          ),
        ),
      ],
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFE7193F);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isSelected
                ? activeColor
                : Colors.black.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isSelected ? activeColor : Colors.black54,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
