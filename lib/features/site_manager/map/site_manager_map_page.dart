import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../helper/site_manager_models.dart';

class SiteManagerMapPage extends StatefulWidget {
  const SiteManagerMapPage({super.key});

  @override
  State<SiteManagerMapPage> createState() => _SiteManagerMapPageState();
}

class _SiteManagerMapPageState extends State<SiteManagerMapPage> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  MapLocation? _selectedLocation;

  final List<MapLocation> _locations = const [
    MapLocation(
      id: '1',
      type: 'Erection',
      priority: 'High',
      title: 'Prj-0842 . Goisteins.Complex',
      company: 'Hochtief AG • Commercial',
      address: 'Goisteinstraße 12, 50968 Köln',
      date: 'Sept 18 - Sept 20 (2.5 days)',
      image: 'assets/images/project_preview.jpg',
      x: 0.60,
      y: 0.24,
    ),
    MapLocation(
      id: '2',
      type: 'Erection',
      priority: 'Medium',
      title: 'Project Erection Site',
      company: 'Construction Project',
      address: 'Leipzig, Germany',
      date: 'Sept 20 - Sept 22',
      image: 'assets/images/project_preview.jpg',
      x: 0.51,
      y: 0.34,
    ),
    MapLocation(
      id: '3',
      type: 'Dismantling',
      priority: 'High',
      title: 'Dismantling Project',
      company: 'Construction Company',
      address: 'Chemnitz, Germany',
      date: 'Sept 22 - Sept 24',
      image: 'assets/images/project_preview.jpg',
      x: 0.64,
      y: 0.43,
    ),
    MapLocation(
      id: '4',
      type: 'Standing',
      priority: 'Low',
      title: 'Standing Project',
      company: 'Construction Company',
      address: 'Bamberg, Germany',
      date: 'Sept 25 - Sept 28',
      image: 'assets/images/project_preview.jpg',
      x: 0.24,
      y: 0.54,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapLocation> get _filteredLocations {
    return _locations.where((location) {
      final matchesFilter =
          _selectedFilter == 'All' || location.type == _selectedFilter;

      final query = _searchController.text.trim().toLowerCase();

      if (query.isEmpty) {
        return matchesFilter;
      }

      final matchesSearch =
          location.title.toLowerCase().contains(query) ||
          location.company.toLowerCase().contains(query) ||
          location.address.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _selectMarker(MapLocation location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;

      // Clear selected marker if it no longer belongs to filter.
      if (_selectedLocation != null &&
          filter != 'All' &&
          _selectedLocation!.type != filter) {
        _selectedLocation = null;
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {});

    // If the selected location doesn't match search anymore,
    // close its detail card.
    if (_selectedLocation != null) {
      final query = value.trim().toLowerCase();

      if (query.isNotEmpty &&
          !_selectedLocation!.title.toLowerCase().contains(query) &&
          !_selectedLocation!.company.toLowerCase().contains(query) &&
          !_selectedLocation!.address.toLowerCase().contains(query)) {
        setState(() {
          _selectedLocation = null;
        });
      }
    }
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
                      _showMessage('Project opened');
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

  void _handleCall() {
    _showMessage('Calling project contact...');
  }

  void _handleEmail() {
    _showMessage('Opening project email...');
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
        _filterChip(keyName: 'All', label: context.loc.all, color: Colors.black),
        SizedBox(width: 6.w),
        _filterChip(keyName: 'Erection', label: context.loc.erectionPhase, color: Colors.green),
        SizedBox(width: 6.w),
        _filterChip(keyName: 'Dismantling', label: context.loc.dismantlingPhase, color: Colors.orange),
        SizedBox(width: 6.w),
        _filterChip(keyName: 'Standing', label: context.loc.standing, color: Colors.lightBlue),
      ],
    );
  }

  Widget _filterChip({required String keyName, required String label, required Color color}) {
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
                    setState(() {
                      _selectedLocation = null;
                    });
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

  Widget _bottomNavigation() {
    return Container(
      height: 58.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.6)),
      ),
      child: Row(
        children: [
          _navItem(
            icon: Icons.home_outlined,
            label: context.loc.home,
            selected: false,
            onTap: () {
              _showMessage('Home selected');
            },
          ),
          _navItem(
            icon: Icons.folder_outlined,
            label: context.loc.projects,
            selected: false,
            onTap: () {
              _showMessage('Projects selected');
            },
          ),
          _navItem(
            icon: Icons.map_outlined,
            label: context.loc.map,
            selected: true,
            onTap: () {},
          ),
          _navItem(
            icon: Icons.access_time,
            label: context.loc.time,
            selected: false,
            onTap: () {
              _showMessage('Time selected');
            },
          ),
          _navItem(
            icon: Icons.more_horiz,
            label: context.loc.more,
            selected: false,
            onTap: () {
              _showMessage('More selected');
            },
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19.sp,
              color: selected ? AppColors.primary : AppColors.textTertiary,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 15.sp,
                color: selected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
