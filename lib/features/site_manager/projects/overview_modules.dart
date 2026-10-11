import 'package:construction_app/core/widgets/snack/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/services/launcher_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/app_date_time_formatter.dart';

/// =============================================================
/// OVERVIEW
/// =============================================================

Widget buildOverviewTab([BuildContext? context]) {
  return CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 20.h),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
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
                  final success = await AppLauncherService.makePhoneCall('+49 221 555 0192');
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

Future<void> _navigation() async {
  final allowed = await AppPermissions.requestLocation();
  final loc = AppLocalization.current;

  if (!allowed) {
    await showPermissionDialog(
      title: loc.locationPermissionRequired,
      message: loc.locationPermissionMessage,
      context: appNavigatorKey.currentContext!,
    );
    return;
  }
  showMessage(loc.startingNavigation);
}

void showMessage(String message) {
  ScaffoldMessenger.of(appNavigatorKey.currentContext!)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16.sp)),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
