import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import 'project_filter_controls.dart';

class ProjectFilterBottomSheet extends StatefulWidget {
  const ProjectFilterBottomSheet({
    super.key,
    required this.onApply,
    this.initialPhases = const [],
    this.initialCities = const [],
    this.initialPriority = 'All',
    this.initialCustomerCategory = 'All',
    this.initialSortBy = 'Newest',
  });

  final void Function({
    required List<String> phases,
    required List<String> cities,
    required String priority,
    required String customerCategory,
    required String sortBy,
  }) onApply;

  final List<String> initialPhases;
  final List<String> initialCities;
  final String initialPriority;
  final String initialCustomerCategory;
  final String initialSortBy;

  @override
  State<ProjectFilterBottomSheet> createState() =>
      _ProjectFilterBottomSheetState();
}

class _ProjectFilterBottomSheetState extends State<ProjectFilterBottomSheet> {
  final TextEditingController _citySearchController = TextEditingController();

  final List<String> _phases = [
    'Erection',
    'Dismantling',
    'Standing Scaffolds',
    'Completed',
  ];

  final List<String> _cities = [
    'Cologne (Köln)',
    'Düsseldorf',
    'Bonn',
    'Leverkusen',
  ];

  late final List<String> _selectedPhases;
  late final List<String> _selectedCities;
  late String _selectedPriority;
  late String _selectedCustomerCategory;
  late String _selectedSortBy;

  @override
  void initState() {
    super.initState();
    _selectedPhases = List<String>.from(widget.initialPhases);
    _selectedCities = List<String>.from(widget.initialCities);
    _selectedPriority = widget.initialPriority;
    _selectedCustomerCategory = widget.initialCustomerCategory;
    _selectedSortBy = widget.initialSortBy;
  }

  @override
  void dispose() {
    _citySearchController.dispose();
    super.dispose();
  }

  List<String> get _filteredCities {
    final query = _citySearchController.text.trim().toLowerCase();
    if (query.isEmpty) return _cities;
    return _cities.where((city) => city.toLowerCase().contains(query)).toList();
  }

  void _resetAll() {
    setState(() {
      _selectedPhases.clear();
      _selectedCities.clear();
      _selectedPriority = 'All';
      _selectedCustomerCategory = 'All';
      _selectedSortBy = 'Newest';
      _citySearchController.clear();
    });
  }

  void _applyFilters() {
    widget.onApply(
      phases: List<String>.from(_selectedPhases),
      cities: List<String>.from(_selectedCities),
      priority: _selectedPriority,
      customerCategory: _selectedCustomerCategory,
      sortBy: _selectedSortBy,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .92,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
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
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 85.w,
                    child: GestureDetector(
                      onTap: _resetAll,
                      child: Text(
                        context.loc.resetAll,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFC8102E),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        context.loc.filterProjects,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 65.w,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilterSectionTitle(title: context.loc.phase),
                    SizedBox(height: 8.h),
                    ..._phases.map(
                      (phase) => FilterCheckboxRow(
                        title: phase,
                        isSelected: _selectedPhases.contains(phase),
                        onTap: () {
                          setState(() {
                            if (_selectedPhases.contains(phase)) {
                              _selectedPhases.remove(phase);
                            } else {
                              _selectedPhases.add(phase);
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    FilterSectionTitle(title: context.loc.cityOrLocation),
                    SizedBox(height: 8.h),
                    FilterCitySearchField(
                      controller: _citySearchController,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 6.h),
                    ..._filteredCities.map(
                      (city) => FilterCheckboxRow(
                        title: city,
                        isSelected: _selectedCities.contains(city),
                        onTap: () {
                          setState(() {
                            if (_selectedCities.contains(city)) {
                              _selectedCities.remove(city);
                            } else {
                              _selectedCities.add(city);
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    FilterSectionTitle(title: context.loc.priority),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        FilterChipButton(
                          label: context.loc.all,
                          selected: _selectedPriority == 'All',
                          onTap: () => setState(() => _selectedPriority = 'All'),
                        ),
                        FilterChipButton(
                          label: context.loc.high,
                          selected: _selectedPriority == 'High',
                          textColor: const Color(0xFFC8102E),
                          onTap: () => setState(() => _selectedPriority = 'High'),
                        ),
                        FilterChipButton(
                          label: context.loc.medium,
                          selected: _selectedPriority == 'Medium',
                          textColor: const Color(0xFFFF9800),
                          onTap: () => setState(() => _selectedPriority = 'Medium'),
                        ),
                        FilterChipButton(
                          label: context.loc.low,
                          selected: _selectedPriority == 'Low',
                          onTap: () => setState(() => _selectedPriority = 'Low'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    FilterSectionTitle(title: context.loc.customerCategory),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        FilterChipButton(
                          label: context.loc.all,
                          selected: _selectedCustomerCategory == 'All',
                          onTap: () => setState(() => _selectedCustomerCategory = 'All'),
                        ),
                        FilterChipButton(
                          label: context.loc.commercial,
                          selected: _selectedCustomerCategory == 'Commercial',
                          onTap: () => setState(() => _selectedCustomerCategory = 'Commercial'),
                        ),
                        FilterChipButton(
                          label: context.loc.private,
                          selected: _selectedCustomerCategory == 'Private',
                          onTap: () => setState(() => _selectedCustomerCategory = 'Private'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    FilterSectionTitle(title: context.loc.sortBy),
                    SizedBox(height: 8.h),
                    FilterRadioRow(
                      title: context.loc.newest,
                      value: 'Newest',
                      selectedSortBy: _selectedSortBy,
                      onSelected: (v) => setState(() => _selectedSortBy = v),
                    ),
                    FilterRadioRow(
                      title: context.loc.nextInspectionDate,
                      value: 'Next inspection date',
                      selectedSortBy: _selectedSortBy,
                      onSelected: (v) => setState(() => _selectedSortBy = v),
                    ),
                    FilterRadioRow(
                      title: context.loc.projectNameAz,
                      value: 'Project name (a-z)',
                      selectedSortBy: _selectedSortBy,
                      onSelected: (v) => setState(() => _selectedSortBy = v),
                    ),
                    SizedBox(height: 20.h),
                    AppButton(
                      text: context.loc.applyFilters,
                      onPressed: _applyFilters,
                      borderRadius: 6.r,
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
}
