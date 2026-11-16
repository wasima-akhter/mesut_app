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

/// Modal bottom sheet to start a new active timer for a project and its phase.
class SiteManagerStartTimerSheet extends ConsumerStatefulWidget {
  const SiteManagerStartTimerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SiteManagerStartTimerSheet(),
    );
  }

  @override
  ConsumerState<SiteManagerStartTimerSheet> createState() =>
      _SiteManagerStartTimerSheetState();
}

class _SiteManagerStartTimerSheetState
    extends ConsumerState<SiteManagerStartTimerSheet> {
  String? _selectedProjectId;
  String? _selectedPhaseId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(mobileProjectsProvider);
    final projects =
        projectsAsync.asData?.value ?? const <MobileProjectEntity>[];

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
    final phases =
        (selectedProject?.phases ?? const <MobileProjectPhaseEntity>[])
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
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  context.loc.startNewTimer,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: 4.h),
              Center(
                child: Text(
                  context.loc.selectAssignedProject,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                context.loc.assignedProject,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: 8.h),
              _buildProjectDropdown(validProjects),
              SizedBox(height: 18.h),
              Text(
                context.loc.activityType,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: 8.h),
              _buildPhaseDropdown(phases),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTertiary,
                  borderRadius: AppRadii.medium,
                ),
                child: Text(
                  context.loc.timerWillStartFromNow,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(height: 20.h),
              AppButton(
                text: context.loc.startNewTimer,
                isLoading: _isLoading,
                onPressed:
                    (_selectedProjectId == null ||
                        _selectedPhaseId == null ||
                        _isLoading)
                    ? null
                    : () => _handleStartTimer(phases),
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
        child: Text(
          context.loc.noPhases,
          style: Theme.of(context).textTheme.bodySmall,
        ),
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

  Future<void> _handleStartTimer(List<MobileProjectPhaseEntity> phases) async {
    final phase = phases.where((p) => p.id == _selectedPhaseId).firstOrNull;
    if (phase == null) return;

    setState(() => _isLoading = true);
    try {
      final activity = BackendActivityType.fromString(phase.type);
      await ref
          .read(mobileTimeLogsProvider.notifier)
          .startTimer(phaseId: phase.id, activityType: activity);
      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.showSuccess(
          context,
          context.loc.timerStartedFor(phase.type.toUpperCase()),
        );
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
