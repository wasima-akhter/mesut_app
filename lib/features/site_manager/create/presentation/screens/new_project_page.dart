import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../providers/create_project_provider.dart';
import '../widgets/step_one_general_info.dart';
import '../widgets/step_three_specs_schedule.dart';
import '../widgets/step_two_location_status.dart';

class NewProjectPage extends ConsumerWidget {
  const NewProjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createProjectProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (state.currentStep > 0) {
                        ref
                            .read(createProjectProvider.notifier)
                            .setStep(state.currentStep - 1);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 18.sp,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        context.loc.newProject,
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70.w,
                    child: Text(
                      context.loc.stepOf(state.currentStep + 1, 3),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: const Color(0xFFC8102E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: state.currentStep,
                children: const [
                  StepOneGeneralInfo(),
                  StepTwoLocationStatus(),
                  StepThreeSpecsSchedule(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
