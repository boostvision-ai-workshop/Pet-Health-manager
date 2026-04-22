import 'package:chongban_health/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Reminder', () {
    test('fromJson / toJson roundtrip', () {
      final raw = <String, dynamic>{
        'id': 'rem_001',
        'eventId': 'evt_002',
        'title': '下次驱虫提醒',
        'dueDate': '2026-05-18T09:00:00.000',
        'status': 'todo',
      };

      final r = Reminder.fromJson(raw);
      expect(r.status, ReminderStatus.todo);

      final again = Reminder.fromJson(r.toJson());
      expect(again.eventId, r.eventId);
      expect(again.dueDate.toIso8601String(), r.dueDate.toIso8601String());
    });
  });
}
