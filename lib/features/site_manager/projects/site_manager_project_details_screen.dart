import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'dates_modules.dart';
import 'enums.dart';
import 'history_modules.dart';
import 'measurement_modules.dart';
import 'notes_modules.dart';
import 'overview_modules.dart';
import 'photos_modules.dart';
import 'task_modules.dart';

/// ===============================================================
/// PROJECT DETAILS SCREEN
/// ===============================================================

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key, this.projectId = 'Prj-0842'});

  final String projectId;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  ProjectDetailsTab _selectedTab = ProjectDetailsTab.overview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: Column(
          children: [
            _buildFixedHeader(),
            _buildFixedTabs(),
            Expanded(child: _buildScrollableTabContent()),
          ],
        ),
      ),
    );
  }

  /// =============================================================
  /// FIXED HEADER
  /// =============================================================

  Widget _buildFixedHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: Column(
        children: [
          Row(
            children: [
              _circleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.pop(),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  widget.projectId,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
              _circleIconButton(
                icon: Icons.edit_outlined,
                onTap: _onEditProject,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Goltstein complex',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 7.h),
          Row(
            children: [
              _statusTag('Erection', color: const Color(0xFF12B76A)),
              SizedBox(width: 6.w),
              _statusTag('In Progress', color: const Color(0xFF12B76A)),
              SizedBox(width: 6.w),
              _statusTag('High', color: const Color(0xFFE00025)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 15.sp,
                color: const Color(0xFF8A8A8A),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  'Goltsteinstraße 12, 50968 Köln',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// =============================================================
  /// FIXED TABS
  /// =============================================================

  Widget _buildFixedTabs() {
    return Container(
      height: 44.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ProjectDetailsTab.values.map((tab) {
            final selected = tab == _selectedTab;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFC8102E)
                      : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    // fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : const Color(0xFF777777),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// =============================================================
  /// SCROLLABLE CONTENT
  /// =============================================================

  Widget _buildScrollableTabContent() {
    switch (_selectedTab) {
      case ProjectDetailsTab.overview:
        return buildOverviewTab();

      case ProjectDetailsTab.tasks:
        return TasksTab();

      case ProjectDetailsTab.photos:
        return PhotosTab();

      case ProjectDetailsTab.measurement:
        return const MeasurementTab();

      case ProjectDetailsTab.dates:
        return DatesTab();

      case ProjectDetailsTab.notes:
        return NotesTab();
      case ProjectDetailsTab.history:
        return HistoryTab();
    }
  }

  /// =============================================================
  /// COMMON WIDGETS
  /// =============================================================

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 17.sp, color: const Color(0xFF333333)),
      ),
    );
  }

  Widget _statusTag(String text, {required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// =============================================================
  /// ACTIONS
  /// =============================================================

  void _onEditProject() {
    // showMessage('Edit project clicked');
    _showEditProjectDetailsBottomSheet();
  }

  void _showEditProjectDetailsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return EditProjectDetailsBottomSheet(
          title: 'Edit Project Details',
          buttonText: 'Save Changes',

          initialProjectPhase: 'Preconstruction',
          initialOperationalStatus: 'In Progress',
          initialPriority: 'High',
          initialContactName: 'Tim muller (project lead)',
          initialPhoneNumber: '+0325455414',
          initialEmail: 'you33@gmail.com',

          onSave:
              ({
                required String projectPhase,
                required String operationalStatus,
                required String priority,
                required String contactName,
                required String phoneNumber,
                required String email,
              }) {
                // Update your project here.

                setState(() {
                  // Example:
                  // project.phase = projectPhase;
                  // project.operationalStatus = operationalStatus;
                  // project.priority = priority;
                  // project.contactName = contactName;
                  // project.phoneNumber = phoneNumber;
                  // project.email = email;
                });
              },
        );
      },
    );
  }

  //

  //
}

class EditProjectDetailsBottomSheet extends StatefulWidget {
  const EditProjectDetailsBottomSheet({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onSave,
    this.initialProjectPhase,
    this.initialOperationalStatus,
    this.initialPriority,
    this.initialContactName,
    this.initialPhoneNumber,
    this.initialEmail,
  });

  final String title;
  final String buttonText;

  final String? initialProjectPhase;
  final String? initialOperationalStatus;
  final String? initialPriority;
  final String? initialContactName;
  final String? initialPhoneNumber;
  final String? initialEmail;

  final Function({
    required String projectPhase,
    required String operationalStatus,
    required String priority,
    required String contactName,
    required String phoneNumber,
    required String email,
  })
  onSave;

  @override
  State<EditProjectDetailsBottomSheet> createState() =>
      _EditProjectDetailsBottomSheetState();
}

class _EditProjectDetailsBottomSheetState
    extends State<EditProjectDetailsBottomSheet> {
  late final TextEditingController _contactNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _emailController;

  late String _projectPhase;
  late String _operationalStatus;
  late String _priority;

  final List<String> _projectPhases = [
    'Preconstruction',
    'Construction',
    'Completion',
    'Handover',
  ];

  final List<String> _operationalStatuses = [
    'Not Started',
    'In Progress',
    'On Hold',
    'Completed',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();

    _projectPhase = widget.initialProjectPhase ?? _projectPhases.first;

    _operationalStatus =
        widget.initialOperationalStatus ?? _operationalStatuses.first;

    _priority = widget.initialPriority ?? _priorities.first;

    _contactNameController = TextEditingController(
      text: widget.initialContactName ?? '',
    );

    _phoneNumberController = TextEditingController(
      text: widget.initialPhoneNumber ?? '',
    );

    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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
            // Drag handle
            Container(
              width: 42.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 9.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD5D5D5),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 8.h),
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800),
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Project Phase'),

                    SizedBox(height: 6.h),

                    _dropdownField(
                      value: _projectPhase,
                      items: _projectPhases,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _projectPhase = value;
                        });
                      },
                    ),

                    SizedBox(height: 14.h),

                    _label('Operational Status'),

                    SizedBox(height: 6.h),

                    _dropdownField(
                      value: _operationalStatus,
                      items: _operationalStatuses,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _operationalStatus = value;
                        });
                      },
                    ),

                    SizedBox(height: 14.h),

                    _label('Priority'),

                    SizedBox(height: 6.h),

                    _dropdownField(
                      value: _priority,
                      items: _priorities,
                      isPriority: true,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _priority = value;
                        });
                      },
                    ),

                    SizedBox(height: 14.h),

                    _label('Contact Name'),

                    SizedBox(height: 6.h),

                    _textField(
                      controller: _contactNameController,
                      hint: 'Tim muller (project lead)',
                      textInputType: TextInputType.name,
                    ),

                    SizedBox(height: 14.h),

                    _label('Phone Number'),

                    SizedBox(height: 6.h),

                    _textField(
                      controller: _phoneNumberController,
                      hint: '+0325455414',
                      textInputType: TextInputType.phone,
                    ),

                    SizedBox(height: 14.h),

                    _label('Email'),

                    SizedBox(height: 6.h),

                    _textField(
                      controller: _emailController,
                      hint: 'you33@gmail.com',
                      textInputType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: 20.h),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
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
                          widget.buttonText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Cancel
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF555555),
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
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF222222),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required TextInputType textInputType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: textInputType,
      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF444444)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 11.sp, color: const Color(0xFF999999)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: const BorderSide(color: Color(0xFFC8102E)),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isPriority = false,
  }) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8D8D8)),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20.sp,
            color: const Color(0xFF555555),
          ),
          style: TextStyle(
            fontSize: 12.sp,
            color: isPriority && value == 'High'
                ? const Color(0xFFC8102E)
                : const Color(0xFF444444),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isPriority && item == 'High'
                      ? const Color(0xFFC8102E)
                      : const Color(0xFF444444),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _save() {
    final contactName = _contactNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final email = _emailController.text.trim();

    if (contactName.isEmpty) {
      _showError('Please enter contact name.');
      return;
    }

    if (phoneNumber.isEmpty) {
      _showError('Please enter phone number.');
      return;
    }

    if (email.isEmpty) {
      _showError('Please enter email.');
      return;
    }

    widget.onSave(
      projectPhase: _projectPhase,
      operationalStatus: _operationalStatus,
      priority: _priority,
      contactName: contactName,
      phoneNumber: phoneNumber,
      email: email,
    );

    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 13.sp)),
      ),
    );
  }
}
