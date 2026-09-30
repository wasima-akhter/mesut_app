/// ===============================================================
/// ENUMS
/// ===============================================================
library;

import 'dart:ui';

enum ProjectPhase { erection, dismantling, standingScaffold, completed }

enum ProjectPriority { high, medium, low }

enum ProjectStatus { inProgress, notStarted, postponed }

enum ProjectTab {
  all,
  active,
  myProjects,
  thisWeek,
  inspection;

  String get label {
    switch (this) {
      case ProjectTab.all:
        return 'All';
      case ProjectTab.active:
        return 'Active';
      case ProjectTab.myProjects:
        return 'My Projects';
      case ProjectTab.thisWeek:
        return 'This Week';
      case ProjectTab.inspection:
        return 'Inspection';
    }
  }
}

/// Tabs are also represented by an enum.
enum ProjectDetailsTab {
  overview,
  tasks,
  photos,
  measurement,
  dates,
  notes,
  history,
}

enum TaskStatusTab {
  open,
  completed;

  String get label {
    switch (this) {
      case TaskStatusTab.open:
        return 'Open';
      case TaskStatusTab.completed:
        return 'Completed';
    }
  }
}

enum ProjectNoteCategory {
  siteAccess,
  customerRequest,
  openPoints,
  agreements,
  specialRequirements,
  localContact,
  general,
}

// ============================================================
// ENUM EXTENSIONS
// ============================================================

extension ProjectNoteCategoryExtension on ProjectNoteCategory {
  String get label {
    switch (this) {
      case ProjectNoteCategory.siteAccess:
        return 'Site Access';
      case ProjectNoteCategory.customerRequest:
        return 'Customer Request';
      case ProjectNoteCategory.openPoints:
        return 'Open Points';
      case ProjectNoteCategory.agreements:
        return 'Agreements';
      case ProjectNoteCategory.specialRequirements:
        return 'Special Requirements';
      case ProjectNoteCategory.localContact:
        return 'Local Contact';
      case ProjectNoteCategory.general:
        return 'General';
    }
  }
}

extension ProjectPhaseExtension on ProjectPhase {
  String get label {
    switch (this) {
      case ProjectPhase.erection:
        return 'Erection';

      case ProjectPhase.dismantling:
        return 'Dismantling';

      case ProjectPhase.standingScaffold:
        return 'Standing Scaffold';

      case ProjectPhase.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case ProjectPhase.erection:
        return const Color(0xFF00A651);

      case ProjectPhase.dismantling:
        return const Color(0xFFFF7A00);

      case ProjectPhase.standingScaffold:
        return const Color(0xFF1976D2);

      case ProjectPhase.completed:
        return const Color(0xFF8A9AA8);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ProjectPhase.erection:
        return const Color(0xFFE9F8EF);

      case ProjectPhase.dismantling:
        return const Color(0xFFFFF2E8);

      case ProjectPhase.standingScaffold:
        return const Color(0xFFEAF3FF);

      case ProjectPhase.completed:
        return const Color(0xFFF0F2F4);
    }
  }
}

extension ProjectPriorityExtension on ProjectPriority {
  String get label {
    switch (this) {
      case ProjectPriority.high:
        return 'High';

      case ProjectPriority.medium:
        return 'Medium';

      case ProjectPriority.low:
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case ProjectPriority.high:
        return const Color(0xFFFF4757);

      case ProjectPriority.medium:
        return const Color(0xFFFFA000);

      case ProjectPriority.low:
        return const Color(0xFF42A5F5);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ProjectPriority.high:
        return const Color(0xFFFFE9EB);

      case ProjectPriority.medium:
        return const Color(0xFFFFF4DE);

      case ProjectPriority.low:
        return const Color(0xFFEAF5FF);
    }
  }
}

extension ProjectStatusExtension on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.inProgress:
        return 'In Progress';

      case ProjectStatus.notStarted:
        return 'Not Started';

      case ProjectStatus.postponed:
        return 'Postponed';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.inProgress:
        return const Color(0xFF00A651);

      case ProjectStatus.notStarted:
        return const Color(0xFFFF9800);

      case ProjectStatus.postponed:
        return const Color(0xFFE53935);
    }
  }
}
//

extension ProjectDetailsTabX on ProjectDetailsTab {
  String get label {
    switch (this) {
      case ProjectDetailsTab.overview:
        return 'Overview';
      case ProjectDetailsTab.tasks:
        return 'Tasks';
      case ProjectDetailsTab.photos:
        return 'Photos';
      case ProjectDetailsTab.measurement:
        return 'Measurement';
      case ProjectDetailsTab.dates:
        return 'Dates';
      case ProjectDetailsTab.notes:
        return 'Notes';
      case ProjectDetailsTab.history:
        return 'History';
    }
  }
}
