import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';

class ProjectHeader extends StatelessWidget {
  const ProjectHeader({
    super.key,
    required this.onOpenSearch,
    required this.onOpenFilters,
  });

  final VoidCallback onOpenSearch;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.loc.projects,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF151515),
            ),
          ),
        ),
        _HeaderButton(
          icon: Icons.search,
          onTap: onOpenSearch,
        ),
        const SizedBox(width: 8),
        _HeaderButton(
          icon: Icons.tune,
          onTap: onOpenFilters,
        ),
      ],
    );
  }
}

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
