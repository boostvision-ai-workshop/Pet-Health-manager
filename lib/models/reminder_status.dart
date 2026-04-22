/// PRD §9、§8.5：提醒状态。
enum ReminderStatus {
  todo,
  done;

  static ReminderStatus fromJson(String value) {
    switch (value) {
      case 'todo':
        return ReminderStatus.todo;
      case 'done':
        return ReminderStatus.done;
      default:
        throw FormatException('Unknown ReminderStatus: $value');
    }
  }

  String toJson() => name;
}
