import '../models/health_event_type.dart';

String healthEventTypeLabel(HealthEventType t) {
  switch (t) {
    case HealthEventType.weight:
      return '体重';
    case HealthEventType.deworm:
      return '驱虫';
    case HealthEventType.spayNeuter:
      return '绝育';
    case HealthEventType.vaccine:
      return '疫苗';
    case HealthEventType.physicalNote:
      return '体检笔记';
  }
}
