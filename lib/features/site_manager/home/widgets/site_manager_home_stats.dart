import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/context_extensions.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_dashboard_entity.dart';

class SiteManagerHomeStats extends StatelessWidget {
  const SiteManagerHomeStats({
    super.key,
    required this.stats,
    required this.onTapInspections,
    this.onTapStandingSites,
    this.onTapErection,
    this.onTapDismantling,
  });

  final DashboardStatsEntity stats;
  final VoidCallback onTapInspections;
  final VoidCallback? onTapStandingSites;
  final VoidCallback? onTapErection;
  final VoidCallback? onTapDismantling;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMainStats(context),
        const SizedBox(height: 14),
        _buildSecondaryStats(context),
      ],
    );
  }

  Widget _buildMainStats(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapStandingSites,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF004D26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.standingScaffold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${stats.standingActiveSites}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 33.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.loc.activeSites,
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 17.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTapInspections,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9DC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE53948)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${stats.pendingInspections}',
                      style: TextStyle(
                        color: const Color(0xFFE32638),
                        fontSize: 33.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      context.loc.inspections,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFE32638),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPhaseStatCard(
            context: context,
            title: context.loc.erectionPhase,
            color: const Color(0xFF00A651),
            planned: stats.erection.planned,
            running: stats.erection.running,
            onTap: onTapErection,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPhaseStatCard(
            context: context,
            title: context.loc.dismantlingPhase,
            color: const Color(0xFFFF9800),
            planned: stats.dismantling.planned,
            running: stats.dismantling.running,
            onTap: onTapDismantling,
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseStatCard({
    required BuildContext context,
    required String title,
    required Color color,
    required int planned,
    required int running,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160.h,
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$planned',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF171717),
                  ),
                ),
                Text(
                  '$running',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF171717),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.loc.planned,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF858585),
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    context.loc.running,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: const Color(0xFF858585),
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
