import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/pet_repository.dart';
import '../models/models.dart';

/// PRD §8.5：应用内列表 + Android 本地通知调度。
abstract final class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    _initialized = true;
  }

  static int _nid(String reminderId) => reminderId.hashCode & 0x7FFFFFFF;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'chongban_reminders',
    '健康提醒',
    channelDescription: '宠物健康记录的到期提醒',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  static Future<void> scheduleReminderIfNeeded(Reminder r) async {
    await cancelReminder(r.id);
    if (r.status != ReminderStatus.todo) return;

    final now = DateTime.now();
    if (!r.dueDate.isAfter(now.subtract(const Duration(seconds: 1)))) {
      return;
    }

    final scheduled = tz.TZDateTime.from(r.dueDate, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;

    await _zonedScheduleWithPermissionFallback(
      id: _nid(r.id),
      title: r.title,
      body: '打开宠伴健康查看详情',
      scheduled: scheduled,
    );
  }

  /// 无「闹钟和提醒」/精确闹钟权限时，回退为 inexact，避免整段启动在 [main] 中失败。
  static Future<void> _zonedScheduleWithPermissionFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduled,
  }) async {
    const details = NotificationDetails(android: _androidDetails);
    const interpret =
        UILocalNotificationDateInterpretation.absoluteTime;
    const modes = <AndroidScheduleMode>[
      AndroidScheduleMode.exactAllowWhileIdle,
      AndroidScheduleMode.exact,
      AndroidScheduleMode.inexact,
    ];
    Object? lastError;
    for (final mode in modes) {
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          details,
          androidScheduleMode: mode,
          uiLocalNotificationDateInterpretation: interpret,
        );
        return;
      } on PlatformException catch (e) {
        if (e.code == 'exact_alarms_not_permitted') {
          lastError = e;
          continue;
        }
        rethrow;
      }
    }
    Error.throwWithStackTrace(
      lastError ?? StateError('zonedSchedule failed'),
      StackTrace.current,
    );
  }

  static Future<void> cancelReminder(String reminderId) async {
    await _plugin.cancel(_nid(reminderId));
  }

  /// 与仓储对齐：重建所有未来待处理提醒的系统通知。
  static Future<void> syncWithRepository(PetRepository repo) async {
    for (final r in repo.getReminders()) {
      await cancelReminder(r.id);
    }
    for (final r in repo.getReminders()) {
      await scheduleReminderIfNeeded(r);
    }
  }
}
