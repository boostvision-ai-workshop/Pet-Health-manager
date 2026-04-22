import 'pet_gender.dart';

/// PRD §9：单宠物档案。
///
/// [latestWeight] 为首页展示方便的**反规范化缓存**，权威数据仍来自 `weight` 事件；
/// 也可在运行时由体重事件推导，本项目在模型层同时保留字段便于本地 JSON 对齐 PRD。
class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.birthday,
    required this.gender,
    required this.breed,
    required this.adoptionDate,
    this.avatar = '',
    this.latestWeight,
    this.initialWeight,
  });

  final String id;
  final String name;
  final DateTime birthday;
  final PetGender gender;
  final String breed;
  final DateTime adoptionDate;
  final String avatar;
  final double? latestWeight;
  final double? initialWeight;

  Pet copyWith({
    String? id,
    String? name,
    DateTime? birthday,
    PetGender? gender,
    String? breed,
    DateTime? adoptionDate,
    String? avatar,
    double? latestWeight,
    double? initialWeight,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      breed: breed ?? this.breed,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      avatar: avatar ?? this.avatar,
      latestWeight: latestWeight ?? this.latestWeight,
      initialWeight: initialWeight ?? this.initialWeight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthday': _formatDateOnly(birthday),
      'gender': gender.toJson(),
      'breed': breed,
      'adoptionDate': _formatDateOnly(adoptionDate),
      'avatar': avatar,
      if (latestWeight != null) 'latestWeight': latestWeight,
      if (initialWeight != null) 'initialWeight': initialWeight,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      birthday: _parseDateOnly(json['birthday'] as String),
      gender: PetGender.fromJson(json['gender'] as String),
      breed: json['breed'] as String,
      adoptionDate: _parseDateOnly(json['adoptionDate'] as String),
      avatar: json['avatar'] as String? ?? '',
      latestWeight: (json['latestWeight'] as num?)?.toDouble(),
      initialWeight: (json['initialWeight'] as num?)?.toDouble(),
    );
  }

  static String _formatDateOnly(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// 支持 `YYYY-MM-DD` 或与 [DateTime.parse] 兼容的字符串。
  static DateTime _parseDateOnly(String s) {
    final isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final m = isoDate.firstMatch(s);
    if (m != null) {
      return DateTime(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      );
    }
    return DateTime.parse(s);
  }
}
