import '../models/models.dart';

/// 本地持久化仓储（PRD §8.6）：单宠物 + 事件 + 提醒。
abstract class PetRepository {
  Pet? getPet();

  Future<void> savePet(Pet pet);

  List<HealthEvent> getEvents();

  Future<void> saveEvent(HealthEvent event);

  Future<void> deleteEvent(String id);

  List<Reminder> getReminders();

  Future<void> saveReminder(Reminder reminder);

  Future<void> deleteReminder(String id);

  Future<void> deleteRemindersForEvent(String eventId);

  /// 清空本地数据（测试或调试）。
  Future<void> clearAll();
}
