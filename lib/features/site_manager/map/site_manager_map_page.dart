import 'package:construction_app/app/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/services/launcher_service.dart';
import '../helper/site_manager_models.dart';
import '../presentation/providers/site_manager_map_provider.dart';

class SiteManagerMapPage extends ConsumerStatefulWidget {
  const SiteManagerMapPage({super.key});

  @override
  ConsumerState<SiteManagerMapPage> createState() => _SiteManagerMapPageState();
}

class _SiteManagerMapPageState extends ConsumerState<SiteManagerMapPage> {
  final TextEditingController _searchController = TextEditingController();

  String get _selectedFilter =>
      ref.watch(siteManagerMapProvider).selectedFilter;

  MapLocation? get _selectedLocation =>
      ref.watch(siteManagerMapProvider).selectedLocation;

  List<MapLocation> get _filteredLocations =>
      ref.watch(siteManagerMapProvider).filteredLocations;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectMarker(MapLocation location) {
    ref.read(siteManagerMapProvider.notifier).selectLocation(location);
  }

  void _selectFilter(String filter) {
    ref.read(siteManagerMapProvider.notifier).setFilter(filter);
    if (_selectedLocation != null &&
        filter != 'All' &&
        _selectedLocation!.type != filter) {
      ref.read(siteManagerMapProvider.notifier).selectLocation(null);
    }
  }

