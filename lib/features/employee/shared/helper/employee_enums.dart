import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';

enum EmployeeActivityType { erection, dismantling, others }

extension EmployeeActivityTypeExtension on EmployeeActivityType {
  String get label {
    switch (this) {
      case EmployeeActivityType.erection:
        return AppLocalization.current.erectionPhase;
      case EmployeeActivityType.dismantling:
        return AppLocalization.current.dismantlingPhase;
      case EmployeeActivityType.others:
        return AppLocalization.current.otherActivity;
    }
  }

  Color get color {
    switch (this) {
      case EmployeeActivityType.erection:
        return const Color(0xFF12B76A);
      case EmployeeActivityType.dismantling:
        return const Color(0xFFF79009);
      case EmployeeActivityType.others:
        return const Color(0xFF2E90FA);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case EmployeeActivityType.erection:
        return const Color(0xFFECFDF3);
      case EmployeeActivityType.dismantling:
        return const Color(0xFFFFFAEB);
      case EmployeeActivityType.others:
        return const Color(0xFFEFF8FF);
    }
  }
}
