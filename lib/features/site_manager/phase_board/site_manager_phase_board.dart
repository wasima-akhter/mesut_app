import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/app_error_resolver.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../../../core/widgets/states/app_empty_widget.dart';
import '../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../domain/entities/mobile_phase_entity.dart';
import '../presentation/providers/mobile_phase_provider.dart';

enum ProjectPhase { enquiry, erection, dismantling, standing }

class SiteManagerPhaseBoardPage extends ConsumerStatefulWidget {
  const SiteManagerPhaseBoardPage({super.key});

  @override
  ConsumerState<SiteManagerPhaseBoardPage> createState() =>
      _SiteManagerPhaseBoardPageState();
}

class _SiteManagerPhaseBoardPageState
    extends ConsumerState<SiteManagerPhaseBoardPage> {
  String _selectedType = 'ALL';

  Future<void> _pickAndUpdateStatus(MobilePhaseEntity phase) async {
    const statuses = ['ENQUIRY', 'PLANNED', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED'];
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Text(
                context.loc.updateStatus,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
            for (final status in statuses)
              ListTile(
                title: Text(status),
                trailing: phase.status == status
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(ctx).pop(status),
              ),
          ],
        ),
      ),
    );

    if (chosen == null || chosen == phase.status) return;
    try {
      await ref
          .read(mobilePhasesProvider.notifier)
          .updateStatus(phase.id, chosen);
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        context.loc.phaseChanged(phase.status, chosen),
      );
    } catch (e) {
      if (!mounted) return;
      final lang = ref.read(appLanguageProvider).code;
      final resolved = AppErrorResolver.resolve(e, languageCode: lang);
      AppSnackBar.showError(context, resolved.displayMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final phasesAsync = ref.watch(mobilePhasesProvider);

    final filters = <(String, String)>[
      ('ALL', context.loc.mapFilterAll),
      ('ERECTION', context.loc.erectionPhase),
      ('DISMANTLING', context.loc.dismantlingPhase),
      ('STANDING', context.loc.standing),
      ('MAINTENANCE', context.loc.maintenancePhase),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.loc.phaseBoard)),
      body: Column(
        children: [
          SizedBox(
            height: 50.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              itemCount: filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, index) {
                final (code, label) = filters[index];
                return ChoiceChip(
                  label: Text(label),
                  selected: _selectedType == code,
                  onSelected: (_) => setState(() => _selectedType = code),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(mobilePhasesProvider.notifier).refresh(),
              child: phasesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.loc.somethingWentWrong),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(mobilePhasesProvider.notifier).refresh(),
                        child: Text(context.loc.mapRetry),
                      ),
                    ],
                  ),
                ),
                data: (phases) {
                  final visible = _selectedType == 'ALL'
                      ? phases
                      : phases
                            .where(
                              (p) =>
                                  p.type.trim().toUpperCase() == _selectedType,
                            )
                            .toList();

                  if (visible.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: 72.h),
                        AppEmptyWidget(
                          icon: Icons.view_kanban_outlined,
                          title: context.loc.noPhasesFound,
                          onRetry: () => ref
                              .read(mobilePhasesProvider.notifier)
                              .refresh(),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(14.w),
                    itemCount: visible.length,
                    itemBuilder: (_, index) => _PhaseBoardCard(
                      phase: visible[index],
                      onUpdateStatus: () =>
                          _pickAndUpdateStatus(visible[index]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseBoardCard extends StatelessWidget {
  const _PhaseBoardCard({
    required this.phase,
    required this.onUpdateStatus,
  });

  final MobilePhaseEntity phase;
  final VoidCallback onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final typeColor = MobilePhaseLocalizer.phaseColor(phase.type);
    return RepaintBoundary(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.only(bottom: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      MobilePhaseLocalizer.phaseType(context, phase.type),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    phase.status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onUpdateStatus,
                    child: Text(context.loc.updateStatus),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                phase.project.name.isEmpty ? phase.id : phase.project.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (phase.project.address.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  phase.project.address,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
