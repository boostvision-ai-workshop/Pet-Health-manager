import 'package:chongban_health/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pet', () {
    test('fromJson / toJson roundtrip (PRD §9 sample)', () {
      const raw = <String, dynamic>{
        'id': 'pet_001',
        'name': '奶油',
        'birthday': '2024-02-12',
        'gender': 'female',
        'breed': '英短',
        'adoptionDate': '2024-06-01',
        'avatar': '',
        'latestWeight': 4.3,
      };

      final pet = Pet.fromJson(raw);
      expect(pet.name, '奶油');
      expect(pet.gender, PetGender.female);
      expect(pet.latestWeight, 4.3);

      final again = Pet.fromJson(pet.toJson());
      expect(again.toJson(), pet.toJson());
    });
  });
}
