import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'enums.dart';
import 'models.dart';

class NotesTab extends StatefulWidget {
  const NotesTab({super.key});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  final List<ProjectNote> _notes = [
    ProjectNote(
      category: ProjectNoteCategory.siteAccess,
      details:
          'Entry via Gate 2 on south side. Code: 4821. Heavy trucks allowed after 08:00 AM only.',
      author: 'Mesut Yilmaz',
      createdAt: DateTime(2026, 9, 18, 8, 15),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 30.h),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _buildTopBar(),

                SizedBox(height: 10.h),

                if (_notes.isEmpty)
                  _buildEmptyState()
                else
                  ..._notes.asMap().entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 9.h),
                      child: _buildNoteCard(entry.value, entry.key),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        const Spacer(),

        SizedBox(
          height: 38.h,
          child: ElevatedButton.icon(
            onPressed: _showAddNoteBottomSheet,
            icon: Icon(Icons.add, size: 17.sp),
            label: Text(
              'Add Note',
              style: TextStyle(fontSize: 16.5.sp, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8102E),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NOTE CARD
  // ============================================================

  Widget _buildNoteCard(ProjectNote note, int index) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  note.category.label,
                  style: TextStyle(
                    fontSize: 17.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () => _showEditNoteBottomSheet(note, index),
                child: Icon(
                  Icons.edit_outlined,
                  size: 17.sp,
                  color: const Color(0xFF777777),
                ),
              ),

              SizedBox(width: 9.w),

              GestureDetector(
                onTap: () => _deleteNote(index),
                child: Icon(
                  Icons.delete_outline,
                  size: 18.sp,
                  color: const Color(0xFFE00025),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Text(
            note.details,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.35,
              color: const Color(0xFF666666),
            ),
          ),

          SizedBox(height: 9.h),

          Text(
            '${note.author} · ${_formatDate(note.createdAt)}',
            style: TextStyle(fontSize: 14.5.sp, color: const Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notes_outlined,
            size: 42.sp,
            color: const Color(0xFFBBBBBB),
          ),
          SizedBox(height: 10.h),
          Text(
            'No project notes',
            style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 5.h),
          Text(
            'Add a note to keep important project information.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD NOTE
  // ============================================================

  Future<void> _showAddNoteBottomSheet() async {
    final note = await showModalBottomSheet<ProjectNote>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const _ProjectNoteBottomSheet(mode: _ProjectNoteSheetMode.add);
      },
    );

    if (note == null) return;

    setState(() {
      _notes.insert(0, note);
    });
  }

  // ============================================================
  // EDIT NOTE
  // ============================================================

  Future<void> _showEditNoteBottomSheet(ProjectNote note, int index) async {
    final updatedNote = await showModalBottomSheet<ProjectNote>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _ProjectNoteBottomSheet(
          mode: _ProjectNoteSheetMode.edit,
          note: note,
        );
      },
    );

    if (updatedNote == null) return;

    setState(() {
      _notes[index] = updatedNote;
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteNote(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Note?',
            style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'This note will be permanently removed.',
            style: TextStyle(fontSize: 17.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(fontSize: 17.sp)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: 17.sp,
                  color: const Color(0xFFE00025),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _notes.removeAt(index);
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, '
        '${date.year} at '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

enum _ProjectNoteSheetMode { add, edit }

class _ProjectNoteBottomSheet extends StatefulWidget {
  const _ProjectNoteBottomSheet({required this.mode, this.note});

  final _ProjectNoteSheetMode mode;
  final ProjectNote? note;

  @override
  State<_ProjectNoteBottomSheet> createState() =>
      _ProjectNoteBottomSheetState();
}

class _ProjectNoteBottomSheetState extends State<_ProjectNoteBottomSheet> {
  late ProjectNoteCategory _category;

  late TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();

    _category = widget.note?.category ?? ProjectNoteCategory.siteAccess;

    _detailsController = TextEditingController(
      text: widget.note?.details ?? '',
    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.mode == _ProjectNoteSheetMode.edit;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .90,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHandle(),

            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 8.h),
              child: Text(
                _isEdit ? 'Edit Project Note' : 'Add Project Note',
                style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800),
              ),
            ),

            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 25.h),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Note Category'),

                          SizedBox(height: 9.h),

                          _buildCategoryWrap(),

                          SizedBox(height: 18.h),

                          _fieldLabel('Notes Details'),

                          SizedBox(height: 7.h),

                          _buildDetailsField(),

                          SizedBox(height: 18.h),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC8102E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                              ),
                              child: Text(
                                _isEdit ? 'Save Changes' : 'Save Notes',
                                style: TextStyle(
                                  fontSize: 17.5.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 3.h),

                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16.5.sp,
                                  color: const Color(0xFF555555),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 42.w,
      height: 4.h,
      margin: EdgeInsets.only(top: 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD5D5D5),
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF333333),
      ),
    );
  }

  // ============================================================
  // CATEGORY CHIPS
  // ============================================================

  Widget _buildCategoryWrap() {
    return Wrap(
      spacing: 6.w,
      runSpacing: 7.h,
      children: ProjectNoteCategory.values.map((category) {
        final selected = _category == category;

        return GestureDetector(
          onTap: () {
            setState(() {
              _category = category;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFC8102E)
                  : const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text(
              category.label,
              style: TextStyle(
                fontSize: 14.5.sp,
                color: selected ? Colors.white : const Color(0xFF777777),
                fontWeight: FontWeight.w600,
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
      style: TextStyle(fontSize: 17.sp, color: const Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: 'Enter site instructions, gate codes, or client requests...',
        hintStyle: TextStyle(fontSize: 16.sp, color: const Color(0xFF999999)),
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
          borderSide: const BorderSide(color: Color(0xFFC8102E), width: 1.2),
        ),
      ),
    );
  }

  void _save() {
    final details = _detailsController.text.trim();

    if (details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter note details.',
            style: TextStyle(fontSize: 17.sp),
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      ProjectNote(
        category: _category,
        details: details,
        author: widget.note?.author ?? 'Mesut Yilmaz',
        createdAt: widget.note?.createdAt ?? DateTime.now(),
      ),
    );
  }
}
