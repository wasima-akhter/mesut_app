import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/features/site_manager/projects/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'models.dart';

// ============================================================
// PROJECT PAGE
// ============================================================

class SiteManagerProjectsPage extends StatefulWidget {
  const SiteManagerProjectsPage({super.key});

  @override
  State<SiteManagerProjectsPage> createState() =>
      _SiteManagerProjectsPageState();
}

class _SiteManagerProjectsPageState extends State<SiteManagerProjectsPage> {
  ProjectTab selectedTab = ProjectTab.all;

  final List<Project> allProjects = const [
    Project(
      id: 'Prj-0842',
      title: 'Goltsteins.Complex',
      company: 'Hochief AG',
      address: 'Goltsteinstraße 12, 50968 Köln',
      owner: 'Mesut Yilmaz',
      duration: 'Erection: Sept 18 – Sept 20 (2.5 days)',
      phase: ProjectPhase.erection,
      priority: ProjectPriority.high,
      status: ProjectStatus.inProgress,
    ),
    Project(
      id: 'Prj-0842',
      title: 'Goltsteins.Complex',
      company: 'Hochief AG',
      address: 'Goltsteinstraße 12, 50968 Köln',
      owner: 'Mesut Yilmaz',
      duration: 'Dismantling: Sept 18 – Sept 20 (2.5 days)',
      phase: ProjectPhase.dismantling,
      priority: ProjectPriority.medium,
      status: ProjectStatus.notStarted,
    ),
    Project(
      id: 'Prj-0842',
      title: 'Goltsteins.Complex',
      company: 'Hochief AG',
      address: 'Goltsteinstraße 12, 50968 Köln',
      owner: 'Mesut Yilmaz',
      duration: 'Inspection Due: Sept 18 – Sept 20 (2.5 days)',
      phase: ProjectPhase.standingScaffold,
      priority: ProjectPriority.medium,
      status: ProjectStatus.postponed,
    ),
    Project(
      id: 'Prj-0842',
      title: 'Goltsteins.Complex',
      company: 'Hochief AG',
      address: 'Goltsteinstraße 12, 50968 Köln',
      owner: 'Mesut Yilmaz',
      duration: 'Finished On: Aug 28, 2026',
      phase: ProjectPhase.completed,
      priority: ProjectPriority.low,
      status: ProjectStatus.inProgress,
    ),
    Project(
      id: 'Prj-0851',
      title: 'Riverside Tower',
      company: 'Hochief AG',
      address: 'Rheinstrasse 28, 50667 Köln',
      owner: 'Mesut Yilmaz',
      duration: 'Erection: Sept 20 – Sept 24 (4 days)',
      phase: ProjectPhase.erection,
      priority: ProjectPriority.low,
      status: ProjectStatus.inProgress,
    ),
    Project(
      id: 'Prj-0858',
      title: 'Central Plaza',
      company: 'Hochief AG',
      address: 'Hohenzollernring 44, 50672 Köln',
      owner: 'Mesut Yilmaz',
      duration: 'Dismantling: Sept 21 – Sept 25 (4 days)',
      phase: ProjectPhase.dismantling,
      priority: ProjectPriority.high,
      status: ProjectStatus.notStarted,
    ),
  ];

