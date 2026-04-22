import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_theme.dart';
import '../../app/providers.dart';
import '../../models/models.dart';
import '../../services/local_notification_service.dart';
import '../../shared/empty_state.dart';

/// PRD：应用内提醒列表（待处理 / 已完成）。
class RemindersListScreen extends ConsumerStatefulWidget {
  const RemindersListScreen({super.key});

  @override
  ConsumerState<RemindersListScreen> createState() =>
      _RemindersListScreenState();
}

class _RemindersListScreenState extends ConsumerState<RemindersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _toggleDone(Reminder r, bool toDone) async {
    final repo = ref.read(petRepositoryProvider);
    await repo.saveReminder(
      r.copyWith(status: toDone ? ReminderStatus.done : ReminderStatus.todo),
    );
    await LocalNotificationService.syncWithRepository(repo);
    ref.bumpAppData();
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersSnapshotProvider);
    final todo = reminders.where((r) => r.status == ReminderStatus.todo).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final done = reminders.where((r) => r.status == ReminderStatus.done).toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('本地提醒'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: '待处理'),
            Tab(text: '已完成'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ReminderListView(
            items: todo,
            empty: const EmptyState(
              title: '暂无待处理提醒',
              subtitle: '在记录健康事件时可设置「下次提醒」。',
              icon: Icons.notifications_none_outlined,
            ),
            trailingFor: (r) => IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: '标记完成',
              onPressed: () => _toggleDone(r, true),
            ),
          ),
          _ReminderListView(
            items: done,
            empty: const EmptyState(
              title: '暂无已完成提醒',
              subtitle: '完成的提醒会出现在这里。',
              icon: Icons.task_alt_outlined,
            ),
            trailingFor: (r) => TextButton(
              onPressed: () => _toggleDone(r, false),
              child: const Text('恢复待处理'),
            ),
          ),
        ],
      ),
    );
  }
}

typedef ReminderTrailing = Widget Function(Reminder r);

class _ReminderListView extends StatelessWidget {
  const _ReminderListView({
    required this.items,
    required this.empty,
    required this.trailingFor,
  });

  final List<Reminder> items;
  final Widget empty;
  final ReminderTrailing trailingFor;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: empty);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(ChongbanTokens.spacePage),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = items[i];
        return Card(
          child: ListTile(
            title: Text(r.title),
            subtitle: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(r.dueDate),
            ),
            trailing: trailingFor(r),
          ),
        );
      },
    );
  }
}
