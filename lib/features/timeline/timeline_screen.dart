import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_theme.dart';
import '../../app/providers.dart';
import '../../models/models.dart';
import '../../services/local_notification_service.dart';
import '../../shared/empty_state.dart';
import '../../shared/event_type_labels.dart';

enum _TimelineFilter { all, weight, health }

/// PRD §8.3：大事记（默认不含绝育）；筛选；删除时列表刷新 + 动效。
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen>
    with SingleTickerProviderStateMixin {
  _TimelineFilter _filter = _TimelineFilter.all;
  String? _removingId;
  late final AnimationController _removeAnimCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..addStatusListener(_onRemoveStatus);

  void _onRemoveStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final id = _removingId;
    if (id == null) return;
    // 先落库再清状态，避免列表在删除完成前把该行「弹回」满高。
    unawaited(_commitAfterIconDeleteAnimation(id));
  }

  Future<void> _commitAfterIconDeleteAnimation(String id) async {
    try {
      await _commitDeleteId(id);
    } finally {
      if (mounted) {
        setState(() {
          if (_removingId == id) {
            _removingId = null;
          }
        });
      }
      if (_removeAnimCtrl.isAnimating) {
        _removeAnimCtrl.stop();
      }
      _removeAnimCtrl.reset();
    }
  }

  @override
  void dispose() {
    _removeAnimCtrl.removeStatusListener(_onRemoveStatus);
    _removeAnimCtrl.dispose();
    super.dispose();
  }

  bool _includeInDefaultList(HealthEvent e) =>
      e.type != HealthEventType.spayNeuter;

  bool _matchFilter(HealthEvent e) {
    switch (_filter) {
      case _TimelineFilter.all:
        return _includeInDefaultList(e);
      case _TimelineFilter.weight:
        return e.type == HealthEventType.weight;
      case _TimelineFilter.health:
        return e.type.isTimelineHealthCategory;
    }
  }

  List<HealthEvent> _sorted(List<HealthEvent> raw) {
    final list = raw.where(_matchFilter).toList();
    list.sort((a, b) {
      final ad = DateTime(a.dateTime.year, a.dateTime.month, a.dateTime.day);
      final bd = DateTime(b.dateTime.year, b.dateTime.month, b.dateTime.day);
      final dayCmp = bd.compareTo(ad);
      if (dayCmp != 0) return dayCmp;
      return b.dateTime.compareTo(a.dateTime);
    });
    return list;
  }

  Future<bool> _askDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定删除这条记录？关联提醒将一并移除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _markDataChanged() {
    ref.bumpAppData();
    // 与 [appDataRevisionProvider] 一起保证依赖列表的页立即重建
    ref.invalidate(eventsSnapshotProvider);
    ref.invalidate(remindersSnapshotProvider);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _commitDeleteId(String id) async {
    if (!mounted) return;
    final repo = ref.read(petRepositoryProvider);
    try {
      await repo.deleteEvent(id);
      _markDataChanged();
      if (!mounted) return;
      try {
        await LocalNotificationService.syncWithRepository(repo);
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('LocalNotificationService.syncWithRepository: $e\n$st');
        }
      }
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('deleteEvent failed: $e\n$st');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除失败，请重试。')),
        );
      }
    }
  }

  /// 删除图标：先确认，再播收起/淡出，最后写库 + 通知同步。
  Future<void> _onIconDelete(HealthEvent e) async {
    if (!await _askDelete() || !mounted) return;
    if (_removingId != null) return;
    setState(() => _removingId = e.id);
    _removeAnimCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsSnapshotProvider);
    final reminders = ref.watch(remindersSnapshotProvider);
    final visible = _sorted(events);

    return Scaffold(
      appBar: AppBar(title: const Text('大事记')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/events/add'),
        icon: const Icon(Icons.add),
        label: const Text('记录'),
        backgroundColor: ChongbanTokens.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ChongbanTokens.spacePage,
              8,
              ChongbanTokens.spacePage,
              0,
            ),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('全部'),
                  selected: _filter == _TimelineFilter.all,
                  onSelected: (_) =>
                      setState(() => _filter = _TimelineFilter.all),
                ),
                ChoiceChip(
                  label: const Text('体重'),
                  selected: _filter == _TimelineFilter.weight,
                  onSelected: (_) =>
                      setState(() => _filter = _TimelineFilter.weight),
                ),
                ChoiceChip(
                  label: const Text('健康事件'),
                  selected: _filter == _TimelineFilter.health,
                  onSelected: (_) =>
                      setState(() => _filter = _TimelineFilter.health),
                ),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? const EmptyState(
                    title: '还没有大事记',
                    subtitle: '点右下角「记录」添加体重或健康事件吧。',
                    icon: Icons.timeline_outlined,
                  )
                : visible.isEmpty
                    ? EmptyState(
                        title: '没有符合条件的记录',
                        subtitle: _filter == _TimelineFilter.all
                            ? '当前只有绝育记录；绝育默认不在时间线展示。'
                            : '换个筛选试试。',
                        icon: Icons.search_off_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(ChongbanTokens.spacePage),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: ChongbanTokens.spaceCard),
                        itemBuilder: (context, i) {
                          final e = visible[i];
                          final hasRem =
                              reminders.any((r) => r.eventId == e.id);
                          return _buildEventRow(
                            e,
                            hasRem,
                            animating: _removingId == e.id,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow(HealthEvent e, bool hasReminder, {bool animating = false}) {
    Widget card = _TimelineTile(
      event: e,
      hasReminder: hasReminder,
      onDelete: () => unawaited(_onIconDelete(e)),
    );
    if (animating) {
      final a = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(
          parent: _removeAnimCtrl,
          curve: Curves.easeInCubic,
        ),
      );
      card = FadeTransition(
        opacity: a,
        child: SizeTransition(
          sizeFactor: a,
          axis: Axis.vertical,
          axisAlignment: 0,
          child: ClipRect(
            child: card,
          ),
        ),
      );
    }

    return Dismissible(
      key: ValueKey('dismiss_${e.id}'),
      direction: animating
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: _swipeDeleteBackground(context),
      confirmDismiss: animating
          ? (_) async => false
          : (_) => _askDelete(),
      onDismissed: (dir) {
        if (animating) return;
        unawaited(_commitDeleteId(e.id));
      },
      child: card,
    );
  }

  Widget _swipeDeleteBackground(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete_forever, color: Colors.white),
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.event,
    required this.hasReminder,
    required this.onDelete,
  });

  final HealthEvent event;
  final bool hasReminder;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dt = DateFormat('yyyy-MM-dd HH:mm').format(event.dateTime);
    final type = healthEventTypeLabel(event.type);
    final detail = switch (event.type) {
      HealthEventType.weight =>
        '${event.value?.toStringAsFixed(2) ?? '-'} ${event.unit ?? 'kg'}',
      _ => (event.note != null && event.note!.isNotEmpty)
          ? event.note!
          : type,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ChongbanTokens.spaceCard + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            type,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (hasReminder) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.notifications_active_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dt,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ChongbanTokens.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        detail,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  tooltip: '删除',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
