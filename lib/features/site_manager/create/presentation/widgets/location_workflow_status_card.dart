import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import 'create_project_form_helpers.dart';

class LocationWorkflowStatusCard extends StatelessWidget {
  final String phaseType;
  final String status;
  final ValueChanged<String> onPhaseChanged;
  final ValueChanged<String> onStatusChanged;

  const LocationWorkflowStatusCard({
    super.key,
    required this.phaseType,
    required this.status,
    required this.onPhaseChanged,
    required this.onStatusChanged,
  });

  static const List<String> availablePhases = [
    'ERECTION',
    'DISMANTLING',
    'STANDING',
    'MAINTENANCE',
  ];

  static const List<String> availableStatuses = [
    'ENQUIRY',
    'QUOTATION',
    'ORDER_CONFIRMED',
    'IN_PROGRESS',
    'COMPLETED',
    'POSTPONED',
  ];

  @override
  Widget build(BuildContext context) {
    final safePhase =
        availablePhases.contains(phaseType) ? phaseType : availablePhases.first;
    final safeStatus =
        availableStatuses.contains(status) ? status : availableStatuses.first;

    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormFieldLabel(label: context.loc.workflowStatus),
          SizedBox(height: 10.h),
          FormFieldLabelSmall(label: context.loc.projectPhase),
          SizedBox(height: 6.h),
          _buildDropdown(
            value: safePhase,
            items: availablePhases,
            labelBuilder: (type) =>
                MobilePhaseLocalizer.phaseType(context, type),
            onChanged: (val) {
              if (val != null) onPhaseChanged(val);
            },
          ),
          SizedBox(height: 12.h),
          FormFieldLabelSmall(label: context.loc.operationalStatus),
          SizedBox(height: 6.h),
          _buildDropdown(
            value: safeStatus,
            items: availableStatuses,
            labelBuilder: (s) => MobilePhaseLocalizer.status(context, s),
            onChanged: (val) {
              if (val != null) onStatusChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String Function(String) labelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFDCDCDC)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(labelBuilder(item), style: TextStyle(fontSize: 16.sp)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
