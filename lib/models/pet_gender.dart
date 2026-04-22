/// PRD §7.5：性别 — 弟弟 / 妹妹 / 未知（框线）。
enum PetGender {
  male,
  female,
  unknown;

  static PetGender fromJson(String value) {
    switch (value) {
      case 'male':
        return PetGender.male;
      case 'female':
        return PetGender.female;
      case 'unknown':
        return PetGender.unknown;
      default:
        throw FormatException('Unknown PetGender: $value');
    }
  }

  String toJson() => name;
}
