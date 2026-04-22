import '../models/models.dart';

/// PRD §8.2：最近一年内体重趋势序列与 UI 分支（大事记中更早的记录不进入本图）。
enum WeightTrendBranch {
  empty,
  single,
  multi,
}

class WeightTrendSeries {
  const WeightTrendSeries({
    required this.points,
    required this.branch,
  });

  /// 按时间升序。
  final List<(DateTime dateTime, double kg)> points;
  final WeightTrendBranch branch;
}

abstract final class WeightTrendService {
  /// 包含 [today] 所在日在内的最近 365 个自然日（滚动一年窗口）。
  static WeightTrendSeries build({
    required DateTime today,
    required List<HealthEvent> events,
  }) {
    final end = _dateOnly(today);
    final start = end.subtract(const Duration(days: 364));

    final weights = events
        .where((e) => e.type == HealthEventType.weight && e.value != null)
        .where((e) {
          final d = _dateOnly(e.dateTime);
          return !d.isBefore(start) && !d.isAfter(end);
        })
        .map((e) => (e.dateTime, e.value!))
        .toList();

    weights.sort((a, b) => a.$1.compareTo(b.$1));

    late WeightTrendBranch branch;
    if (weights.isEmpty) {
      branch = WeightTrendBranch.empty;
    } else if (weights.length == 1) {
      branch = WeightTrendBranch.single;
    } else {
      branch = WeightTrendBranch.multi;
    }

    return WeightTrendSeries(points: weights, branch: branch);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
