import 'dart:io';

import 'package:chongban_health/data/pet_repository_hive.dart';
import 'package:chongban_health/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('chongban_hive_');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await PetRepositoryHive.disposeForTesting();
    try {
      await Hive.deleteBoxFromDisk('chongban_health_v1');
    } catch (_) {}
  });

  tearDownAll(() async {
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  });

  test('写入宠物与事件后读取一致；删事件级联提醒', () async {
    final repo = await PetRepositoryHive.open();

    final pet = Pet(
      id: 'pet_001',
      name: '奶油',
      birthday: DateTime(2024, 2, 12),
      gender: PetGender.female,
      breed: '英短',
      adoptionDate: DateTime(2024, 6, 1),
      latestWeight: 4.0,
    );
    await repo.savePet(pet);
    expect(repo.getPet()?.name, '奶油');

    final evt = HealthEvent(
      id: 'evt_1',
      type: HealthEventType.deworm,
      dateTime: DateTime(2026, 4, 18),
      note: '体内驱虫',
    );
    await repo.saveEvent(evt);

    final rem = Reminder(
      id: 'rem_1',
      eventId: 'evt_1',
      title: '下次驱虫',
      dueDate: DateTime(2026, 5, 1),
      status: ReminderStatus.todo,
    );
    await repo.saveReminder(rem);

    expect(repo.getEvents().length, 1);
    expect(repo.getReminders().length, 1);

    await repo.deleteEvent('evt_1');
    expect(repo.getEvents(), isEmpty);
    expect(repo.getReminders(), isEmpty);
  });

  test('更新提醒状态可持久化', () async {
    final repo = await PetRepositoryHive.open();
    await repo.clearAll();

    final pet = Pet(
      id: 'pet_001',
      name: '奶油',
      birthday: DateTime(2024, 2, 12),
      gender: PetGender.female,
      breed: '英短',
      adoptionDate: DateTime(2024, 6, 1),
    );
    await repo.savePet(pet);

    final rem = Reminder(
      id: 'rem_1',
      eventId: 'evt_x',
      title: '提醒',
      dueDate: DateTime(2026, 5, 1),
      status: ReminderStatus.todo,
    );
    await repo.saveReminder(rem);

    await repo.saveReminder(rem.copyWith(status: ReminderStatus.done));
    expect(repo.getReminders().single.status, ReminderStatus.done);
  });
}
