import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import 'site_manager_phase_board.dart';

enum MovePhase { standing, dismantling, completed }

class SiteManagerMoveToPage extends StatefulWidget {
  final ProjectBoardModel project;

  const SiteManagerMoveToPage({super.key, required this.project});

  @override
  State<SiteManagerMoveToPage> createState() => _SiteManagerMoveToPageState();
}

class _SiteManagerMoveToPageState extends State<SiteManagerMoveToPage> {
  MovePhase? _selectedPhase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),

                  SizedBox(height: 28.h),

                  _buildProjectTitle(),

                  SizedBox(height: 22.h),

                  Text(
                    context.loc.moveTo,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  SizedBox(height: 12.h),

                  _buildPhaseOption(
                    phase: MovePhase.standing,
                    icon: Icons.foundation_outlined,
                    title: context.loc.standingScaffold,
                    color: AppColors.info,
                  ),

                  SizedBox(height: 9.h),

                  _buildPhaseOption(
                    phase: MovePhase.dismantling,
                    icon: Icons.build_outlined,
                    title: context.loc.dismantlingPhase,
                    color: AppColors.warning,
                  ),

                  SizedBox(height: 9.h),

                  _buildPhaseOption(
                    phase: MovePhase.completed,
                    icon: Icons.check_rounded,
                    title: context.loc.completed,
                    color: AppColors.success,
                  ),

                  SizedBox(height: 28.h),

                  _buildMoveButton(),

                  SizedBox(height: 8.h),

                  _buildCancelButton(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildBackButton(),

        SizedBox(width: 12.w),

        Expanded(
          child: Text(
            context.loc.moveProject,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pop(),
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(Icons.arrow_back_rounded, size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildProjectTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.project.id}.${widget.project.title}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 4.h),
        Text(
          '${widget.project.company} • ${widget.project.type}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPhaseOption({
    required MovePhase phase,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final selected = _selectedPhase == phase;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPhase = phase;
          });
        },
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 21.sp),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              if (selected)
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 15.sp,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoveButton() {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: ElevatedButton(
        onPressed: _selectedPhase == null ? null : _moveProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.neutral200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(context.loc.moveProject),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => context.pop(),
      child: Text(context.loc.cancel),
    );
  }

  void _moveProject() {
    if (_selectedPhase == null) return;

    // API call here.

    context.pop();
  }
}
