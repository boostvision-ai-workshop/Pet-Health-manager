import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../app/providers.dart';
import '../../../models/models.dart';
import '../../../services/local_notification_service.dart';

class RemindersStrip extends ConsumerWidget {
  const RemindersStrip({super.key, required this.reminders});

  final List<Reminder> reminders;

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = reminders
        .where((r) => r.status == ReminderStatus.todo)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final top = todos.take(3).toList();
    if (top.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(ChongbanTokens.spaceCard + 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '近期提醒',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '暂无待处理提醒',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final today = _dateOnly(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ChongbanTokens.spaceCard + 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '近期提醒',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/reminders'),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...top.map((r) => _ReminderTile(reminder: r, today: today)),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({
    required this.reminder,
    required this.today,
  });

  final Reminder reminder;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDay = DateTime(
      reminder.dueDate.year,
      reminder.dueDate.month,
      reminder.dueDate.day,
    );
    final overdue = dueDay.isBefore(today);
    final subtitle = overdue
        ? '逾期 · ${DateFormat('MM-dd HH:mm').format(reminder.dueDate)}'
        : '将于 ${DateFormat('MM-dd HH:mm').format(reminder.dueDate)}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(reminder.title),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: '标记完成',
        icon: const Icon(Icons.check_circle_outline),
        onPressed: () async {
          final repo = ref.read(petRepositoryProvider);
          await repo.saveReminder(
            reminder.copyWith(status: ReminderStatus.done),
          );
          await LocalNotificationService.cancelReminder(reminder.id);
          ref.bumpAppData();
        },
      ),
    );
  }
}
