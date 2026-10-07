/// ===============================================================
/// ENUMS
/// ===============================================================
library;

import 'dart:ui';
import '../../../core/localization/app_localization.dart';

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
        return AppLocalization.current.projectFilterAll;
      case ProjectTab.active:
        return AppLocalization.current.projectFilterActive;
      case ProjectTab.myProjects:
        return AppLocalization.current.projectFilterMyProjects;
      case ProjectTab.thisWeek:
        return AppLocalization.current.projectFilterThisWeek;
      case ProjectTab.inspection:
        return AppLocalization.current.projectFilterInspection;
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
        return AppLocalization.current.open;
      case TaskStatusTab.completed:
        return AppLocalization.current.completed;
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
        return AppLocalization.current.siteAccess;
      case ProjectNoteCategory.customerRequest:
        return AppLocalization.current.customerRequest;
      case ProjectNoteCategory.openPoints:
        return AppLocalization.current.openPoints;
      case ProjectNoteCategory.agreements:
        return AppLocalization.current.agreements;
      case ProjectNoteCategory.specialRequirements:
        return AppLocalization.current.specialRequirements;
      case ProjectNoteCategory.localContact:
        return AppLocalization.current.localContact;
      case ProjectNoteCategory.general:
        return AppLocalization.current.general;
    }
  }
}

extension ProjectPhaseExtension on ProjectPhase {
  String get label {
    switch (this) {
      case ProjectPhase.erection:
        return AppLocalization.current.erectionPhase;

      case ProjectPhase.dismantling:
        return AppLocalization.current.dismantlingPhase;

      case ProjectPhase.standingScaffold:
        return AppLocalization.current.standingScaffold;

      case ProjectPhase.completed:
        return AppLocalization.current.completed;
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
        return AppLocalization.current.high;

      case ProjectPriority.medium:
        return AppLocalization.current.medium;

      case ProjectPriority.low:
        return AppLocalization.current.low;
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
        return AppLocalization.current.inProgress;

      case ProjectStatus.notStarted:
        return AppLocalization.current.notStarted;

      case ProjectStatus.postponed:
        return AppLocalization.current.postponed;
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

extension ProjectDetailsTabX on ProjectDetailsTab {
  String get label {
    switch (this) {
      case ProjectDetailsTab.overview:
        return AppLocalization.current.smOverview;
      case ProjectDetailsTab.tasks:
        return AppLocalization.current.smTasks;
      case ProjectDetailsTab.photos:
        return AppLocalization.current.smPhotos;
      case ProjectDetailsTab.measurement:
        return AppLocalization.current.smMeasurement;
      case ProjectDetailsTab.dates:
        return AppLocalization.current.smDates;
      case ProjectDetailsTab.notes:
        return AppLocalization.current.smNotes;
      case ProjectDetailsTab.history:
        return AppLocalization.current.smHistory;
    }
  }
}
