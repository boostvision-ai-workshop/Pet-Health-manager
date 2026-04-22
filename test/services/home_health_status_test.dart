import 'package:chongban_health/models/models.dart';
import 'package:chongban_health/services/home_health_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeHealthStatusService', () {
    final today = DateTime(2026, 4, 22, 10, 0);

    test('逾期提醒 → 需关注', () {
      final status = HomeHealthStatusService.compute(
        now: today,
        events: [
          HealthEvent(
            id: 'e1',
            type: HealthEventType.weight,
            dateTime: today.subtract(const Duration(days: 5)),
            value: 4.0,
            unit: 'kg',
          ),
        ],
        reminders: [
          Reminder(
            id: 'r1',
            eventId: 'e1',
            title: '驱虫',
            dueDate: DateTime(2026, 4, 15, 9, 0),
            status: ReminderStatus.todo,
          ),
        ],
      );
      expect(status, HomeHealthStatus.attention);
    });

    test('未来 7 天内有待处理提醒 → 待处理', () {
      final status = HomeHealthStatusService.compute(
        now: today,
        events: [
          HealthEvent(
            id: 'e1',
            type: HealthEventType.weight,
            dateTime: today.subtract(const Duration(days: 10)),
            value: 4.0,
            unit: 'kg',
          ),
        ],
        reminders: [
          Reminder(
            id: 'r1',
            eventId: 'e1',
            title: '驱虫',
            dueDate: DateTime(2026, 4, 24, 9, 0),
            status: ReminderStatus.todo,
          ),
        ],
      );
      expect(status, HomeHealthStatus.pending);
    });

    test('30 天内有记录且无近 7 天提醒 → 稳定', () {
      final status = HomeHealthStatusService.compute(
        now: today,
        events: [
          HealthEvent(
            id: 'e1',
            type: HealthEventType.weight,
            dateTime: today.subtract(const Duration(days: 5)),
            value: 4.0,
            unit: 'kg',
          ),
        ],
        reminders: const [],
      );
      expect(status, HomeHealthStatus.stable);
    });

    test('60 天内无任何记录 → 需关注', () {
      final status = HomeHealthStatusService.compute(
        now: today,
        events: [
          HealthEvent(
            id: 'old',
            type: HealthEventType.weight,
            dateTime: DateTime(2026, 1, 1),
            value: 4.0,
            unit: 'kg',
          ),
        ],
        reminders: const [],
      );
      expect(status, HomeHealthStatus.attention);
    });
  });
}