  List<Project> get filteredProjects {
    switch (selectedTab) {
      case ProjectTab.all:
        return allProjects;

      case ProjectTab.active:
        return allProjects
            .where(
              (project) =>
                  project.status == ProjectStatus.inProgress ||
                  project.status == ProjectStatus.notStarted,
            )
            .toList();

      case ProjectTab.myProjects:
        return allProjects
            .where((project) => project.owner == 'Mesut Yilmaz')
            .toList();

      case ProjectTab.thisWeek:
        return allProjects
            .where(
              (project) =>
                  project.phase == ProjectPhase.erection ||
                  project.phase == ProjectPhase.dismantling,
            )
            .toList();

      case ProjectTab.inspection:
        return allProjects
            .where((project) => project.phase == ProjectPhase.standingScaffold)
            .toList();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 15)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openSearch() {
    showSearch(context: context, delegate: ProjectSearchDelegate(allProjects));
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ProjectFilterBottomSheet(
          onApply:
              ({
                required List<String> phases,
                required List<String> cities,
                required String priority,
                required String customerCategory,
                required String sortBy,
              }) {
                setState(() {
                  // Apply your filters here.

                  // Example:
                  // _selectedPhases = phases;
                  // _selectedCities = cities;
                  // _selectedPriority = priority;
                  // _selectedCustomerCategory = customerCategory;
                  // _selectedSortBy = sortBy;
                });
              },
        );
      },
    );
  }

  void _addProject() {
    // _showMessage('Create new project');

    context.push(RouteConstants.siteManagerCreateproject);
  }

  @override
  Widget build(BuildContext context) {
    final projects = filteredProjects;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ======================================================
      // BODY
      // ======================================================
      body: SafeArea(
        child: Column(
          children: [
            // ------------------------------------------------
            // FIXED HEADER
            // ------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _buildHeader(),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------
            // FIXED TABS
            // ------------------------------------------------
            SizedBox(
              height: 37,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(ProjectTab.values.length, (index) {
                    final tab = ProjectTab.values[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == ProjectTab.values.length - 1 ? 0 : 7,
                      ),
                      child: _buildTab(tab),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 11),

            // ------------------------------------------------
            // SCROLLABLE PROJECT LIST
            // ------------------------------------------------
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final project = projects[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildProjectCard(project),
                        );
                      }, childCount: projects.length),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ======================================================
      // FLOATING ADD BUTTON
      // ======================================================
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  //
  Widget _taskFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF333333) : Colors.white,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: selected ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: selected ? Colors.white : const Color(0xFF666666),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Projects',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Color(0xFF151515),
            ),
          ),
        ),

        _HeaderButton(icon: Icons.search, onTap: _openSearch),

        const SizedBox(width: 8),

        _HeaderButton(icon: Icons.tune, onTap: _openFilters),
      ],
    );
  }

  // ==========================================================
  // TAB
  // ==========================================================

  Widget _buildTab(ProjectTab tab) {
    final bool selected = selectedTab == tab;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tab;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFC8102E) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          tab.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : const Color(0xFF707070),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PROJECT CARD
  // ==========================================================

  Widget _buildProjectCard(Project project) {
    return GestureDetector(
      onTap: () {
        // _showMessage('Opening ${project.id} · ${project.title}');
        context.push(
          RouteConstants.siteManagerProjectDetail,
          extra: project.id,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------
            // TAG ROW
            // -----------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PhaseBadge(phase: project.phase),

                const SizedBox(width: 7),

                _StatusLabel(status: project.status),

                const Spacer(),

                _PriorityBadge(priority: project.priority),
              ],
            ),

            const SizedBox(height: 9),

            // -----------------------------------------------
            // PROJECT TITLE
            // -----------------------------------------------
            Text(
              '${project.id} · ${project.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xFF151515),
              ),
            ),

            const SizedBox(height: 7),

            // -----------------------------------------------
            // COMPANY
            // -----------------------------------------------
            _InfoRow(
              icon: Icons.business_outlined,
              text: '${project.company} · Commercial',
            ),

            const SizedBox(height: 5),

            // -----------------------------------------------
            // ADDRESS
            // -----------------------------------------------
            _InfoRow(icon: Icons.location_on_outlined, text: project.address),

            const SizedBox(height: 5),

            // -----------------------------------------------
            // DURATION
            // -----------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Color(0xFF8A8A8A),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      project.duration,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: project.phase == ProjectPhase.standingScaffold
                            ? const Color(0xFFFF7A00)
                            : const Color(0xFF888888),
                        fontWeight:
                            project.phase == ProjectPhase.standingScaffold
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // -----------------------------------------------
            // OWNER
            // -----------------------------------------------
            _InfoRow(icon: Icons.person_outline, text: project.owner),
          ],
        ),
      ),
    );
  }

  //
}

// ============================================================
// HEADER BUTTON
// ============================================================

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE4E4E4)),
        ),
        child: Icon(icon, size: 17, color: const Color(0xFF858585)),
      ),
    );
  }
}

// ============================================================
// PHASE BADGE
// ============================================================

class _PhaseBadge extends StatelessWidget {
  final ProjectPhase phase;

