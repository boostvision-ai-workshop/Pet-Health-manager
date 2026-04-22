import 'calendar_compare.dart';

/// PRD §7.5：宠物档案表单校验入口。
abstract final class PetProfileRules {
  static List<String> validate({
    required String name,
    required DateTime birthday,
    required DateTime adoptionDate,
    required DateTime today,
  }) {
    final errors = <String>[];
    if (name.trim().isEmpty) {
      errors.add('姓名不能为空');
    }
    if (!isCalendarOnOrBefore(birthday, today)) {
      errors.add('出生日期不能晚于今天');
    }
    if (!isCalendarOnOrBefore(adoptionDate, today)) {
      errors.add('到家日期不能晚于今天');
    }
    return errors;
  }
}
