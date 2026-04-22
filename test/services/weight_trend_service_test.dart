import 'package:chongban_health/models/models.dart';
import 'package:chongban_health/services/weight_trend_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 4, 22);

  test('空分支', () {
    final s = WeightTrendService.build(today: today, events: const []);
    expect(s.branch, WeightTrendBranch.empty);
    expect(s.points, isEmpty);
  });

  test('一年窗口内早先与最近均纳入', () {
    final events = [
      HealthEvent(
        id: 'old',
        type: HealthEventType.weight,
        dateTime: DateTime(2026, 3, 1),
        value: 3.0,
        unit: 'kg',
      ),
      HealthEvent(
        id: 'new',
        type: HealthEventType.weight,
        dateTime: DateTime(2026, 4, 20),
        value: 4.0,
        unit: 'kg',
      ),
    ];
    final s = WeightTrendService.build(today: today, events: events);
    expect(s.branch, WeightTrendBranch.multi);
    expect(s.points.length, 2);
    expect(s.points.first.$2, 3.0);
    expect(s.points.last.$2, 4.0);
  });

  test('一年以前体重不计入', () {
    final events = [
      HealthEvent(
        id: 'tooOld',
        type: HealthEventType.weight,
        dateTime: DateTime(2024, 1, 1),
        value: 2.0,
        unit: 'kg',
      ),
      HealthEvent(
        id: 'b',
        type: HealthEventType.weight,
        dateTime: DateTime(2026, 4, 20),
        value: 4.0,
        unit: 'kg',
      ),
    ];
    final s = WeightTrendService.build(today: today, events: events);
    expect(s.branch, WeightTrendBranch.single);
    expect(s.points.length, 1);
    expect(s.points.first.$2, 4.0);
  });

  test('≥2 条 → multi', () {
    final events = [
      HealthEvent(
        id: 'a',
        type: HealthEventType.weight,
        dateTime: DateTime(2026, 4, 10),
        value: 3.9,
        unit: 'kg',
      ),
      HealthEvent(
        id: 'b',
        type: HealthEventType.weight,
        dateTime: DateTime(2026, 4, 20),
        value: 4.1,
        unit: 'kg',
      ),
    ];
    final s = WeightTrendService.build(today: today, events: events);
    expect(s.branch, WeightTrendBranch.multi);
    expect(s.points.length, 2);
  });
}
