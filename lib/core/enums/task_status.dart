import '../localization/app_localization.dart';

enum TaskStatus {
  todo,
  inProgress,
  completed;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return AppLocalization.current.get('status.todo', 'To Do');
      case TaskStatus.inProgress:
        return AppLocalization.current.inProgress;
      case TaskStatus.completed:
        return AppLocalization.current.completed;
    }
  }
}
