import 'package:chongban_health/models/models.dart';
import 'package:chongban_health/services/milestone_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pet = Pet(
    id: 'pet_001',
    name: '奶油',
    birthday: DateTime(2024, 2, 12),
    gender: PetGender.female,
    breed: '英短',
    adoptionDate: DateTime(2024, 6, 1),
  );

  test('到家天数与驱虫/疫苗/绝育「待补充」', () {
    final today = DateTime(2026, 4, 22);
    final r = MilestoneService.compute(
      today: today,
      pet: pet,
      events: const [],
    );
    expect(r.daysSinceAdoption, greaterThan(0));
    expect(r.daysSinceDeworm, isNull);
    expect(r.daysSinceVaccine, isNull);
    expect(r.daysSinceSpayNeuter, isNull);
    expect(r.labelOrPending(r.daysSinceDeworm, suffix: '天'), '待补充');
  });

  test('距上次驱虫/疫苗取最近一次事件', () {
    final today = DateTime(2026, 4, 22);
    final events = [
      HealthEvent(
        id: 'a',
        type: HealthEventType.deworm,
        dateTime: DateTime(2026, 4, 10),
        note: 'x',
      ),
      HealthEvent(
        id: 'b',
        type: HealthEventType.deworm,
        dateTime: DateTime(2026, 4, 18),
        note: 'y',
      ),
      HealthEvent(
        id: 'c',
        type: HealthEventType.vaccine,
        dateTime: DateTime(2026, 3, 1),
        note: 'z',
      ),
    ];
    final r = MilestoneService.compute(
      today: today,
      pet: pet,
      events: events,
    );
    expect(r.daysSinceDeworm, 4);
    // 2026-03-01 → 2026-04-22 的自然日差为 52（与 [MilestoneService] 按日历日相减一致）
    expect(r.daysSinceVaccine, 52);
  });
}
