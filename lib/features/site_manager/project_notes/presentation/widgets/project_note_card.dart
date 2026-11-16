import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/extensions/date_time_extensions.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../projects/enums.dart';
import '../../domain/entities/project_note_entity.dart';

/// Card widget displaying a single project note with edit and delete capabilities.
class ProjectNoteCard extends StatelessWidget {
  final ProjectNoteEntity note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectNoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Category Name & Action Icons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  note.category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => _showDeleteConfirmation(context),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    Icons.delete_outline,
                    size: 19.sp,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Row 2: Note Content
          Text(
            note.content,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.4,
              color: const Color(0xFF555555),
            ),
          ),

          SizedBox(height: 10.h),

          // Row 3: Author and Creation Date
          Text(
            '${note.authorName} · ${_formatDate(note.createdAt)}',
            style: TextStyle(
              fontSize: 13.5.sp,
              color: const Color(0xFF999999),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return date.formatLocalized();
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.loc.deleteNote,
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.loc.deleteNoteConfirmation,
          style: TextStyle(fontSize: 14.5.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.loc.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              onDelete();
            },
            child: Text(
              context.loc.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
