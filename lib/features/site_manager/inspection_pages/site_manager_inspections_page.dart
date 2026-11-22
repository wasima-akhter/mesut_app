import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/localization/pending_refetch_controller.dart';
import '../../../core/widgets/states/app_empty_widget.dart';
import '../../../core/widgets/translation/translation_status_badge.dart';
import '../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import 'domain/entities/mobile_inspection_entity.dart';
import 'presentation/providers/mobile_inspection_provider.dart';

enum InspectionStatus { pending, completed }

class SiteInspectionModel {
  final String projectId;
  final String projectName;
  final String company;
  final String type;
  final String address;
  final String inspector;
  final String appointment;
  final InspectionStatus status;

  const SiteInspectionModel({
    required this.projectId,
    required this.projectName,
    required this.company,
    required this.type,
    required this.address,
    required this.inspector,
    required this.appointment,
    required this.status,
  });
}

class CalendarEventModel {
  final String projectId;
  final String title;
  final String address;
  final String type;
  final String dateRange;
  final String time;
  final String assignee;
  final Color color;

  const CalendarEventModel({
    required this.projectId,
    required this.title,
    required this.address,
    required this.type,
    required this.dateRange,
    required this.time,
    required this.assignee,
    required this.color,
  });
}

class SiteInspectionPage extends ConsumerStatefulWidget {
  const SiteInspectionPage({
    super.key,
    this.initialStatus = InspectionStatus.pending,
  });

  final InspectionStatus initialStatus;

  @override
  ConsumerState<SiteInspectionPage> createState() => _SiteInspectionPageState();
}

class _SiteInspectionPageState extends ConsumerState<SiteInspectionPage> {
  late InspectionStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final inspectionsAsync = ref.watch(mobileInspectionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.loc.siteInspection),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () =>
                context.push(RouteConstants.siteManagerInspectionCalendarPage),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: SegmentedButton<InspectionStatus>(
              segments: [
                ButtonSegment(
                  value: InspectionStatus.pending,
                  label: Text(context.loc.pending),
                ),
                ButtonSegment(
                  value: InspectionStatus.completed,
                  label: Text(context.loc.surveyDone),
                ),
              ],
              selected: {_selectedStatus},
              onSelectionChanged: (s) =>
                  setState(() => _selectedStatus = s.first),
            ),
          ),
          Expanded(
            child: PendingPollEffect(
              hasPending: anyLocalizationPending(
                (inspectionsAsync.asData?.value ?? const [])
                    .map((i) => i.localization),
              ),
              onPoll: () =>
                  ref.read(mobileInspectionsProvider.notifier).refresh(),
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(mobileInspectionsProvider.notifier).refresh(),
                child: inspectionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.loc.somethingWentWrong),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(mobileInspectionsProvider.notifier)
                            .refresh(),
                        child: Text(context.loc.mapRetry),
                      ),
                    ],
                  ),
                ),
                data: (items) {
                  final filtered = items.where((item) {
                    return _selectedStatus == InspectionStatus.pending
                        ? item.isPending
                        : item.isSurveyDone;
                  }).toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: 72.h),
                        AppEmptyWidget(
                          icon: Icons.assignment_outlined,
                          title: context.loc.noInspections,
                          onRetry: () => ref
                              .read(mobileInspectionsProvider.notifier)
                              .refresh(),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _InspectionCard(
                      inspection: filtered[index],
                      onTap: () {
                        ref
                            .read(selectedInspectionIdProvider.notifier)
                            .select(filtered[index].id);
                        context.push(
                          RouteConstants.siteManagerInspectionSurveyPage,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  const _InspectionCard({required this.inspection, required this.onTap});

  final MobileInspectionEntity inspection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badgeColor = inspection.isPending
        ? const Color(0xFFD97706)
        : const Color(0xFF16A34A);

    return RepaintBoundary(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.only(bottom: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              inspection.isPending ? context.loc.pending : context.loc.surveyDone,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: badgeColor),
                            ),
                          ),
                          if (inspection.localization != null)
                            TranslationStatusBadge.fromMeta(inspection.localization),
                        ],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      MobilePhaseLocalizer.formatDateRange(inspection.appointmentDate, null),
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  inspection.siteTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (inspection.customer.name.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    inspection.customer.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                SizedBox(height: 6.h),
                Text(
                  '${inspection.address}, ${inspection.postalCode} ${inspection.city}'
                      .trim(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
