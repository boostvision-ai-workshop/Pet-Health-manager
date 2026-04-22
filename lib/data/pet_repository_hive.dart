import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import 'pet_repository.dart';

/// JSON 字符串存 Hive（与 PRD 示例 JSON 对齐，避免手写 TypeAdapter）。
class PetRepositoryHive implements PetRepository {
  PetRepositoryHive._(this._box);

  static const _boxName = 'chongban_health_v1';
  static const _keyPet = 'pet';
  static const _keyEvents = 'events';
  static const _keyReminders = 'reminders';

  static PetRepositoryHive? _instance;

  final Box<String> _box;

  static Future<PetRepositoryHive> open() async {
    if (_instance != null) return _instance!;
    final box = await Hive.openBox<String>(_boxName);
    _instance = PetRepositoryHive._(box);
    return _instance!;
  }

  /// 单测清理：关闭 Box 并释放单例，便于下次 [open] 使用新存储路径。
  static Future<void> disposeForTesting() async {
    final i = _instance;
    _instance = null;
    if (i != null) {
      try {
        await i._box.close();
      } catch (_) {}
    }
  }

  /// 测试或特殊场景直接绑定已打开的 Box。
  static PetRepositoryHive bind(Box<String> box) => PetRepositoryHive._(box);

  @override
  Pet? getPet() {
    final raw = _box.get(_keyPet);
    if (raw == null || raw.isEmpty) return null;
    return Pet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> savePet(Pet pet) async {
    await _box.put(_keyPet, jsonEncode(pet.toJson()));
  }

  List<Map<String, dynamic>> _decodeList(String key) {
    final raw = _box.get(key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _encodeList(String key, List<Map<String, dynamic>> items) async {
    await _box.put(key, jsonEncode(items));
  }

  @override
  List<HealthEvent> getEvents() {
    return _decodeList(_keyEvents)
        .map(HealthEvent.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> saveEvent(HealthEvent event) async {
    final items = _decodeList(_keyEvents);
    final i = items.indexWhere((e) => e['id'] == event.id);
    final map = event.toJson();
    if (i >= 0) {
      items[i] = map;
    } else {
      items.add(map);
    }
    await _encodeList(_keyEvents, items);

    final pet = getPet();
    if (pet != null && event.type == HealthEventType.weight && event.value != null) {
      await savePet(pet.copyWith(latestWeight: event.value));
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    final items = _decodeList(_keyEvents).where((e) => e['id'] != id).toList();
    await _encodeList(_keyEvents, items);
    await deleteRemindersForEvent(id);
  }

  @override
  List<Reminder> getReminders() {
    return _decodeList(_keyReminders)
        .map(Reminder.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> saveReminder(Reminder reminder) async {
    final items = _decodeList(_keyReminders);
    final i = items.indexWhere((e) => e['id'] == reminder.id);
    final map = reminder.toJson();
    if (i >= 0) {
      items[i] = map;
    } else {
      items.add(map);
    }
    await _encodeList(_keyReminders, items);
  }

  @override
  Future<void> deleteReminder(String id) async {
    final items = _decodeList(_keyReminders).where((e) => e['id'] != id).toList();
    await _encodeList(_keyReminders, items);
  }

  @override
  Future<void> deleteRemindersForEvent(String eventId) async {
    final items =
        _decodeList(_keyReminders).where((e) => e['eventId'] != eventId).toList();
    await _encodeList(_keyReminders, items);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }
}
