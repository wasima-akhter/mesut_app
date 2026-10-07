import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../helper/employee_enums.dart';
import '../../helper/employee_models.dart';

class EmployeePlanState {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<EmployeeCalendarEventModel> events;

  const EmployeePlanState({
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
  });

  EmployeePlanState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    List<EmployeeCalendarEventModel>? events,
  }) {
    return EmployeePlanState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      events: events ?? this.events,
    );
  }

  List<EmployeeCalendarEventModel> get selectedEvents {
    return events.where((event) => isSameDay(event.date, selectedDay)).toList();
  }
}

final employeePlanProvider =
    NotifierProvider<EmployeePlanNotifier, EmployeePlanState>(
  EmployeePlanNotifier.new,
);

class EmployeePlanNotifier extends Notifier<EmployeePlanState> {
  @override
  EmployeePlanState build() {
    final initialDate = DateTime(2026, 9, 18);

    return EmployeePlanState(
      focusedDay: initialDate,
      selectedDay: initialDate,
      events: [
        EmployeeCalendarEventModel(
          date: DateTime(2026, 9, 18),
          project: const EmployeeProjectModel(
            id: 'Prj-0842',
            name: 'Goltsteins.Complex',
            address: 'Goltsteinstraße 12, 50968 Köln',
            activity: EmployeeActivityType.erection,
            startTime: '07:30 am',
            endTime: '04:30 pm',
            siteManager: 'Mesut Rahaman',
          ),
        ),
        EmployeeCalendarEventModel(
          date: DateTime(2026, 9, 19),
          project: const EmployeeProjectModel(
            id: 'Prj-0842',
            name: 'Goltsteins.Complex',
            address: 'Goltsteinstraße 12, 50968 Köln',
            activity: EmployeeActivityType.erection,
            startTime: '07:30 am',
            endTime: '04:30 pm',
            siteManager: 'Mesut Rahaman',
          ),
        ),
      ],
    );
  }

  void selectDay(DateTime selected, DateTime focused) {
    state = state.copyWith(
      selectedDay: selected,
      focusedDay: focused,
    );
  }

  void updateFocusedDay(DateTime focused) {
    state = state.copyWith(focusedDay: focused);
  }
}