  const _PhaseBadge({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: phase.backgroundColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        phase.label,
        style: TextStyle(
          color: phase.color,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ============================================================
// PRIORITY BADGE
// ============================================================

class _PriorityBadge extends StatelessWidget {
  final ProjectPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: priority.color,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ============================================================
// STATUS
// ============================================================

class _StatusLabel extends StatelessWidget {
  final ProjectStatus status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          status.label,
          style: TextStyle(
            fontSize: 12.sp,
            color: status.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8C8C8C)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5.sp, color: Color(0xFF858585)),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// FILTER CHIP
// ============================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const _FilterChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH DELEGATE
// ============================================================

class ProjectSearchDelegate extends SearchDelegate<Project?> {
  final List<Project> projects;

  ProjectSearchDelegate(this.projects);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = projects.where((project) {
      final search = query.toLowerCase();

      return project.title.toLowerCase().contains(search) ||
          project.id.toLowerCase().contains(search) ||
          project.address.toLowerCase().contains(search) ||
          project.company.toLowerCase().contains(search);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No projects found', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: results.map((project) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SearchResultCard(project: project),
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

class _SearchResultCard extends StatelessWidget {
  final Project project;

  const _SearchResultCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${project.id} · ${project.title}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            project.address,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// FILTER BOTTOM SHEET
/// ===============================================================

//

class ProjectFilterBottomSheet extends StatefulWidget {
  const ProjectFilterBottomSheet({super.key, required this.onApply});

  final void Function({
    required List<String> phases,
    required List<String> cities,
    required String priority,
    required String customerCategory,
    required String sortBy,
  })
  onApply;

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

  final List<String> _selectedPhases = [];
  final List<String> _selectedCities = [];

  String _selectedPriority = 'All';
  String _selectedCustomerCategory = 'All';
  String _selectedSortBy = 'Newest';

  @override
  void dispose() {
    _citySearchController.dispose();
    super.dispose();
  }

  List<String> get _filteredCities {
    final query = _citySearchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return _cities;
    }

    return _cities.where((city) => city.toLowerCase().contains(query)).toList();
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

            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 65.w,
                    child: GestureDetector(
                      onTap: _resetAll,
                      child: Text(
                        'Reset All',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFC8102E),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        'Filter projects',
                        style: TextStyle(
                          fontSize: 19.sp,
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
                    // -------------------------
                    // Phase
                    // -------------------------
                    _sectionTitle('Phase'),

                    SizedBox(height: 8.h),

                    ..._phases.map(
                      (phase) => _checkboxRow(
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

                    // -------------------------
                    // City / Location
                    // -------------------------
                    _sectionTitle('City / Location'),

                    SizedBox(height: 8.h),

                    _citySearchField(),

                    SizedBox(height: 6.h),

                    ..._filteredCities.map(
                      (city) => _checkboxRow(
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

                    // -------------------------
                    // Priority
                    // -------------------------
                    _sectionTitle('Priority'),

                    SizedBox(height: 8.h),

                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _filterChip(
                          label: 'All',
                          selected: _selectedPriority == 'All',
                          onTap: () {
                            setState(() {
                              _selectedPriority = 'All';
                            });
                          },
                        ),
                        _filterChip(
                          label: 'High',
                          selected: _selectedPriority == 'High',
                          textColor: const Color(0xFFC8102E),
                          onTap: () {
                            setState(() {
                              _selectedPriority = 'High';
                            });
                          },
                        ),
                        _filterChip(
                          label: 'Medium',
                          selected: _selectedPriority == 'Medium',
                          textColor: const Color(0xFFFF9800),
                          onTap: () {
                            setState(() {
                              _selectedPriority = 'Medium';
                            });
                          },
                        ),
                        _filterChip(
                          label: 'Low',
                          selected: _selectedPriority == 'Low',
                          onTap: () {
                            setState(() {
                              _selectedPriority = 'Low';
                            });
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // -------------------------
                    // Customer Category
                    // -------------------------
                    _sectionTitle('Customer Category'),

                    SizedBox(height: 8.h),

                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _filterChip(
                          label: 'All',
                          selected: _selectedCustomerCategory == 'All',
                          onTap: () {
                            setState(() {
                              _selectedCustomerCategory = 'All';
                            });
                          },
                        ),
                        _filterChip(
                          label: 'Commercial',
                          selected: _selectedCustomerCategory == 'Commercial',
                          onTap: () {
                            setState(() {
                              _selectedCustomerCategory = 'Commercial';
                            });
                          },
                        ),
                        _filterChip(
                          label: 'Private',
                          selected: _selectedCustomerCategory == 'Private',
                          onTap: () {
                            setState(() {
                              _selectedCustomerCategory = 'Private';
                            });
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // -------------------------
                    // Sort By
                    // -------------------------
                    _sectionTitle('Sort by'),

                    SizedBox(height: 8.h),

                    _radioRow(title: 'Newest', value: 'Newest'),

                    _radioRow(
                      title: 'Next inspection date',
                      value: 'Next inspection date',
                    ),

                    _radioRow(
                      title: 'Project name (a-z)',
                      value: 'Project name (a-z)',
                    ),

                    SizedBox(height: 20.h),

                    // -------------------------
                    // Apply button
                    // -------------------------
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8102E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF999999),
      ),
    );
  }

  Widget _checkboxRow({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: SizedBox(
        height: 34.h,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF222222),
                ),
              ),
            ),

            Container(
              width: 17.w,
              height: 17.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC8102E)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFC8102E)
                      : const Color(0xFF111111),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 13.sp, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _citySearchField() {
    return TextField(
      controller: _citySearchController,
      onChanged: (_) => setState(() {}),
      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: 'Search City',
        hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF555555)),
        prefixIcon: Icon(
          Icons.search,
          size: 20.sp,
          color: const Color(0xFF333333),
        ),
        filled: true,
        fillColor: const Color(0xFFF2F8F7),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFC8102E) : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: selected
                ? Colors.white
                : textColor ?? const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _radioRow({required String title, required String value}) {
    final isSelected = _selectedSortBy == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSortBy = value;
        });
      },
      child: SizedBox(
        height: 34.h,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: const Color(0xFF222222),
                ),
              ),
            ),

            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF111111), width: 1.5),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9.w,
                        height: 9.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFC8102E),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
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
}
