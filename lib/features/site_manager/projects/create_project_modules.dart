import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/context_extensions.dart';
import 'enums.dart';

// Import your existing enums file.
// import 'project_enums.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  int _currentStep = 0;

  // ============================================================
  // STEP 1 - GENERAL & CUSTOMER INFO
  // ============================================================

  final TextEditingController _projectNameController = TextEditingController();

  final TextEditingController _contactPersonController =
      TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  bool _existingClient = true;
  String? _selectedClient;

  ProjectPriority _priority = ProjectPriority.high;

  // ============================================================
  // STEP 2 - SITE LOCATION & STATUS
  // ============================================================

  final TextEditingController _streetController = TextEditingController();

  final TextEditingController _postalCodeController = TextEditingController();

  final TextEditingController _cityController = TextEditingController();

  String? _siteManager;

  ProjectPhase _projectPhase = ProjectPhase.erection;

  ProjectStatus _operationalStatus = ProjectStatus.inProgress;

  // ============================================================
  // STEP 3 - SCAFFOLD SPECS & SCHEDULE
  // ============================================================

  final TextEditingController _estimatedAreaController =
      TextEditingController();

  DateTime _erectionStartDate = DateTime(2026, 9, 18);

  DateTime _dismantlingDate = DateTime(2026, 9, 18);

  double _erectionDuration = 2.5;
  double _dismantlingDuration = 2.5;

  ProjectNoteCategory _selectedNoteCategory = ProjectNoteCategory.siteAccess;

  final TextEditingController _notesController = TextEditingController();

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _projectNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    _streetController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();

    _estimatedAreaController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(child: _buildCurrentStep()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep--;
                });
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
              context.loc.stepOf(_currentStep + 1, 3),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15.sp,
                color: const Color(0xFFC8102E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT STEP
  // ============================================================

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStepOne();

      case 1:
        return _buildStepTwo();

      case 2:
        return _buildStepThree();

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // STEP 1
  // ============================================================

  Widget _buildStepOne() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _sectionTitle(context.loc.generalAndCustomerInfo),

              SizedBox(height: 16.h),

              _fieldLabel(context.loc.projectName),

              SizedBox(height: 7.h),

              _textField(
                controller: _projectNameController,
                hint: 'e.g. Goldstein Complex',
              ),

              SizedBox(height: 17.h),

              _fieldLabel(context.loc.customer),

              SizedBox(height: 7.h),

              _customerTypeSelector(),

              SizedBox(height: 8.h),

              if (_existingClient)
                _dropdown(
                  value: _selectedClient,
                  hint: context.loc.selectClient,
                  items: const [
                    'Goldstein GmbH',
                    'Muller Construction',
                    'Weber Scaffolding',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedClient = value;
                    });
                  },
                ),

              SizedBox(height: 17.h),

              _fieldLabel(context.loc.priority),

              SizedBox(height: 7.h),

              _enumDropdown<ProjectPriority>(
                value: _priority,
                items: ProjectPriority.values,
                labelBuilder: (value) => value.label,
                colorBuilder: (value) => value.color,
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _priority = value;
                  });
                },
              ),

              SizedBox(height: 17.h),

              _fieldLabel(context.loc.contactPerson),

              SizedBox(height: 7.h),

              _textField(
                controller: _contactPersonController,
                hint: 'Tim Muller (project lead)',
              ),

              SizedBox(height: 17.h),

              _fieldLabel(context.loc.phoneNumber),

              SizedBox(height: 7.h),

              _textField(
                controller: _phoneController,
                hint: '+0325454514',
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 17.h),

              _fieldLabel(context.loc.email),

              SizedBox(height: 7.h),

              _textField(
                controller: _emailController,
                hint: 'you33@gmail.com',
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 22.h),

              _nextButton(),
            ]),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2
  // ============================================================

  Widget _buildStepTwo() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _sectionTitle(context.loc.siteLocationAndStatus),

              SizedBox(height: 16.h),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(context.loc.siteAddress),

                    SizedBox(height: 7.h),

                    _fieldLabelSmall(context.loc.streetAndNo),

                    SizedBox(height: 6.h),

                    _textField(
                      controller: _streetController,
                      hint: 'e.g. Goldstein',
                    ),

                    SizedBox(height: 14.h),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabelSmall(context.loc.postalCode),

                              SizedBox(height: 6.h),

                              _textField(
                                controller: _postalCodeController,
                                hint: 'e.g. 1212',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 10.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabelSmall(context.loc.city),

                              SizedBox(height: 6.h),

                              _textField(
                                controller: _cityController,
                                hint: 'e.g. Goldstein',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(context.loc.siteManager),

                    SizedBox(height: 7.h),

                    _dropdown(
                      value: _siteManager,
                      hint: context.loc.selectSiteManager,
                      items: const [
                        'Mesut Yilmaz',
                        'Tim Muller',
                        'Andreas Weber',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _siteManager = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(context.loc.workflowStatus),

                    SizedBox(height: 12.h),

                    _fieldLabelSmall(context.loc.projectPhase),

                    SizedBox(height: 6.h),

                    _enumDropdown<ProjectPhase>(
                      value: _projectPhase,
                      items: ProjectPhase.values,
                      labelBuilder: (value) => value.label,
                      colorBuilder: (value) => value.color,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _projectPhase = value;
                        });
                      },
                    ),

                    SizedBox(height: 14.h),

                    _fieldLabelSmall(context.loc.operationalStatus),

                    SizedBox(height: 6.h),

                    _enumDropdown<ProjectStatus>(
                      value: _operationalStatus,
                      items: ProjectStatus.values,
                      labelBuilder: (value) => value.label,
                      colorBuilder: (value) => value.color,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _operationalStatus = value;
                        });
                      },
                    ),

                    SizedBox(height: 14.h),

                    _fieldLabelSmall(context.loc.priority),

                    SizedBox(height: 6.h),

                    _enumDropdown<ProjectPriority>(
                      value: _priority,
                      items: ProjectPriority.values,
                      labelBuilder: (value) => value.label,
                      colorBuilder: (value) => value.color,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _priority = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              _stepButtons(
                previousText: context.loc.previous,
                nextText: context.loc.next,
                onPrevious: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                onNext: () {
                  setState(() {
                    _currentStep++;
                  });
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 3
  // ============================================================

  Widget _buildStepThree() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _sectionTitle(context.loc.scaffoldSpecsAndSchedule),

              SizedBox(height: 16.h),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(context.loc.estimatedAreaM2),

                    SizedBox(height: 7.h),

                    _textField(
                      controller: _estimatedAreaController,
                      hint: '450 m²',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              _scheduleCard(
                title: context.loc.erectionSchedule,
                dateLabel: context.loc.startDate,
                date: _erectionStartDate,
                duration: _erectionDuration,
                onDateTap: () => _selectDate(
                  initialDate: _erectionStartDate,
                  onSelected: (date) {
                    setState(() {
                      _erectionStartDate = date;
                    });
                  },
                ),
                onMinus: () {
                  setState(() {
                    if (_erectionDuration > 0.5) {
                      _erectionDuration -= 0.5;
                    }
                  });
                },
                onPlus: () {
                  setState(() {
                    _erectionDuration += 0.5;
                  });
                },
              ),

              SizedBox(height: 12.h),

              _scheduleCard(
                title: context.loc.dismantlingSchedule,
                dateLabel: context.loc.teardownDate,
                date: _dismantlingDate,
                duration: _dismantlingDuration,
                onDateTap: () => _selectDate(
                  initialDate: _dismantlingDate,
                  onSelected: (date) {
                    setState(() {
                      _dismantlingDate = date;
                    });
                  },
                ),
                onMinus: () {
                  setState(() {
                    if (_dismantlingDuration > 0.5) {
                      _dismantlingDuration -= 0.5;
                    }
                  });
                },
                onPlus: () {
                  setState(() {
                    _dismantlingDuration += 0.5;
                  });
                },
              ),

              SizedBox(height: 12.h),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(context.loc.safetyInspection),

                    SizedBox(height: 10.h),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.loc.nextDueDate,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF777777),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 17.sp,
                          color: const Color(0xFF555555),
                        ),
                        SizedBox(width: 7.w),
                        Text(
                          _formatDate(_erectionStartDate),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              _buildSiteAccessCard(),

              SizedBox(height: 12.h),

              _buildNotesCard(),

              SizedBox(height: 12.h),

              _buildPhotosCard(),

              SizedBox(height: 20.h),

              _stepButtons(
                previousText: context.loc.previous,
                nextText: context.loc.createProject,
                onPrevious: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                onNext: _createProject,
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SITE ACCESS / NOTE CATEGORY
  // ============================================================

  Widget _buildSiteAccessCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(context.loc.siteAccessAndPhotos),

          SizedBox(height: 10.h),

          _fieldLabelSmall(context.loc.noteCategory),

          SizedBox(height: 8.h),

          Wrap(
            spacing: 6.w,
            runSpacing: 7.h,
            children: ProjectNoteCategory.values.map((category) {
              final selected = _selectedNoteCategory == category;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNoteCategory = category;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFC8102E)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : const Color(0xFF666666),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTES
  // ============================================================

  Widget _buildNotesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(context.loc.noteDetails),

          SizedBox(height: 7.h),

          TextField(
            controller: _notesController,
            maxLines: 4,
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF333333)),
            decoration: InputDecoration(
              hintText: context.loc.enterSiteInstructions,
              hintStyle: TextStyle(
                fontSize: 15.sp,
                color: const Color(0xFF999999),
              ),
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
                borderSide: const BorderSide(color: Color(0xFFC8102E)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PHOTOS
  // ============================================================

  Widget _buildPhotosCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(context.loc.uploadPhotos),

          SizedBox(height: 8.h),

          GestureDetector(
            onTap: _uploadFrontPhoto,
            child: Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFBDBDBD)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 25.sp,
                    color: const Color(0xFF999999),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    context.loc.uploadFrontSide,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              _photoPlaceholder(),
              SizedBox(width: 6.w),
              _photoPlaceholder(),
              SizedBox(width: 6.w),
              _photoPlaceholder(),
              SizedBox(width: 6.w),
              _photoPlaceholder(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Expanded(
      child: GestureDetector(
        onTap: _uploadPhoto,
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFBDBDBD)),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Icon(Icons.add, size: 20.sp, color: const Color(0xFF999999)),
        ),
      ),
    );
  }

  // ============================================================
  // SCHEDULE CARD
  // ============================================================

  Widget _scheduleCard({
    required String title,
    required String dateLabel,
    required DateTime date,
    required double duration,
    required VoidCallback onDateTap,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(title),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ),

              GestureDetector(
                onTap: onDateTap,
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: const Color(0xFF555555),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 9.h),
            child: Divider(height: 1, color: const Color(0xFFE5E5E5)),
          ),

          Row(
            children: [
              Expanded(
                child: Text(
                  context.loc.duration,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ),

              GestureDetector(
                onTap: onMinus,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD0D0D0)),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 14.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),

              SizedBox(width: 9.w),

              Text(
                context.loc.durationDays(duration.toStringAsFixed(1)),
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(width: 9.w),

              GestureDetector(
                onTap: onPlus,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD0D0D0)),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 14.sp,
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

  // ============================================================
  // CUSTOMER TYPE
  // ============================================================

  Widget _customerTypeSelector() {
    return Container(
      height: 42.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _customerTypeButton(
              title: context.loc.existingClient,
              selected: _existingClient,
              onTap: () {
                setState(() {
                  _existingClient = true;
                });
              },
            ),
          ),
          Expanded(
            child: _customerTypeButton(
              title: context.loc.newClient,
              selected: !_existingClient,
              onTap: () {
                setState(() {
                  _existingClient = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerTypeButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF777777),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GENERIC DROPDOWN
  // ============================================================

  Widget _dropdown({
    String? value,
    String? hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8D8D8)),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint == null
              ? null
              : Text(
                  hint,
                  style: TextStyle(
                    fontSize: 17.5.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 21.sp,
            color: const Color(0xFF555555),
          ),
          style: TextStyle(fontSize: 19.sp, color: const Color(0xFF444444)),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 18.sp)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================================================
  // ENUM DROPDOWN
  // ============================================================

  Widget _enumDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T value) labelBuilder,
    required ValueChanged<T?> onChanged,

    Color Function(T value)? colorBuilder,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8D8D8)),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 21.sp,
            color: const Color(0xFF555555),
          ),
          style: TextStyle(fontSize: 18.sp, color: const Color(0xFF444444)),
          items: items.map((item) {
            final color = colorBuilder != null ? colorBuilder(item) : null;
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                style: TextStyle(fontSize: 18.sp, color: color),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 17.sp, color: const Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 17.sp, color: const Color(0xFF999999)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
          borderSide: const BorderSide(color: Color(0xFFC8102E)),
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: child,
    );
  }

  // ============================================================
  // LABELS
  // ============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 21.5.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF222222),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF222222),
      ),
    );
  }

  Widget _fieldLabelSmall(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF333333),
      ),
    );
  }

  // ============================================================
  // BUTTONS
  // ============================================================

  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _currentStep++;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC8102E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Text(
          context.loc.next,
          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _stepButtons({
    required VoidCallback onPrevious,
    required VoidCallback onNext,
    String? previousText,
    String? nextText,
  }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: OutlinedButton(
              onPressed: onPrevious,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF333333),
                side: const BorderSide(color: Color(0xFFAAAAAA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                previousText ?? context.loc.previous,
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8102E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                nextText ?? context.loc.next,
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      onSelected(date);
    }
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ============================================================
  // PHOTO ACTIONS
  // ============================================================

  void _uploadFrontPhoto() {
    // Connect image_picker here.
  }

  void _uploadPhoto() {
    // Connect image_picker here.
  }

  // ============================================================
  // CREATE PROJECT
  // ============================================================

  void _createProject() {
    if (_projectNameController.text.trim().isEmpty) {
      _showError(context.loc.pleaseEnterProjectName);
      return;
    }

    if (_streetController.text.trim().isEmpty) {
      _showError(context.loc.pleaseEnterSiteAddress);
      return;
    }

    if (_cityController.text.trim().isEmpty) {
      _showError(context.loc.pleaseEnterCity);
      return;
    }

    // At this point you can send all values to your
    // controller / ViewModel / API.

    debugPrint('''
      PROJECT
      -------------------------
      Name: ${_projectNameController.text}
      Existing Client: $_existingClient
      Client: $_selectedClient
      Priority: ${_priority.label}
      Contact: ${_contactPersonController.text}
      Phone: ${_phoneController.text}
      Email: ${_emailController.text}

      SITE
      -------------------------
      Street: ${_streetController.text}
      Postal: ${_postalCodeController.text}
      City: ${_cityController.text}
      Manager: $_siteManager
      Phase: ${_projectPhase.label}
      Status: ${_operationalStatus.label}

      SCAFFOLD
      -------------------------
      Area: ${_estimatedAreaController.text}
      Erection: ${_formatDate(_erectionStartDate)}
      Erection Duration: $_erectionDuration
      Dismantling: ${_formatDate(_dismantlingDate)}
      Dismantling Duration: $_dismantlingDuration
      Note Category: ${_selectedNoteCategory.label}
      Notes: ${_notesController.text}
      ''');

    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16.sp)),
      ),
    );
  }
}

