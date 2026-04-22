/// PRD §2.3、§9：核心健康事件类型。
enum HealthEventType {
  weight,
  deworm,
  spayNeuter,
  vaccine,
  physicalNote;

  static HealthEventType fromJson(String value) {
    switch (value) {
      case 'weight':
        return HealthEventType.weight;
      case 'deworm':
        return HealthEventType.deworm;
      case 'spayNeuter':
        return HealthEventType.spayNeuter;
      case 'vaccine':
        return HealthEventType.vaccine;
      case 'physicalNote':
        return HealthEventType.physicalNote;
      default:
        throw FormatException('Unknown HealthEventType: $value');
    }
  }

  String toJson() => name;

  /// 大事记筛选「健康事件」：驱虫、疫苗、体检笔记（不含绝育默认列表逻辑在 UI 层）。
  bool get isTimelineHealthCategory {
    switch (this) {
      case HealthEventType.deworm:
      case HealthEventType.vaccine:
      case HealthEventType.physicalNote:
        return true;
      default:
        return false;
    }
  }
}
