import 'package:construction_app/core/widgets/snack/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/services/launcher_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/app_date_time_formatter.dart';
import '../../../core/widgets/buttons/buttons.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/route_constants.dart';
import '../../../core/enums/app_enum.dart';
import '../../map/domain/entities/map_location_entity.dart';
import '../../map/domain/entities/map_request_entity.dart';
import '../../map/utils/map_coordinate_resolver.dart';
import '../presentation/providers/site_manager_project_details_provider.dart';

/// =============================================================
/// OVERVIEW
/// =============================================================

Widget buildOverviewTab([BuildContext? context, ProjectDetailsState? state]) {
  return CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 20.h),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            buildProjectHoursCard(context, state),
            SizedBox(height: 10.h),
            buildCustomerCard(context),
            SizedBox(height: 10.h),
            buildMapCard(context),
            SizedBox(height: 10.h),
            buildScaffoldSpecificationCard(context),
            SizedBox(height: 10.h),
            buildScheduleCard(context),
          ]),
        ),
      ),
    ],
  );
}

Widget buildCustomerCard([BuildContext? context]) {
  final loc = AppLocalization.current;
  return card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.customer,
          style: TextStyle(
            fontSize: 17.sp,
            color: const Color(0xFF777777),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(
              Icons.business_outlined,
              size: 18.sp,
              color: const Color(0xFF555555),
            ),
            SizedBox(width: 7.w),
            Text(
              'Hochief AG',
              style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 5.w),
            Text(
              '• ${loc.commercial}',
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF777777)),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Column(
            children: [
              _contactRow(
                icon: Icons.person_outline,
                text: loc.contactLabel('Andreas Weber (${loc.projectLead})'),
              ),
              SizedBox(height: 8.h),
              _contactRow(icon: Icons.phone_outlined, text: '+49 221 555 0192'),
              SizedBox(height: 8.h),
              _contactRow(icon: Icons.mail_outline, text: 'you@gmail.com'),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _outlineButton(
                icon: Icons.phone_outlined,
                label: loc.callClient,
                onTap: () async {
                  final success = await AppLauncherService.makePhoneCall(
                    '+49 221 555 0192',
                  );
                  if (!success) {
                    showMessage(loc.callingClient);
                  }
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _outlineButton(
                icon: Icons.mail_outline,
                label: loc.mailClient,
                onTap: () async {
                  final success = await AppLauncherService.sendEmail(
                    email: 'you@gmail.com',
                    subject: 'Project Inquiry: Andreas Weber',
                  );
                  if (!success) {
                    showMessage(loc.openingEmail);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildMapCard([BuildContext? context]) {
  return card(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        Container(
          height: 145.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EBE6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(9.r)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _MapPlaceholderPainter()),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: const Color(0xFFC8102E),
                    size: 28.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 17.sp,
                    color: const Color(0xFF777777),
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      'Goltsteinstraße 12, 50968 Köln',
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              AppButton.dark(
                text: AppLocalization.current.navigation,
                leadingIcon: Icons.navigation_outlined,
                onPressed: _navigation,
                borderRadius: 7.r,
                verticalPadding: 10.h,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFD1D8D0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final greenPaint = Paint()
      ..color = const Color(0xFFD8E5D4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .03,
        size.height * .08,
        size.width * .25,
        size.height * .25,
      ),
      greenPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .70,
        size.height * .55,
        size.width * .25,
        size.height * .35,
      ),
      greenPaint,
    );

    final road1 = Path()
      ..moveTo(0, size.height * .70)
      ..quadraticBezierTo(
        size.width * .40,
        size.height * .20,
        size.width,
        size.height * .40,
      );

    final road2 = Path()
      ..moveTo(size.width * .55, 0)
      ..quadraticBezierTo(
        size.width * .35,
        size.height * .45,
        size.width * .20,
        size.height,
      );

    canvas.drawPath(road1, roadPaint);
    canvas.drawPath(road2, roadPaint);

    canvas.drawPath(road1, thinRoadPaint);
    canvas.drawPath(road2, thinRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

Future<void> _navigation([String? address, String? title]) async {
  final ctx = appNavigatorKey.currentContext;
  if (ctx != null) {
    final addr = address ?? 'Goltsteinstraße 12, 50968 Köln';
    final destination = MapLocationEntity(
      id: 'proj_${addr.hashCode}',
      title: title ?? 'Goltsteins.Complex',
      address: addr,
      coordinate: MapCoordinateResolver.resolve(addr),
      type: 'Erection',
    );

    ctx.push(
      RouteConstants.map,
      extra: MapRequestEntity.routeNavigation(
        role: UserRole.siteManager,
        destination: destination,
      ),
    );
  }
}

void showMessage(String message) {
  AppSnackBar.showInfo(null, message, icon: Icons.navigation_outlined);
}

Future<void> showPermissionDialog({
  required String title,
  required String message,
  required BuildContext context,
}) async {
  final loc = AppLocalization.current;
  final shouldOpenSettings = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(message, style: TextStyle(fontSize: 17.sp)),
        actions: [
          AppTextButton(
            text: loc.cancel,
            onPressed: () => Navigator.pop(context, false),
            textStyle: TextStyle(fontSize: 17.sp),
          ),
          AppTextButton(
            text: loc.settings,
            onPressed: () => Navigator.pop(context, true),
            foregroundColor: const Color(0xFFC8102E),
            textStyle: TextStyle(
              fontSize: 17.sp,
              color: const Color(0xFFC8102E),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    },
  );

  if (shouldOpenSettings == true) {
    await AppPermissions.openSettings();
  }
}

Widget buildScaffoldSpecificationCard([BuildContext? context]) {
  final loc = AppLocalization.current;
  return card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTitle(text: loc.scaffoldSpecification),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _specValue(value: '450 m²', label: loc.scaffoldArea),
            ),
            Expanded(
              child: _specValue(
                value: loc.frontScaffold,
                label: loc.scaffoldType,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        _specValue(value: '24 m', label: loc.buildingHeight),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5DD),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Text(
            loc.nextSafetyInspection(
              '${AppDateTimeFormatter.formatDateRange(DateTime.utc(2026, 9, 18), DateTime.utc(2026, 9, 20))} (${AppDateTimeFormatter.formatShortUnit(2.5, 'days')})',
            ),
            style: TextStyle(
              fontSize: 15.5.sp,
              color: const Color(0xFFF79009),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildScheduleCard([BuildContext? context]) {
  final loc = AppLocalization.current;
  final scheduleDateRange = AppDateTimeFormatter.formatDateRange(
    DateTime.utc(2026, 9, 18),
    DateTime.utc(2026, 9, 20),
  );

  return card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTitle(text: loc.scheduleAndDuration),

        SizedBox(height: 12.h),
        _scheduleRow(
          color: const Color(0xFF12B76A),
          title: loc.erectionPhase,
          date: scheduleDateRange,
          duration: loc.durationDays('2.5'),
        ),
        SizedBox(height: 12.h),
        _scheduleRow(
          color: const Color(0xFFF79009),
          title: loc.dismantlingPhase,
          date: scheduleDateRange,
          duration: loc.durationDays('2.5'),
        ),
      ],
    ),
  );
}

Widget card({required Widget child, EdgeInsets? padding}) {
  return Container(
    width: double.infinity,
    padding: padding ?? EdgeInsets.all(10.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9.r),
      border: Border.all(color: const Color(0xFFE9E9E9)),
    ),
    child: child,
  );
}

Widget _contactRow({required IconData icon, required String text}) {
  return Row(
    children: [
      Icon(icon, size: 16.sp, color: const Color(0xFF777777)),
      SizedBox(width: 7.w),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 16.5.sp, color: const Color(0xFF555555)),
        ),
      ),
    ],
  );
}

Widget _outlineButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return AppOutlinedButton(
    text: label,
    leadingIcon: icon,
    onPressed: onTap,
    foregroundColor: const Color(0xFF333333),
    borderColor: const Color(0xFFD8D8D8),
    borderRadius: 6.r,
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 7.h),
    size: AppButtonSize.small,
  );
}

Widget _specValue({required String value, required String label}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 21.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF111111),
        ),
      ),
      SizedBox(height: 2.h),
      Text(
        label,
        style: TextStyle(fontSize: 15.5.sp, color: const Color(0xFF888888)),
      ),
    ],
  );
}

