import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../core/enums/backend_enums.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/buttons/buttons.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_project_entity.dart';
import '../../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../../shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';

/// Modal bottom sheet to manually record a new time entry for a project phase.
class SiteManagerAddTimeSheet extends ConsumerStatefulWidget {
  const SiteManagerAddTimeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SiteManagerAddTimeSheet(),
    );
  }

  @override
  ConsumerState<SiteManagerAddTimeSheet> createState() =>
      _SiteManagerAddTimeSheetState();
}

class _SiteManagerAddTimeSheetState
    extends ConsumerState<SiteManagerAddTimeSheet> {
  String? _selectedProjectId;
  String? _selectedPhaseId;
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _breakTime = const TimeOfDay(hour: 0, minute: 45);
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(mobileProjectsProvider);
    final projects = projectsAsync.asData?.value ?? const <MobileProjectEntity>[];

    final seenProjects = <String>{};
    final validProjects = projects
        .where((p) => p.id.isNotEmpty && seenProjects.add(p.id))
        .toList();

    if (_selectedProjectId == null && validProjects.isNotEmpty) {
      _selectedProjectId = validProjects.first.id;
    }

    final selectedProject = validProjects
        .where((p) => p.id == _selectedProjectId)
        .firstOrNull;

    final seenPhases = <String>{};
    final phases = (selectedProject?.phases ?? const <MobileProjectPhaseEntity>[])
        .where((ph) => ph.id.isNotEmpty && seenPhases.add(ph.id))
        .toList();

    if (phases.isNotEmpty &&
        (_selectedPhaseId == null ||
            !phases.any((p) => p.id == _selectedPhaseId))) {
      _selectedPhaseId = phases.first.id;
    } else if (phases.isEmpty) {
      _selectedPhaseId = null;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Center(
                child: Text(
                  context.loc.addTimeEntry,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: 18.h),
              Text(context.loc.project, style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8.h),
              _buildProjectDropdown(validProjects),
              SizedBox(height: 18.h),
              Text(context.loc.activityType, style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8.h),
              _buildPhaseDropdown(phases),
              SizedBox(height: 18.h),
              Text(context.loc.startTime, style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8.h),
              _buildTimeField(
                time: _startTime,
                onSelected: (t) => setState(() => _startTime = t),
              ),
              SizedBox(height: 18.h),
              Text(context.loc.endTime, style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8.h),
              _buildTimeField(
                time: _endTime,
                onSelected: (t) => setState(() => _endTime = t),
              ),
              SizedBox(height: 18.h),
              Text(context.loc.breakTime, style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8.h),
              _buildTimeField(
                time: _breakTime,
                onSelected: (t) => setState(() => _breakTime = t),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTertiary,
                  borderRadius: AppRadii.medium,
                ),
                child: Text(
                  context.loc.workingTimeDeductBreak,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(height: 20.h),
              AppButton(
                text: context.loc.saveEntry,
                isLoading: _isLoading,
                onPressed: (_selectedProjectId == null ||
                        _selectedPhaseId == null ||
                        _isLoading)
                    ? null
                    : () => _saveEntry(phases),
                borderRadius: 8.r,
              ),
              SizedBox(height: 8.h),
              Center(
                child: AppTextButton(
                  text: context.loc.cancel,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectDropdown(List<MobileProjectEntity> validProjects) {
    if (validProjects.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(hintText: context.loc.noProjectsFound),
        child: Text(context.loc.noProjectsFound),
      );
    }
    final effectiveValue = validProjects.any((p) => p.id == _selectedProjectId)
        ? _selectedProjectId
        : validProjects.first.id;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: effectiveValue,
      decoration: InputDecoration(hintText: context.loc.selectProject),
      items: validProjects.map((project) {
        return DropdownMenuItem<String>(
          value: project.id,
          child: Text(
            project.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedProjectId = val;
          _selectedPhaseId = null;
        });
      },
    );
  }

  Widget _buildPhaseDropdown(List<MobileProjectPhaseEntity> phases) {
    if (phases.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(hintText: context.loc.noPhases),
        child: Text(context.loc.noPhases, style: Theme.of(context).textTheme.bodySmall),
      );
    }
    final effectiveValue = phases.any((p) => p.id == _selectedPhaseId)
        ? _selectedPhaseId
        : phases.first.id;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: effectiveValue,
      decoration: InputDecoration(hintText: context.loc.phase),
      items: phases.map((phase) {
        return DropdownMenuItem<String>(
          value: phase.id,
          child: Text(
            phase.type.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedPhaseId = val);
      },
    );
  }

  Widget _buildTimeField({required TimeOfDay time, required ValueChanged<TimeOfDay> onSelected}) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onSelected(picked);
      },
      borderRadius: AppRadii.medium,
      child: InputDecorator(
        decoration: const InputDecoration(suffixIcon: Icon(Icons.access_time_outlined)),
        child: Text(time.format(context)),
      ),
    );
  }

  Future<void> _saveEntry(List<MobileProjectPhaseEntity> phases) async {
    final phase = phases.where((p) => p.id == _selectedPhaseId).firstOrNull;
    if (phase == null) return;

    final now = DateTime.now();
    final startDateTime = DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute);
    var endDateTime = DateTime(now.year, now.month, now.day, _endTime.hour, _endTime.minute);
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }
    final breakMinutes = _breakTime.hour * 60 + _breakTime.minute;

    setState(() => _isLoading = true);
    try {
      final activity = BackendActivityType.fromString(phase.type);
      await ref.read(mobileTimeLogsProvider.notifier).logManualTime(
            phaseId: phase.id,
            activityType: activity,
            startTime: startDateTime,
            endTime: endDateTime,
            breakMinutes: breakMinutes,
          );
      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.showSuccess(context, context.loc.timeEntryAdded);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
