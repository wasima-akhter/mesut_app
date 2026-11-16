import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../../core/widgets/states/app_empty_widget.dart';
import '../../../mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../../mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../providers/mobile_time_tracking_provider.dart';
import 'mobile_time_log_card.dart';

class MobileCrewTimePanel extends ConsumerStatefulWidget {
  const MobileCrewTimePanel({super.key});

  @override
  ConsumerState<MobileCrewTimePanel> createState() =>
      _MobileCrewTimePanelState();
}

class _MobileCrewTimePanelState extends ConsumerState<MobileCrewTimePanel> {
  String? _selectedProjectId;
  DateTime? _selectedDate;

  void _load() {
    final pid = _selectedProjectId;
    if (pid == null || pid.isEmpty) return;
    ref
        .read(mobileCrewTimeProvider.notifier)
        .load(projectId: pid, date: _selectedDate);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final projects = ref.watch(mobileProjectsProvider).asData?.value ?? const [];
    final crewAsync = ref.watch(mobileCrewTimeProvider);

    if (_selectedProjectId == null && projects.isNotEmpty) {
      _selectedProjectId = projects.first.id;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: projects.any((p) => p.id == _selectedProjectId)
                    ? _selectedProjectId
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                hint: Text(context.loc.selectAssignedProject),
                items: projects
                    .map(
                      (p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedProjectId = val);
                  _load();
                },
              ),
            ),
            SizedBox(width: 8.w),
            IconButton.outlined(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        crewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Column(
              children: [
                Text(context.loc.somethingWentWrong),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: _load,
                  child: Text(context.loc.mapRetry),
                ),
              ],
            ),
          ),
          data: (crew) {
            if (crew == null) {
              return AppEmptyWidget(
                icon: Icons.groups_outlined,
                title: context.loc.noCrewLogs,
                onRetry: _load,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RepaintBoundary(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.totalProjectHours,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${crew.totalProjectHours.toStringAsFixed(1)} h',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (crew.hoursByActivity.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    context.loc.hoursByActivity,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: crew.hoursByActivity.map((item) {
                      return Chip(
                        label: Text(
                          '${MobilePhaseLocalizer.phaseType(context, item.activityType.serializedName)}: ${item.hours.toStringAsFixed(1)}h',
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (crew.crewBreakdown.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Text(
                    context.loc.crewBreakdown,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: crew.crewBreakdown.length,
                    itemBuilder: (_, index) {
                      final member = crew.crewBreakdown[index];
                      return RepaintBoundary(
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: ListTile(
                            title: Text(member.user.fullName),
                            subtitle: Text(
                              member.synced
                                  ? context.loc.syncedLabel
                                  : context.loc.pendingSyncLabel,
                            ),
                            trailing: Text(
                              '${member.totalHours.toStringAsFixed(1)} h',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                if (crew.logs.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: crew.logs.length,
                    itemBuilder: (_, index) =>
                        MobileTimeLogCard(log: crew.logs[index]),
                  ),
                ] else if (crew.crewBreakdown.isEmpty) ...[
                  SizedBox(height: 16.h),
                  AppEmptyWidget(
                    icon: Icons.groups_outlined,
                    title: context.loc.noCrewLogs,
                    onRetry: _load,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