Widget _scheduleRow({
  required Color color,
  required String title,
  required String date,
  required String duration,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 8.w,
        height: 8.w,
        margin: EdgeInsets.only(top: 4.h),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.5.sp,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              '$date • $duration',
              style: TextStyle(fontSize: 15.sp, color: const Color(0xFF777777)),
            ),
          ],
        ),
      ),
    ],
  );
}

Text _cardTitle({required String text}) {
  return Text(
    text,
    style: TextStyle(fontSize: 18.5.sp, fontWeight: FontWeight.w700),
  );
}

/// =============================================================
/// PROJECT HOURS & LABOR SUMMARY CARD
/// =============================================================

Widget buildProjectHoursCard([
  BuildContext? context,
  ProjectDetailsState? state,
]) {
  final loc = context != null ? context.loc : AppLocalization.current;
  final detailsState = state ?? const ProjectDetailsState();
  final isProfitable = detailsState.isProfitable;
  final totalHours = detailsState.totalLoggedHours;
  final remaining = detailsState.remainingHours;
  final progress = detailsState.budgetProgress;

  return card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -----------------------------------------------------
        // CARD HEADER: TITLE + PROFITABILITY / BUDGET STATUS
        // -----------------------------------------------------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: isProfitable
                    ? const Color(0xFFE9F8EF)
                    : const Color(0xFFFEE4E2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.access_time_filled_rounded,
                size: 20.sp,
                color: isProfitable
                    ? const Color(0xFF027A48)
                    : const Color(0xFFD92D20),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.projectHoursLabor,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    loc.hoursLoggedByCrew,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),

              decoration: BoxDecoration(
                color: isProfitable
                    ? const Color(0xFFECFDF3)
                    : const Color(0xFFFEF3F2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isProfitable
                      ? const Color(0xFFA6F4C5)
                      : const Color(0xFFFECDCA),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isProfitable
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    size: 15.sp,
                    color: isProfitable
                        ? const Color(0xFF027A48)
                        : const Color(0xFFD92D20),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    isProfitable ? loc.profitable : loc.lossRisk,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isProfitable
                          ? const Color(0xFF027A48)
                          : const Color(0xFFD92D20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 14.h),

        // -----------------------------------------------------
        // KEY METRICS BOX: Logged Hours vs Target Budget vs Variance
        // -----------------------------------------------------
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detailsState.formattedTotalHours,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      loc.consumedHours,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: const Color(0xFF667085),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 38.h, color: const Color(0xFFE4E7EC)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 8.w),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        detailsState.formattedBudgetHours,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF344054),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        loc.targetBudget,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF667085),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 38.h, color: const Color(0xFFE4E7EC)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${isProfitable ? '+' : '-'}${remaining.abs().toStringAsFixed(1)}h',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: isProfitable
                              ? const Color(0xFF027A48)
                              : const Color(0xFFD92D20),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isProfitable ? loc.underBudget : loc.overBudget,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: isProfitable
                              ? const Color(0xFF027A48)
                              : const Color(0xFFD92D20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // -----------------------------------------------------
        // BUDGET CONSUMPTION PROGRESS BAR
        // -----------------------------------------------------
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.budgetConsumedPercent((progress * 100).toInt().toString()),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF344054),
              ),
            ),
            Text(
              '${detailsState.formattedTotalHours} / ${detailsState.formattedBudgetHours}',
              style: TextStyle(
                fontSize: 15.5.sp,
                color: const Color(0xFF667085),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 7.h,
            backgroundColor: const Color(0xFFEAECF0),
            valueColor: AlwaysStoppedAnimation(
              isProfitable
                  ? (progress > 0.85
                        ? const Color(0xFFF79009)
                        : const Color(0xFF12B76A))
                  : const Color(0xFFD92D20),
            ),
          ),
        ),

        SizedBox(height: 14.h),

        // -----------------------------------------------------
        // BREAKDOWN: HOURS LOGGED BY ASSIGNED CREW
        // -----------------------------------------------------
        Text(
          loc.loggedByAssignedCrew,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D2939),
          ),
        ),
        SizedBox(height: 8.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            children: detailsState.crewHours.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              final percent = totalHours > 0
                  ? ((member.loggedHours / totalHours) * 100).toInt()
                  : 0;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17.r,
                          backgroundColor: const Color(0xFFFEE4E2),
                          child: Text(
                            member.employeeName.isNotEmpty
                                ? member.employeeName
                                      .split(' ')
                                      .map((e) => e.isNotEmpty ? e[0] : '')
                                      .take(2)
                                      .join()
                                : 'E',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFB42318),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.employeeName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF101828),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${_localizeCrewRole(loc, member.role)} • ${_localizeCrewActivity(loc, member.recentActivity)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF667085),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              member.formattedHours,
                              style: TextStyle(
                                fontSize: 15.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF101828),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '$percent%',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: const Color(0xFF98A2B3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (index < detailsState.crewHours.length - 1)
                    const Divider(height: 1, color: Color(0xFFEAECF0)),
                ],
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 12.h),

        // -----------------------------------------------------
        // BREAKDOWN: HOURS BY ACTIVITY
        // -----------------------------------------------------
        Text(
          loc.hoursByActivity,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D2939),
          ),
        ),
        SizedBox(height: 8.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,

          children: detailsState.activityHours.entries.map((entry) {
            final act = entry.key;
            final hrs = entry.value;
            final pct = totalHours > 0 ? ((hrs / totalHours) * 100).toInt() : 0;
            Color dotColor;
            if (act.toLowerCase().contains('erect')) {
              dotColor = const Color(0xFF12B76A);
            } else if (act.toLowerCase().contains('dismantl')) {
              dotColor = const Color(0xFFF79009);
            } else {
              dotColor = const Color(0xFF2E90FA);
            }

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      '${_localizeCrewActivity(loc, act)}: ',
                      style: TextStyle(
                        fontSize: 16.5.sp,
                        color: const Color(0xFF475467),
                      ),
                    ),
                  ),
                  Text(
                    '${hrs.toStringAsFixed(1)}h ($pct%)',
                    style: TextStyle(
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 12.h),

        // -----------------------------------------------------
        // ACTION BUTTON: View Detailed Time Logs
        // -----------------------------------------------------
        SizedBox(
          width: double.infinity,
          child: _outlineButton(
            icon: Icons.list_alt_rounded,
            label: loc.viewTimeLogs,
            onTap: () {
              if (context != null) {
                _showProjectTimeLogsSheet(context, detailsState);
              }
            },
          ),
        ),
      ],
    ),
  );
}

