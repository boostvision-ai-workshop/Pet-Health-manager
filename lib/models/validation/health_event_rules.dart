import '../health_event.dart';
import '../health_event_type.dart';

/// PRD §7.4：健康事件表单校验入口。
abstract final class HealthEventRules {
  static const maxNoteLength = 200;

  static List<String> validateFields({
    required HealthEventType type,
    required double? value,
    required String? note,
  }) {
    final errors = <String>[];
    if (type == HealthEventType.weight) {
      if (value == null) {
        errors.add('体重记录必须填写数值');
      } else if (value <= 0) {
        errors.add('体重数值必须大于 0');
      }
    }
    final text = note ?? '';
    if (text.length > maxNoteLength) {
      errors.add('备注不能超过 $maxNoteLength 字');
    }
    return errors;
  }

  static List<String> validate(HealthEvent event) {
    return validateFields(
      type: event.type,
      value: event.value,
      note: event.note,
    );
  }
}
