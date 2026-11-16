import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../providers/create_project_provider.dart';
import 'create_project_form_helpers.dart';
import 'schedule_item_card.dart';

class StepThreeSpecsSchedule extends ConsumerStatefulWidget {
  const StepThreeSpecsSchedule({super.key});

  @override
  ConsumerState<StepThreeSpecsSchedule> createState() =>
      _StepThreeSpecsScheduleState();
}

class _StepThreeSpecsScheduleState
    extends ConsumerState<StepThreeSpecsSchedule> {
  late final TextEditingController _areaController;
  late final TextEditingController _heightController;
  late final TextEditingController _typeController;
  late final TextEditingController _notesController;

  final List<String> _noteCategories = [
    'SITE_ACCESS',
    'CUSTOMER_REQUEST',
    'OPEN_POINTS',
    'AGREEMENTS',
    'SPECIAL_REQUIREMENTS',
    'LOCAL_CONTACT',
    'GENERAL',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(createProjectProvider);
    _areaController =
        TextEditingController(text: state.scaffoldArea.toStringAsFixed(0));
    _heightController =
        TextEditingController(text: state.scaffoldHeight.toStringAsFixed(0));
    _typeController = TextEditingController(text: state.scaffoldType);
    _notesController = TextEditingController(text: state.noteContent);
  }

  @override
  void dispose() {
    _areaController.dispose();
    _heightController.dispose();
    _typeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncInputs() {
    final area = double.tryParse(_areaController.text.trim()) ?? 450.0;
    final height = double.tryParse(_heightController.text.trim()) ?? 15.0;
    ref.read(createProjectProvider.notifier).updateStepThree(
          scaffoldArea: area,
          scaffoldHeight: height,
          scaffoldType: _typeController.text.trim(),
          noteContent: _notesController.text.trim(),
        );
  }

  Future<void> _submit() async {
    _syncInputs();
    final success =
        await ref.read(createProjectProvider.notifier).submit(context);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createProjectProvider);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      children: [
        FormSectionTitle(title: context.loc.scaffoldSpecsAndSchedule),
        SizedBox(height: 14.h),
        FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormFieldLabel(label: context.loc.scaffoldSpecification),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormFieldLabelSmall(label: context.loc.scaffoldArea),
                        SizedBox(height: 6.h),
                        FormTextField(
                          controller: _areaController,
                          hint: '450 m²',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormFieldLabelSmall(label: context.loc.heightM),
                        SizedBox(height: 6.h),
                        FormTextField(
                          controller: _heightController,
                          hint: '15 m',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              FormFieldLabelSmall(label: context.loc.scaffoldType),
              SizedBox(height: 6.h),
              FormTextField(
                controller: _typeController,
                hint: 'e.g. Façade / Modular',
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: FormFieldLabel(label: context.loc.scheduleAndDuration),
            ),
            GestureDetector(
              onTap: () {
                _syncInputs();
                ref.read(createProjectProvider.notifier).addScheduleItem(
                      type: state.scheduleData.length.isOdd
                          ? 'dismantling'
                          : 'standing',
                    );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8102E),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  context.loc.addSchedule,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...List.generate(state.scheduleData.length, (index) {
          final item = state.scheduleData[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ScheduleItemCard(
              index: index,
              item: item,
              onChanged: (updated) {
                ref
                    .read(createProjectProvider.notifier)
                    .updateScheduleItem(index, updated);
              },
              onRemove: state.scheduleData.length > 1
                  ? () {
                      ref
                          .read(createProjectProvider.notifier)
                          .removeScheduleItem(index);
                    }
                  : null,
            ),
          );
        }),
        SizedBox(height: 10.h),
        FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormFieldLabel(label: context.loc.siteAccessAndPhotos),
              SizedBox(height: 10.h),
              FormFieldLabelSmall(label: context.loc.noteCategory),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 7.h,
                children: _noteCategories.map((cat) {
                  final sel = state.noteCategory == cat;
                  return GestureDetector(
                    onTap: () => ref
                        .read(createProjectProvider.notifier)
                        .updateStepThree(noteCategory: cat),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFFC8102E)
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        cat.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w500,
                          color: sel ? Colors.white : const Color(0xFF555555),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12.h),
              FormFieldLabelSmall(label: context.loc.noteDetails),
              SizedBox(height: 6.h),
              FormTextField(
                controller: _notesController,
                hint: context.loc.enterSiteInstructions,
                maxLines: 3,
              ),
            ],
          ),
        ),
        SizedBox(height: 22.h),
        StepActionButtons(
          previousText: context.loc.previous,
          nextText: context.loc.createProject,
          isSubmitting: state.isSubmitting,
          onPrevious: () {
            _syncInputs();
            ref.read(createProjectProvider.notifier).setStep(1);
          },
          onNext: _submit,
        ),
      ],
    );
  }
}
