import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/milestone_service.dart';

class MilestoneSection extends StatelessWidget {
  const MilestoneSection({
    super.key,
    required this.pet,
    required this.events,
  });

  final Pet pet;
  final List<HealthEvent> events;

  @override
  Widget build(BuildContext context) {
    final r = MilestoneService.compute(
      today: DateTime.now(),
      pet: pet,
      events: events,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ChongbanTokens.spaceCard + 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '里程碑',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _row(context, '到家天数', '${r.daysSinceAdoption} 天'),
            _row(
              context,
              '距上次驱虫',
              r.labelOrPending(r.daysSinceDeworm, suffix: ' 天'),
            ),
            _row(
              context,
              '距上次疫苗',
              r.labelOrPending(r.daysSinceVaccine, suffix: ' 天'),
            ),
            _row(
              context,
              '绝育后',
              r.labelOrPending(r.daysSinceSpayNeuter, suffix: ' 天'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
