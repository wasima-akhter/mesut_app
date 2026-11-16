import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../enums.dart';

class ProjectTabsBar extends StatelessWidget {
  const ProjectTabsBar({
    super.key,
    required this.selectedTab,
    required this.onSelectTab,
  });

  final ProjectTab selectedTab;
  final ValueChanged<ProjectTab> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(ProjectTab.values.length, (index) {
            final tab = ProjectTab.values[index];
            final bool selected = selectedTab == tab;

            return Padding(
              padding: EdgeInsets.only(
                right: index == ProjectTab.values.length - 1 ? 0 : 7,
              ),
              child: GestureDetector(
                onTap: () => onSelectTab(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFC8102E)
                        : const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : const Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
