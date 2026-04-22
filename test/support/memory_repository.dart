import 'package:chongban_health/data/pet_repository.dart';
import 'package:chongban_health/models/models.dart';

/// 内存仓储，仅用于 Widget 测试。
class MemoryPetRepository implements PetRepository {
  Pet? _pet;
  final List<HealthEvent> _events = [];
  final List<Reminder> _reminders = [];

  MemoryPetRepository({Pet? pet}) : _pet = pet;

  @override
  Pet? getPet() => _pet;

  @override
  Future<void> savePet(Pet pet) async {
    _pet = pet;
  }

  @override
  List<HealthEvent> getEvents() =>
      List.unmodifiable(_events);

  @override
  Future<void> saveEvent(HealthEvent event) async {
    final i = _events.indexWhere((e) => e.id == event.id);
    if (i >= 0) {
      _events[i] = event;
    } else {
      _events.add(event);
    }
    final pet = _pet;
    if (pet != null && event.type == HealthEventType.weight && event.value != null) {
      _pet = pet.copyWith(latestWeight: event.value);
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await deleteRemindersForEvent(id);
  }

  @override
  List<Reminder> getReminders() => List.unmodifiable(_reminders);

  @override
  Future<void> saveReminder(Reminder reminder) async {
    final i = _reminders.indexWhere((r) => r.id == reminder.id);
    if (i >= 0) {
      _reminders[i] = reminder;
    } else {
      _reminders.add(reminder);
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> deleteRemindersForEvent(String eventId) async {
    _reminders.removeWhere((r) => r.eventId == eventId);
  }

  @override
  Future<void> clearAll() async {
    _pet = null;
    _events.clear();
    _reminders.clear();
  }
}
