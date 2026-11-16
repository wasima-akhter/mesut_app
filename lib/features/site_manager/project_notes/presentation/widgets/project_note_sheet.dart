import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../projects/enums.dart';
import '../../data/models/project_note_model.dart';
import '../../domain/entities/project_note_entity.dart';
import '../providers/project_notes_provider.dart';

/// Modal bottom sheet for adding or editing a project note.
class ProjectNoteSheet extends ConsumerStatefulWidget {
  final ProjectNoteEntity? initialNote;

  const ProjectNoteSheet({super.key, this.initialNote});

  static Future<bool?> show(
    BuildContext context, {
    ProjectNoteEntity? initialNote,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProjectNoteSheet(initialNote: initialNote),
    );
  }

  @override
  ConsumerState<ProjectNoteSheet> createState() => _ProjectNoteSheetState();
}

class _ProjectNoteSheetState extends ConsumerState<ProjectNoteSheet> {
  late ProjectNoteCategory _category;
  late final TextEditingController _detailsController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;
    _category = note?.category ?? ProjectNoteCategory.siteAccess;
    _detailsController = TextEditingController(text: note?.content ?? '');
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.initialNote != null;

  Future<void> _submit() async {
    final details = _detailsController.text.trim();

    if (details.isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseEnterNoteDetails);
      return;
    }

    setState(() => _isSubmitting = true);

    final notifier = ref.read(projectNotesProvider.notifier);
    final apiCategory = ProjectNoteModel.categoryToApi(_category);
    final bool success;

    if (!_isEdit) {
      success = await notifier.createNote(
        category: apiCategory,
        content: details,
      );
      if (mounted && success) {
        AppSnackBar.showSuccess(context, context.loc.noteCreated);
      }
    } else {
      success = await notifier.updateNote(
        noteId: widget.initialNote!.id,
        category: apiCategory,
        content: details,
      );
      if (mounted && success) {
        AppSnackBar.showSuccess(context, context.loc.noteUpdated);
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        AppSnackBar.showError(context, context.loc.operationFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? context.loc.editNote : context.loc.addNote;
    final buttonText =
        _isEdit ? context.loc.saveChanges : context.loc.saveNotes;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.90,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 9.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD5D5D5),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 8.h),
              child: Text(
                title,
                style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w800),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context.loc.noteCategory),
                    SizedBox(height: 8.h),
                    _buildCategoryChips(),
                    SizedBox(height: 18.h),
                    _buildLabel(context.loc.notesDetails),
                    SizedBox(height: 8.h),
                    _buildDetailsField(),
                    SizedBox(height: 22.h),
                    AppButton(
                      text: buttonText,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submit,
                      borderRadius: 6.r,
                    ),
                    SizedBox(height: 4.h),
                    AppTextButton(
                      text: context.loc.cancel,
                      onPressed: () => Navigator.pop(context),
                      foregroundColor: const Color(0xFF555555),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF333333),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 6.w,
      runSpacing: 7.h,
      children: ProjectNoteCategory.values.map((cat) {
        final selected = _category == cat;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
              ),
            ),
            child: Text(
              cat.label,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: selected ? Colors.white : const Color(0xFF666666),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailsField() {
    return TextField(
      controller: _detailsController,
      maxLines: 5,
      style: TextStyle(fontSize: 15.sp, color: const Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: 'Enter site instructions, gate codes, or client requests...',
        hintStyle: TextStyle(fontSize: 13.5.sp, color: const Color(0xFF999999)),
        contentPadding: EdgeInsets.all(12.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}
