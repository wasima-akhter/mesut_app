import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../site_manager_inspections_page.dart';

class SiteInspectionState {
  final InspectionStatus selectedStatus;
  final List<SiteInspectionModel> inspections;
  final DateTime selectedCalendarDate;
  final DateTime focusedCalendarDate;
  final List<CalendarEventModel> calendarEvents;

  SiteInspectionState({
    this.selectedStatus = InspectionStatus.pending,
    this.inspections = const [],
    DateTime? selectedCalendarDate,
    DateTime? focusedCalendarDate,
    this.calendarEvents = const [],
  }) : selectedCalendarDate = selectedCalendarDate ?? DateTime.now(),
       focusedCalendarDate = focusedCalendarDate ?? DateTime.now();

  List<SiteInspectionModel> get filteredInspections {
    return inspections.where((i) => i.status == selectedStatus).toList();
  }

  SiteInspectionState copyWith({
    InspectionStatus? selectedStatus,
    List<SiteInspectionModel>? inspections,
    DateTime? selectedCalendarDate,
    DateTime? focusedCalendarDate,
    List<CalendarEventModel>? calendarEvents,
  }) {
    return SiteInspectionState(
      selectedStatus: selectedStatus ?? this.selectedStatus,
      inspections: inspections ?? this.inspections,
      selectedCalendarDate: selectedCalendarDate ?? this.selectedCalendarDate,
      focusedCalendarDate: focusedCalendarDate ?? this.focusedCalendarDate,
      calendarEvents: calendarEvents ?? this.calendarEvents,
    );
  }
}

class SiteInspectionNotifier extends Notifier<SiteInspectionState> {
  @override
  SiteInspectionState build() {
    return SiteInspectionState();
  }

  void setStatus(InspectionStatus status) {
    state = state.copyWith(selectedStatus: status);
  }

  void setCalendarDates({
    required DateTime selectedDay,
    required DateTime focusedDay,
  }) {
    state = state.copyWith(
      selectedCalendarDate: selectedDay,
      focusedCalendarDate: focusedDay,
    );
  }
}

final siteInspectionProvider =
    NotifierProvider<SiteInspectionNotifier, SiteInspectionState>(
      SiteInspectionNotifier.new,
    );
