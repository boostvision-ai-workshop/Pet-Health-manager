import '../models/models.dart';

/// PRD §8.7：首页健康状态标签。
enum HomeHealthStatus {
  stable,
  pending,
  attention,
}

extension HomeHealthStatusLabel on HomeHealthStatus {
  String get zh {
    switch (this) {
      case HomeHealthStatus.stable:
        return '稳定';
      case HomeHealthStatus.pending:
        return '待处理';
      case HomeHealthStatus.attention:
        return '需关注';
    }
  }
}

abstract final class HomeHealthStatusService {
  /// 仅统计 [status] 为 [ReminderStatus.todo] 的提醒。
  /// 优先级：需关注 > 待处理 > 稳定；其余缺口归为需关注（记录偏旧）。
  static HomeHealthStatus compute({
    required DateTime now,
    required List<HealthEvent> events,
    required List<Reminder> reminders,
  }) {
    final today = DateTime(now.year, now.month, now.day);

    bool hasEventInLastDays(int daysInclusive) {
      final start = today.subtract(Duration(days: daysInclusive - 1));
      for (final e in events) {
        final d = _dateOnly(e.dateTime);
        if (!d.isBefore(start) && !d.isAfter(today)) return true;
      }
      return false;
    }

    final todos = reminders.where((r) => r.status == ReminderStatus.todo).toList();

    bool isOverdue(DateTime due) {
      return _dateOnly(due).isBefore(today);
    }

    bool dueInNextSevenDays(DateTime due) {
      final d = _dateOnly(due);
      final end = today.add(const Duration(days: 7));
      return !d.isBefore(today) && !d.isAfter(end);
    }

    final hasOverdue = todos.any((r) => isOverdue(r.dueDate));
    final noRecord60 = !hasEventInLastDays(60);

    if (hasOverdue || noRecord60) {
      return HomeHealthStatus.attention;
    }

    final upcoming = todos.any((r) => dueInNextSevenDays(r.dueDate));
    if (upcoming) {
      return HomeHealthStatus.pending;
    }

    final record30 = hasEventInLastDays(30);
    if (record30) {
      return HomeHealthStatus.stable;
    }

    return HomeHealthStatus.attention;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
