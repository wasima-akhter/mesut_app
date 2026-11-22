import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/pending_refetch_controller.dart';
import '../../domain/entities/project_details_entity.dart';
import 'project_details_crew_card.dart';
import 'project_details_customer_card.dart';
import 'project_details_hours_card.dart';
import 'project_details_inspection_card.dart';
import 'project_details_map_card.dart';
import 'project_details_scaffold_card.dart';
import 'project_details_schedule_card.dart';

class ProjectDetailsOverviewTab extends StatelessWidget {
  final ProjectDetailsEntity details;
  final Future<void> Function() onRefresh;

  const ProjectDetailsOverviewTab({
    super.key,
    required this.details,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return PendingPollEffect(
      hasPending: details.localization?.isPending == true,
      onPoll: () => onRefresh(),
      child: RefreshIndicator(
        color: const Color(0xFFC8102E),
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 32.h),
          children: [
            RepaintBoundary(child: ProjectDetailsHoursCard(details: details)),
            SizedBox(height: 10.h),
            RepaintBoundary(
              child: ProjectDetailsCustomerCard(customer: details.customer),
            ),
            SizedBox(height: 10.h),
            RepaintBoundary(
              child: ProjectDetailsMapCard(
                projectId: details.id,
                coordinates: details.coordinates,
                title: details.name,
              ),
            ),
            SizedBox(height: 10.h),
            RepaintBoundary(
              child: ProjectDetailsScaffoldCard(
                scaffoldSpec: details.scaffoldSpecification,
                siteAccessCode: details.siteAccessCode,
                siteAccessNotes: details.siteAccessNotes,
              ),
            ),
            SizedBox(height: 10.h),
            RepaintBoundary(
              child: ProjectDetailsScheduleCard(
                scheduleData: details.scheduleData,
                phases: details.phases,
              ),
            ),
            SizedBox(height: 10.h),
            RepaintBoundary(
              child: ProjectDetailsInspectionCard(
                inspection: details.nextSafetyInspection,
              ),
            ),
            SizedBox(height: 10.h),
            RepaintBoundary(
              child: ProjectDetailsCrewCard(crew: details.crewBreakdown),
            ),
          ],
        ),
      ),
    );
  }
}
