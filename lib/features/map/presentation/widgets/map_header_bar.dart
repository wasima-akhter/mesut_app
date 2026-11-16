import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enum.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/buttons/app_back_button.dart';
import '../../domain/entities/map_request_entity.dart';
import '../providers/map_state.dart';

/// Top bar containing title, back button, search bar, and category filter chips.
class MapHeaderBar extends StatelessWidget {
  final MapState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback? onBack;

  static const List<String> filterCategories = [
    'All',
    'Erection',
    'Dismantling',
    'Standing',
    'Inspection',
  ];

  const MapHeaderBar({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onFilterChanged,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isMulti = state.request.purpose == MapPurpose.multiLocation;
    final isInspecting =
        state.selectedLocation != null || state.activeRoute != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleBar(context),
            if (isMulti && !isInspecting) ...[
              SizedBox(height: 10.h),
              _buildSearchBar(context),
              SizedBox(height: 8.h),
              _buildFilterChips(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    final title = state.selectedLocation != null
        ? state.selectedLocation!.title
        : (state.activeRoute != null
            ? state.activeRoute!.title
            : (state.request.title ??
                (state.request.role == UserRole.siteManager
                    ? context.loc.mapSiteManagerMap
                    : context.loc.mapAssignmentNavigation)));

    return Row(
      children: [
        if (onBack != null) ...[
          AppBackButton(onPressed: onBack!),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_city,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildRoleBadge(context, state.request.role),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: context.loc.mapSearchHint,
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onSearchClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filterCategories.length,
        separatorBuilder: (_, _) => SizedBox(width: 6.w),
        itemBuilder: (context, index) {
          final cat = filterCategories[index];
          final isSelected = state.selectedFilter == cat;

          return GestureDetector(
            onTap: () => onFilterChanged(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                _localizeFilter(context, cat),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context, UserRole role) {
    final isSM = role == UserRole.siteManager;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isSM
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        isSM ? context.loc.mapRoleSiteManager : context.loc.mapRoleEmployee,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: isSM ? AppColors.primary : AppColors.info,
        ),
      ),
    );
  }

  String _localizeFilter(BuildContext context, String cat) {
    switch (cat) {
      case 'All':
        return context.loc.mapFilterAll;
      case 'Erection':
        return context.loc.mapFilterErection;
      case 'Dismantling':
        return context.loc.mapFilterDismantling;
      case 'Standing':
        return context.loc.mapFilterStanding;
      case 'Inspection':
        return context.loc.mapFilterInspection;
      default:
        return cat;
    }
  }
}
