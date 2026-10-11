import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/launcher_service.dart';
import 'site_manager_inspections_page.dart';

class InspectionSurveyPage extends StatefulWidget {
  const InspectionSurveyPage({super.key});

  @override
  State<InspectionSurveyPage> createState() => _InspectionSurveyPageState();
}

class _InspectionSurveyPageState extends State<InspectionSurveyPage> {
  String _scaffoldType = 'Front Scaffold';

  final TextEditingController _areaController = TextEditingController(
    text: '30.00 m',
  );

  final TextEditingController _heightController = TextEditingController(
    text: '30.00 m',
  );

  final TextEditingController _accessController = TextEditingController(
    text: 'Narrow access road. Trucks must unload at south gate.',
  );

  final TextEditingController _requirementsController = TextEditingController(
    text: 'High pedestrian traffic on sidewalk. Heavy safety netting required.',
  );

  @override
  void dispose() {
    _areaController.dispose();
    _heightController.dispose();
    _accessController.dispose();
    _requirementsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // NO BOTTOM NAVIGATION
      body: SafeArea(
        child: Column(
          children: [
            InspectionHeader(title: context.loc.survey),

            SizedBox(height: 10.h),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 20.h),
                children: [
                  _buildEnquiryCard(),

                  SizedBox(height: 10.h),

                  _buildTechnicalSurvey(),

                  SizedBox(height: 10.h),

                  _buildAccessRequirements(),

                  SizedBox(height: 10.h),

                  _buildPhotos(),

                  SizedBox(height: 14.h),

                  AppButton(
                    text: context.loc.completeAndConvertToProject,
                    onPressed: _completeSurvey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // PRE-FILLED FROM ENQUIRY
  // ----------------------------------------------------------

  Widget _buildEnquiryCard() {
    return _SurveySection(
      title: context.loc.prefilledFromEnquiry,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business_outlined,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),

              SizedBox(width: 5.w),

              Text(
                'HochTief AG.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          _contactRow('Andreas Weber', Icons.phone_outlined, context.loc.call),

          Divider(height: 12.h, color: AppColors.border),

          _contactRow(
            'Goldsteinstraße 12, 50968 Köln',
            Icons.navigation_outlined,
            context.loc.route,
          ),

          Divider(height: 12.h, color: AppColors.border),

          Row(
            children: [
              Expanded(
                child: Text(
                  context.loc.smAppointment,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              Text(
                'Today: 10:30 am',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactRow(String text, IconData icon, String action) {
    return InkWell(
      onTap: () {
        if (icon == Icons.phone_outlined) {
          AppLauncherService.makePhoneCall('+49 221 555 0192');
        }
      },
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodySmall),
            ),

            Icon(icon, size: 16.sp, color: AppColors.textPrimary),

            SizedBox(width: 5.w),

            Text(
              action,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TECHNICAL FIELD SURVEY
  // ----------------------------------------------------------

  Widget _buildTechnicalSurvey() {
    return _SurveySection(
      title: context.loc.technicalFieldSurvey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(context.loc.scaffoldType),

          SizedBox(height: 5.h),

          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: DropdownButton<String>(
              value: _scaffoldType,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp),
              style: Theme.of(context).textTheme.bodyMedium,
              items: [
                DropdownMenuItem(
                  value: 'Front Scaffold',
                  child: Text(context.loc.frontScaffold),
                ),
                DropdownMenuItem(
                  value: 'Side Scaffold',
                  child: Text(context.loc.sideScaffold),
                ),
                DropdownMenuItem(
                  value: 'Full Scaffold',
                  child: Text(context.loc.fullScaffold),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _scaffoldType = value;
                });
              },
            ),
          ),

          SizedBox(height: 10.h),

          Row(
            children: [
              Expanded(
                child: _measurementField(
                  label: context.loc.estAreaM2,
                  controller: _areaController,
                  icon: Icons.straighten_outlined,
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: _measurementField(
                  label: context.loc.heightM,
                  controller: _heightController,
                  icon: Icons.height_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _measurementField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),

        SizedBox(height: 6.h),

        SizedBox(
          height: 42.h,

          child: TextField(
            controller: controller,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 10.h,
              ),
              suffixIcon: Icon(
                icon,
                size: 17.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
  // ----------------------------------------------------------
  // ACCESS & REQUIREMENTS
  // ----------------------------------------------------------

  Widget _buildAccessRequirements() {
    return _SurveySection(
      title: context.loc.accessAndRequirements,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(context.loc.siteAccessInstruction),

          SizedBox(height: 5.h),

          _multiLineField(
            controller: _accessController,
            minLines: 2,
            maxLines: 3,
          ),

          SizedBox(height: 10.h),

          _fieldLabel(context.loc.specialRequirementsNotes),

          SizedBox(height: 5.h),

          _multiLineField(
            controller: _requirementsController,
            minLines: 2,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _multiLineField({
    required TextEditingController controller,
    required int minLines,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(10.w),
      ),
    );
  }
  // ----------------------------------------------------------
  // PHOTOS
  // ----------------------------------------------------------

  Widget _buildPhotos() {
    return _SurveySection(
      title: context.loc.sitePhoto,
      trailing: SmallRedButton(text: context.loc.viewAll, onTap: _viewAllPhotos),
      child: Row(
        children: [
          Expanded(
            child: _photoPlaceholder(
              'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=300',
            ),
          ),

          SizedBox(width: 7.w),

          Expanded(
            child: _photoPlaceholder(
              'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=300',
            ),
          ),

          SizedBox(width: 7.w),

          Expanded(
            child: _photoPlaceholder(
              'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=300',
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder(String url) {
    return GestureDetector(
      onTap: _viewAllPhotos,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.r),
        child: AspectRatio(
          aspectRatio: 1.05,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return Container(
                color: AppColors.background,
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.textSecondary,
                  size: 24.sp,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // SECTION
  // ----------------------------------------------------------

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  void _viewAllPhotos() {
    context.push(RouteConstants.siteManagerInspectionPhotos);
  }

  void _completeSurvey() {
    // Save survey data here.

    context.pop();
  }
}

// ============================================================
// SURVEY SECTION CONTAINER
// ============================================================

class _SurveySection extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SurveySection({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),

              ?trailing,
            ],
          ),

          SizedBox(height: 9.h),

          child,
        ],
      ),
    );
  }
}
