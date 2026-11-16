import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../domain/entities/project_details_entity.dart';

class ProjectDetailsScaffoldCard extends StatelessWidget {
  final ProjectScaffoldSpec scaffoldSpec;
  final String siteAccessCode;
  final String siteAccessNotes;

  const ProjectDetailsScaffoldCard({
    super.key,
    required this.scaffoldSpec,
    required this.siteAccessCode,
    required this.siteAccessNotes,
  });

  @override
  Widget build(BuildContext context) {
    if (scaffoldSpec.isEmpty &&
        siteAccessCode.isEmpty &&
        siteAccessNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.scaffoldSpecification,
            style: TextStyle(fontSize: 18.5.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (scaffoldSpec.area > 0)
                Expanded(
                  child: _SpecValue(
                    value: '${scaffoldSpec.area.toStringAsFixed(0)} m²',
                    label: context.loc.scaffoldArea,
                  ),
                ),
              if (scaffoldSpec.type.isNotEmpty)
                Expanded(
                  child: _SpecValue(
                    value: scaffoldSpec.type,
                    label: context.loc.scaffoldType,
                  ),
                ),
            ],
          ),
          if (scaffoldSpec.height > 0) ...[
            SizedBox(height: 14.h),
            _SpecValue(
              value: '${scaffoldSpec.height.toStringAsFixed(0)} m',
              label: context.loc.buildingHeight,
            ),
          ],
          if (siteAccessCode.isNotEmpty || siteAccessNotes.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Divider(height: 1, color: const Color(0xFFE9E9E9)),
            SizedBox(height: 10.h),
            Text(
              context.loc.siteAccessAndPhotos,
              style: TextStyle(
                fontSize: 16.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
            ),
            if (siteAccessCode.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Row(
                children: [
                  Text(
                    context.loc.accessCode,
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  Text(
                    siteAccessCode,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ],
            if (siteAccessNotes.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                siteAccessNotes,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF555555),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SpecValue extends StatelessWidget {
  final String value;
  final String label;

  const _SpecValue({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
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
}
