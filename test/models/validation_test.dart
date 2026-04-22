import 'package:chongban_health/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 4, 22);

  group('PetProfileRules', () {
    test('rejects empty name and future calendar dates', () {
      final a = PetProfileRules.validate(
        name: '  ',
        birthday: DateTime(2026, 4, 23),
        adoptionDate: DateTime(2026, 1, 1),
        today: today,
      );
      expect(a.length, greaterThanOrEqualTo(2));
      expect(a.any((e) => e.contains('姓名')), isTrue);
      expect(a.any((e) => e.contains('出生')), isTrue);

      final b = PetProfileRules.validate(
        name: '奶油',
        birthday: DateTime(2024, 2, 12),
        adoptionDate: DateTime(2026, 5, 1),
        today: today,
      );
      expect(b.any((e) => e.contains('到家')), isTrue);
    });

    test('accepts valid profile', () {
      final ok = PetProfileRules.validate(
        name: '奶油',
        birthday: DateTime(2024, 2, 12),
        adoptionDate: DateTime(2024, 6, 1),
        today: today,
      );
      expect(ok, isEmpty);
    });
  });

  group('HealthEventRules', () {
    test('weight requires positive value', () {
      final e = HealthEvent(
        id: 'x',
        type: HealthEventType.weight,
        dateTime: today,
        value: null,
        unit: 'kg',
        note: null,
      );
      expect(HealthEventRules.validate(e), isNotEmpty);

      final ok = HealthEvent(
        id: 'x',
        type: HealthEventType.weight,
        dateTime: today,
        value: 4.2,
        unit: 'kg',
        note: null,
      );
      expect(HealthEventRules.validate(ok), isEmpty);
    });

    test('note length', () {
      final longNote = List.filled(201, 'a').join();
      final e = HealthEvent(
        id: 'x',
        type: HealthEventType.deworm,
        dateTime: today,
        note: longNote,
      );
      expect(HealthEventRules.validate(e), isNotEmpty);
    });
  });

  group('isCalendarOnOrBefore', () {
    test('compares date only', () {
      expect(isCalendarOnOrBefore(DateTime(2026, 4, 22, 23, 59), today), isTrue);
      expect(isCalendarOnOrBefore(DateTime(2026, 4, 23), today), isFalse);
    });
  });
}
