import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/weight_trend_service.dart';
import '../../../shared/empty_state.dart';
import '../../../shared/weight_trend_copy.dart';

class WeightTrendCard extends StatelessWidget {
  const WeightTrendCard({
    super.key,
    required this.events,
  });

  final List<HealthEvent> events;

  @override
  Widget build(BuildContext context) {
    final series = WeightTrendService.build(
      today: DateTime.now(),
      events: events,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ChongbanTokens.spaceCard + 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '体重趋势',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  '最近一年的记录',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ChongbanTokens.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            switch (series.branch) {
              WeightTrendBranch.empty => EmptyState(
                  title: WeightTrendCopy.emptyTitle,
                  subtitle: WeightTrendCopy.emptySubtitle,
                  icon: Icons.monitor_weight_outlined,
                  actionLabel: '去记录',
                  onAction: () => context.push('/events/add'),
                ),
              WeightTrendBranch.single => SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${series.points.first.$2.toStringAsFixed(2)} kg',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: ChongbanTokens.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _fmt(series.points.first.$1),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '仅一条记录，继续记录即可生成折线。',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              WeightTrendBranch.multi => SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: _minY(series) - 0.3,
                      maxY: _maxY(series) + 0.3,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 0.5,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: ChongbanTokens.divider.withValues(alpha: 0.6),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (v, m) => Text(
                              v.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (v, m) {
                              final i = v.round();
                              if (i < 0 ||
                                  i >= series.points.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _fmtShort(series.points[i].$1),
                                  style: const TextStyle(fontSize: 9),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < series.points.length; i++)
                              FlSpot(i.toDouble(), series.points[i].$2),
                          ],
                          isCurved: true,
                          color: ChongbanTokens.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: ChongbanTokens.primary.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            },
          ],
        ),
      ),
    );
  }

  double _minY(WeightTrendSeries s) {
    var m = s.points.first.$2;
    for (final p in s.points) {
      if (p.$2 < m) m = p.$2;
    }
    return m;
  }

  double _maxY(WeightTrendSeries s) {
    var m = s.points.first.$2;
    for (final p in s.points) {
      if (p.$2 > m) m = p.$2;
    }
    return m;
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtShort(DateTime d) =>
      '${d.month}/${d.day}';
}
