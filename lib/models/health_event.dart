import 'health_event_type.dart';

/// PRD §9：健康事件。
class HealthEvent {
  const HealthEvent({
    required this.id,
    required this.type,
    required this.dateTime,
    this.value,
    this.unit,
    this.note,
  });

  final String id;
  final HealthEventType type;
  final DateTime dateTime;
  final double? value;
  final String? unit;
  final String? note;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'dateTime': dateTime.toIso8601String(),
      'value': value,
      'unit': unit,
      'note': note,
    };
  }

  factory HealthEvent.fromJson(Map<String, dynamic> json) {
    return HealthEvent(
      id: json['id'] as String,
      type: HealthEventType.fromJson(json['type'] as String),
      dateTime: DateTime.parse(json['dateTime'] as String),
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      note: json['note'] as String?,
    );
  }

  HealthEvent copyWith({
    String? id,
    HealthEventType? type,
    DateTime? dateTime,
    double? value,
    String? unit,
    String? note,
  }) {
    return HealthEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      note: note ?? this.note,
    );
  }
}
