import '../models/models.dart';

/// PRD §8.4：里程碑文案与天数（纯函数；[today] 可注入便于测试）。
class MilestoneResult {
  const MilestoneResult({
    required this.daysSinceAdoption,
    required this.daysSinceDeworm,
    required this.daysSinceVaccine,
    required this.daysSinceSpayNeuter,
  });

  final int daysSinceAdoption;
  final int? daysSinceDeworm;
  final int? daysSinceVaccine;
  final int? daysSinceSpayNeuter;

  String labelOrPending(int? days, {required String suffix}) {
    if (days == null) return '待补充';
    return '$days$suffix';
  }
}

abstract final class MilestoneService {
  /// [today] 取日历日（时分秒忽略）。
  static MilestoneResult compute({
    required DateTime today,
    required Pet pet,
    required List<HealthEvent> events,
  }) {
    final adoption = _dateOnly(pet.adoptionDate);
    final t = _dateOnly(today);
    final adoptionDays = t.difference(adoption).inDays;

    DateTime? latestOf(HealthEventType type) {
      HealthEvent? best;
      for (final e in events) {
        if (e.type != type) continue;
        if (best == null || e.dateTime.isAfter(best.dateTime)) {
          best = e;
        }
      }
      return best?.dateTime;
    }

    int? daysSince(HealthEventType type) {
      final dt = latestOf(type);
      if (dt == null) return null;
      return t.difference(_dateOnly(dt)).inDays;
    }

    return MilestoneResult(
      daysSinceAdoption: adoptionDays,
      daysSinceDeworm: daysSince(HealthEventType.deworm),
      daysSinceVaccine: daysSince(HealthEventType.vaccine),
      daysSinceSpayNeuter: daysSince(HealthEventType.spayNeuter),
    );
  }

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);
}
