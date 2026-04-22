import '../models/pet_gender.dart';

String petGenderLabel(PetGender g) {
  switch (g) {
    case PetGender.male:
      return '弟弟';
    case PetGender.female:
      return '妹妹';
    case PetGender.unknown:
      return '未知';
  }
}
