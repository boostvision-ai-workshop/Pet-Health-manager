import 'reminder_status.dart';

/// PRD §9：与事件关联的本地提醒。
class Reminder {
  const Reminder({
    required this.id,
    required this.eventId,
    required this.title,
    required this.dueDate,
    required this.status,
  });

  final String id;
  final String eventId;
  final String title;
  final DateTime dueDate;
  final ReminderStatus status;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'status': status.toJson(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: ReminderStatus.fromJson(json['status'] as String),
    );
  }

  Reminder copyWith({
    String? id,
    String? eventId,
    String? title,
    DateTime? dueDate,
    ReminderStatus? status,
  }) {
    return Reminder(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }
}
