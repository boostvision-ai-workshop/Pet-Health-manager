import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../models/models.dart';
import '../../../services/home_health_status.dart';
import '../../../shared/pet_labels.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.pet,
    required this.events,
    required this.reminders,
  });

  final Pet pet;
  final List<HealthEvent> events;
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    final status = HomeHealthStatusService.compute(
      now: DateTime.now(),
      events: events,
      reminders: reminders,
    );

    final weightText = pet.latestWeight != null
        ? '${pet.latestWeight!.toStringAsFixed(1)} kg'
        : '待补充';

    final birth = DateFormat('yyyy-MM-dd').format(pet.birthday);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ChongbanTokens.spaceCard + 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: ChongbanTokens.primary.withValues(alpha: 0.2),
              child: Text(
                pet.name.isNotEmpty
                    ? Characters(pet.name).first
                    : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: ChongbanTokens.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$birth · ${petGenderLabel(pet.gender)} · ${pet.breed}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '最新体重 $weightText',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ChongbanTokens.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '健康 ${status.zh}',
                          style: const TextStyle(
                            color: ChongbanTokens.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
