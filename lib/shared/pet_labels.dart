import '../models/pet_gender.dart';

String petGenderLabel(PetGender g) {
  switch (g) {
    case PetGender.male:
      return '公';
    case PetGender.female:
      return '母';
    case PetGender.unknown:
      return '未知';
  }
}
