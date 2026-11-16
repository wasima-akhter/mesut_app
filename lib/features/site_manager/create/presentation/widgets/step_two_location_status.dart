import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../providers/create_project_provider.dart';
import 'create_project_form_helpers.dart';
import 'location_map_picker_sheet.dart';
import 'location_map_preview_card.dart';
import 'location_workflow_status_card.dart';

class StepTwoLocationStatus extends ConsumerStatefulWidget {
  const StepTwoLocationStatus({super.key});

  @override
  ConsumerState<StepTwoLocationStatus> createState() =>
      _StepTwoLocationStatusState();
}

class _StepTwoLocationStatusState extends ConsumerState<StepTwoLocationStatus> {
  late final TextEditingController _labelController;
  GoogleMapController? _previewController;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(createProjectProvider);
    _labelController = TextEditingController(text: state.placeLabel);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _handleUseCurrentLocation() async {
    setState(() => _isLocating = true);
    final success = await ref
        .read(createProjectProvider.notifier)
        .useCurrentLocation();
    if (!mounted) return;
    setState(() => _isLocating = false);

    if (success) {
      final s = ref.read(createProjectProvider);
      _labelController.text = s.placeLabel;
      _previewController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(s.lat, s.lng)),
      );
      AppSnackBar.showSuccess(context, context.loc.locationUpdatedFromGps);
    } else {
      AppSnackBar.showError(
        context,
        context.loc.couldNotObtainLocation,
      );
    }
  }

  Future<void> _handleOpenMapPicker() async {
    final state = ref.read(createProjectProvider);
    final result = await LocationMapPickerSheet.show(
      context,
      initialLat: state.lat,
      initialLng: state.lng,
    );

    if (result != null && mounted) {
      ref
          .read(createProjectProvider.notifier)
          .setCoordinates(
            lat: result.lat,
            lng: result.lng,
            placeLabel: result.address,
          );
      _labelController.text = result.address;
      _previewController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(result.lat, result.lng)),
      );
    }
  }

  void _onNext() {
    final state = ref.read(createProjectProvider);
    if (state.lat == 0 && state.lng == 0) {
      AppSnackBar.showError(
        context,
        context.loc.pleaseSelectSiteLocation,
      );
      return;
    }

    ref
        .read(createProjectProvider.notifier)
        .updateStepTwo(
          lat: state.lat,
          lng: state.lng,
          placeLabel: _labelController.text.trim(),
        );

    ref.read(createProjectProvider.notifier).setStep(2);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createProjectProvider);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      children: [
        FormSectionTitle(title: context.loc.siteLocationAndStatus),
        SizedBox(height: 14.h),
        FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormFieldLabel(label: context.loc.siteAddress),
              SizedBox(height: 6.h),
              Text(
                context.loc.selectScaffoldingCoordinates,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildLocationActionButton(
                      icon: Icons.map_outlined,
                      label: context.loc.selectOnMap,
                      color: const Color(0xFFC8102E),
                      bgColor: const Color(0xFFFEF2F2),
                      borderColor: const Color(0xFFFECACA),
                      isLoading: false,
                      onTap: _handleOpenMapPicker,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildLocationActionButton(
                      icon: Icons.my_location,
                      label: context.loc.currentGps,
                      color: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFEFF6FF),
                      borderColor: const Color(0xFFBFDBFE),
                      isLoading: _isLocating,
                      onTap: _isLocating ? null : _handleUseCurrentLocation,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              LocationMapPreviewCard(
                lat: state.lat,
                lng: state.lng,
                onTapChange: _handleOpenMapPicker,
                onMapCreated: (c) => _previewController = c,
              ),
              SizedBox(height: 14.h),
              FormFieldLabelSmall(label: context.loc.placeLabelOptional),
              SizedBox(height: 6.h),
              FormTextField(
                controller: _labelController,
                hint: context.loc.placeLabelHint,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        LocationWorkflowStatusCard(
          phaseType: state.phaseType,
          status: state.status,
          onPhaseChanged: (val) => ref
              .read(createProjectProvider.notifier)
              .updateStepTwo(phaseType: val),
          onStatusChanged: (val) => ref
              .read(createProjectProvider.notifier)
              .updateStepTwo(status: val),
        ),
        SizedBox(height: 22.h),
        StepActionButtons(
          previousText: context.loc.previous,
          nextText: context.loc.next,
          onPrevious: () => ref.read(createProjectProvider.notifier).setStep(0),
          onNext: _onNext,
        ),
      ],
    );
  }

  Widget _buildLocationActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