String _localizeCrewRole(AppStrings loc, String role) {
  switch (role.toLowerCase()) {
    case 'site manager':
      return loc.siteManager;
    case 'lead scaffolder':
      return loc.leadScaffolder;
    case 'scaffolder':
      return loc.scaffolder;
    default:
      return role;
  }
}

String _localizeCrewActivity(AppStrings loc, String activity) {
  switch (activity.toLowerCase()) {
    case 'erection phase':
    case 'erection':
      return loc.erectionPhase;
    case 'dismantling phase':
    case 'dismantling':
      return loc.dismantlingPhase;
    case 'standing':
    case 'standing scaffold':
      return loc.smStandingScaffold;
    case 'standing & inspection':
      return '${loc.smStandingScaffold} & ${loc.safetyInspection}';
    case 'erection & anchoring':
      return loc.erectionAndAnchoring;
    case 'material handling':
      return loc.materialHandling;
    case 'safety inspection':
      return loc.safetyInspection;
    default:
      return activity;
  }
}

void _showProjectTimeLogsSheet(
  BuildContext context,
  ProjectDetailsState state,
) {
  final loc = context.loc;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        height: 0.85.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D5DD),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.totalProjectHours,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF101828),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          loc.loggedAcrossEmployees(
                            state.formattedTotalHours,
                            state.crewHours.length,
                          ),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEAECF0)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                children: [
                  // Breakdown card in sheet
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: state.isProfitable
                          ? const Color(0xFFECFDF3)
                          : const Color(0xFFFEF3F2),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: state.isProfitable
                            ? const Color(0xFFA6F4C5)
                            : const Color(0xFFFECDCA),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.isProfitable
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: state.isProfitable
                              ? const Color(0xFF027A48)
                              : const Color(0xFFB42318),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.isProfitable
                                    ? loc.profitabilityHealthy
                                    : loc.profitabilityAtRisk,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: state.isProfitable
                                      ? const Color(0xFF027A48)
                                      : const Color(0xFFB42318),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                state.isProfitable
                                    ? loc.remainingUnderLaborBudget(
                                        state.remainingHours.toStringAsFixed(1),
                                        state.formattedBudgetHours,
                                      )
                                    : loc.exceedingBudgetLimit(
                                        state.remainingHours
                                            .abs()
                                            .toStringAsFixed(1),
                                        state.formattedBudgetHours,
                                      ),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: state.isProfitable
                                      ? const Color(0xFF027A48)
                                      : const Color(0xFFB42318),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    loc.itemizedTimeLogsByCrew,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...state.crewHours.map((member) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFE4E7EC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18.r,
                                backgroundColor: const Color(0xFFFDE8EB),
                                child: Text(
                                  member.employeeName.isNotEmpty
                                      ? member.employeeName
                                            .split(' ')
                                            .map(
                                              (e) => e.isNotEmpty ? e[0] : '',
                                            )
                                            .take(2)
                                            .join()
                                      : 'E',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFBA162C),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.employeeName,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF101828),
                                      ),
                                    ),
                                    Text(
                                      _localizeCrewRole(loc, member.role),
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: const Color(0xFF667085),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F7),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  member.formattedHours,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF101828),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 18.sp,
                                  color: const Color(0xFF12B76A),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  loc.primaryTask(
                                    _localizeCrewActivity(
                                      loc,
                                      member.recentActivity,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 15.5.sp,
                                    color: const Color(0xFF475467),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