  void _onSearchChanged(String value) {
    ref.read(siteManagerMapProvider.notifier).setSearchQuery(value);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _handleRoute() {
    if (_selectedLocation == null) return;

    _showMessage('Route to ${_selectedLocation!.title} selected');
  }

  void _handleOpen() {
    if (_selectedLocation == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        final location = _selectedLocation!;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8.h),
                Text(
                  location.company,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  location.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // _showMessage('Project opened');
                      context.push(RouteConstants.siteManagerProjectDetail);
                    },
                    child: Text(context.loc.openProject),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCall() async {
    final success = await AppLauncherService.makePhoneCall('+49 221 555 0192');
    if (!success && mounted) {
      _showMessage(context.loc.callingContact);
    }
  }

  void _handleEmail() async {
    final title = _selectedLocation?.title ?? 'Project';
    final success = await AppLauncherService.sendEmail(
      email: 'contact@goldstein-bau.de',
      subject: 'Inquiry: $title',
    );
    if (!success && mounted) {
      _showMessage(context.loc.openingEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ----------------------------------------------------------
            // MAP
            // Replace this Image.asset with GoogleMap later.
            // ----------------------------------------------------------
            Positioned.fill(
              child: Image.network(
                'https://360mediaventures.com/dev/wp-content/uploads/2013/03/map-placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Slight overlay so controls remain readable.
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.white.withValues(alpha: 0.02)),
              ),
            ),

            // ----------------------------------------------------------
            // SEARCH + FILTERS
            // ----------------------------------------------------------
            Positioned(
              top: 14.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _searchField(),
                  SizedBox(height: 8.h),
                  _filterRow(),
                ],
              ),
            ),

            // ----------------------------------------------------------
            // MAP MARKERS
            // ----------------------------------------------------------
            ..._filteredLocations.map(
              (location) => Positioned(
                left: MediaQuery.sizeOf(context).width * location.x,
                top: MediaQuery.sizeOf(context).height * location.y,
                child: _marker(location),
              ),
            ),

            // ----------------------------------------------------------
            // BOTTOM PROJECT CARD
            // ----------------------------------------------------------
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: 16.w,
              right: 16.w,
              bottom: 20.h,
              child: _selectedLocation != null
                  ? _projectCard(_selectedLocation!)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: context.loc.searchCity,
          prefixIcon: Icon(
            Icons.search,
            size: 20.sp,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  icon: Icon(Icons.close, size: 18.sp),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 13.h),
        ),
      ),
    );
  }

  Widget _filterRow() {
    return Wrap(
      runSpacing: 6.w,
      children: [
        _filterChip(
          keyName: 'All',
          label: context.loc.all,
          color: Colors.black,
        ),
        SizedBox(width: 6.w),
        _filterChip(
          keyName: 'Erection',
          label: context.loc.erectionPhase,
          color: Colors.green,
        ),
        SizedBox(width: 6.w),
        _filterChip(
          keyName: 'Dismantling',
          label: context.loc.dismantlingPhase,
          color: Colors.orange,
        ),
        SizedBox(width: 6.w),
        _filterChip(
          keyName: 'Standing',
          label: context.loc.standing,
          color: Colors.lightBlue,
        ),
      ],
    );
  }

  Widget _filterChip({
    required String keyName,
    required String label,
    required Color color,
  }) {
    final selected = _selectedFilter == keyName;

    return GestureDetector(
      onTap: () => _selectFilter(keyName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),

        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected
              ? Colors.black.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),

            SizedBox(width: 4.w),

            Text(
              label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marker(MapLocation location) {
    final selected = _selectedLocation?.id == location.id;

    Color markerColor;

    switch (location.type) {
      case 'Erection':
        markerColor = Colors.green;
        break;
      case 'Dismantling':
        markerColor = Colors.orange;
        break;
      case 'Standing':
        markerColor = Colors.lightBlue;
        break;
      default:
        markerColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => _selectMarker(location),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: selected ? 1.15 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: selected ? 58.w : 30.w,
              height: selected ? 58.w : 30.w,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withValues(alpha: 0.35),
                    blurRadius: selected ? 14 : 8,
                    spreadRadius: selected ? 3 : 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.location_on,
                color: Colors.white,
                size: selected ? 31.sp : 17.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _projectCard(MapLocation location) {
    String typeLabel;
    switch (location.type) {
      case 'Erection':
        typeLabel = context.loc.erectionPhase;
        break;
      case 'Dismantling':
        typeLabel = context.loc.dismantlingPhase;
        break;
      case 'Standing':
        typeLabel = context.loc.standing;
        break;
      default:
        typeLabel = location.type;
    }

    String priorityLabel;
    switch (location.priority.toLowerCase()) {
      case 'high':
        priorityLabel = context.loc.high;
        break;
      case 'medium':
        priorityLabel = context.loc.medium;
        break;
      case 'low':
        priorityLabel = context.loc.low;
        break;
      default:
        priorityLabel = location.priority;
    }

    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(16.r),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: SizedBox(
                    width: 96.w,
                    height: 82.h,
                    child: Image.asset(
                      location.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.grey.shade500,
                            size: 28.sp,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // Project information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              typeLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.green.shade700,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            priorityLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.redAccent,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5.h),

                      Text(
                        location.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        location.company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 17.sp),
                      ),

                      SizedBox(height: 3.h),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15.sp,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              location.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 16.sp),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // Date
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 17.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      location.date,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 16.5.sp),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 7.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _cardButton(
                    icon: Icons.navigation_outlined,
                    text: context.loc.route,
                    filled: true,
                    onTap: _handleRoute,
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  flex: 2,
                  child: _cardButton(
                    icon: Icons.open_in_new,
                    text: context.loc.open,
                    onTap: _handleOpen,
                  ),
                ),
                SizedBox(width: 5.w),
                _iconCardButton(icon: Icons.phone_outlined, onTap: _handleCall),
                SizedBox(width: 5.w),
                _iconCardButton(icon: Icons.mail_outline, onTap: _handleEmail),
                SizedBox(width: 5.w),
                _iconCardButton(
                  icon: Icons.close,
                  onTap: () {
                    ref
                        .read(siteManagerMapProvider.notifier)
                        .selectLocation(null);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return SizedBox(
      height: 34.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14.sp),
        label: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? Colors.black : Colors.white,
          foregroundColor: filled ? Colors.white : AppColors.textPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          side: filled ? BorderSide.none : BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
      ),
    );
  }

  Widget _iconCardButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 34.w,
      height: 34.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
        child: Icon(icon, size: 15.sp, color: AppColors.textPrimary),
      ),
    );
  }
}
