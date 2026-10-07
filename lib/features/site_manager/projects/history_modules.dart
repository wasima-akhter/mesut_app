import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/app_localization.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<_HistoryItem> get _history {
    final loc = AppLocalization.current;
    return [
      _HistoryItem(
        icon: Icons.refresh_rounded,
        color: const Color(0xFF12B76A),
        title: loc.durationUpdated('2.0 days', '2.5 days'),
        user: 'Mesut Yilmaz (${loc.siteManagerRole})',
        date: 'Sep 18, 2026 at 06:30 AM',
      ),
      _HistoryItem(
        icon: Icons.edit_outlined,
        color: const Color(0xFF4F7CFF),
        title: loc.phaseChanged(loc.orderConfirmed, loc.erectionPhase),
        user: 'Mesut Yilmaz (${loc.siteManagerRole})',
        date: 'Sep 18, 2026 at 07:30 AM',
      ),
      _HistoryItem(
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFFF79009),
        title: loc.phaseChanged(loc.orderConfirmed, loc.erectionPhase),
        user: 'Mesut Yilmaz (${loc.siteManagerRole})',
        date: 'Sep 18, 2026 at 07:30 AM',
      ),
      _HistoryItem(
        icon: Icons.folder_outlined,
        color: const Color(0xFF7B61FF),
        title: loc.phaseChanged(loc.orderConfirmed, loc.erectionPhase),
        user: 'Mesut Yilmaz (${loc.siteManagerRole})',
        date: 'Sep 18, 2026 at 07:30 AM',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                ..._history.asMap().entries.map((entry) {
                  return _buildHistoryItem(entry.value, entry.key);
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(_HistoryItem item, int index) {
    final isLast = index == _history.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38.w,
            child: Column(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, size: 16.sp, color: item.color),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(width: 1, color: const Color(0xFFE3E3E3)),
                  ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h, top: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF333333),
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    item.user,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF777777),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    item.date,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.user,
    required this.date,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String user;
  final String date;
}
