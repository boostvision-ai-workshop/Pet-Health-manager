import 'package:chongban_health/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HealthEvent', () {
    test('fromJson / toJson roundtrip', () {
      final raw = <String, dynamic>{
        'id': 'evt_001',
        'type': 'weight',
        'dateTime': '2026-04-21T08:45:00.000',
        'value': 4.3,
        'unit': 'kg',
        'note': '状态稳定',
      };

      final e = HealthEvent.fromJson(raw);
      expect(e.type, HealthEventType.weight);
      expect(e.value, 4.3);

      final map = e.toJson();
      final again = HealthEvent.fromJson(map);
      expect(again.type, e.type);
      expect(again.value, e.value);
      expect(again.note, e.note);
    });
  });
}
