import 'package:flutter/material.dart';
import '../project_dates/presentation/widgets/project_dates_tab_view.dart';

export '../project_dates/presentation/widgets/project_dates_tab_view.dart';

class DatesTab extends StatelessWidget {
  final String projectId;

  const DatesTab({super.key, this.projectId = ''});

  @override
  Widget build(BuildContext context) {
    return ProjectDatesTabView(projectId: projectId);
  }
}
