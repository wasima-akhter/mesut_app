import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inspection_pages/site_manager_inspections_page.dart';

class SiteInspectionState {
  final InspectionStatus selectedStatus;
  final List<SiteInspectionModel> inspections;
  final DateTime selectedCalendarDate;
  final DateTime focusedCalendarDate;
  final List<CalendarEventModel> calendarEvents;

  SiteInspectionState({
    this.selectedStatus = InspectionStatus.pending,
    this.inspections = const [
      SiteInspectionModel(
        projectId: 'PRJ-0842',
        projectName: 'Goldsteins.Complex',
        company: 'HochTief AG',
        type: 'Commercial',
        address: 'Goldsteinstraße 12, 50968 Köln',
        inspector: 'Mesut Yilmaz (you)',
        appointment: 'Today, 10:30 am',
        status: InspectionStatus.pending,
      ),
      SiteInspectionModel(
        projectId: 'PRJ-0843',
        projectName: 'Goldsteins.Complex',
        company: 'HochTief AG',
        type: 'Commercial',
        address: 'Goldsteinstraße 12, 50968 Köln',
        inspector: 'Mesut Yilmaz (you)',
        appointment: 'Today, 10:30 am',
        status: InspectionStatus.pending,
      ),
      SiteInspectionModel(
        projectId: 'PRJ-0844',
        projectName: 'Goldsteins.Complex',
        company: 'HochTief AG',
        type: 'Commercial',
        address: 'Goldsteinstraße 12, 50968 Köln',
        inspector: 'Mesut Yilmaz (you)',
        appointment: 'Today, 10:30 am',
        status: InspectionStatus.pending,
      ),
      SiteInspectionModel(
        projectId: 'PRJ-0845',
        projectName: 'Goldsteins.Complex',
        company: 'HochTief AG',
        type: 'Commercial',
        address: 'Goldsteinstraße 12, 50968 Köln',
        inspector: 'Mesut Yilmaz (you)',
        appointment: '18 Sep 2026',
        status: InspectionStatus.completed,
      ),
    ],
    DateTime? selectedCalendarDate,
    DateTime? focusedCalendarDate,
    this.calendarEvents = const [
      CalendarEventModel(
        projectId: 'PRJ-0842',
        title: 'Goldsteins.Complex',
        address: 'Goldsteinstraße 12, 50968 Köln',
        type: 'Erection',
        dateRange: 'Sept 18 – Sept 20 (2.5 days)',
        time: '7:30–4:30',
        assignee: 'Mesut Yilmaz (you)',
        color: Colors.green,
      ),
      CalendarEventModel(
        projectId: 'PRJ-0842',
        title: 'Goldsteins.Complex',
        address: 'Goldsteinstraße 12, 50968 Köln',
        type: 'Dismantling',
        dateRange: 'Sept 18 – Sept 20 (2.5 days)',
        time: '7:30–4:30',
        assignee: 'Mesut Yilmaz (you)',
        color: Colors.orange,
      ),
    ],
  })  : selectedCalendarDate =
            selectedCalendarDate ?? DateTime(2026, 9, 18),
        focusedCalendarDate =
            focusedCalendarDate ?? DateTime(2026, 9, 18);

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
      selectedCalendarDate:
          selectedCalendarDate ?? this.selectedCalendarDate,
      focusedCalendarDate:
          focusedCalendarDate ?? this.focusedCalendarDate,
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
