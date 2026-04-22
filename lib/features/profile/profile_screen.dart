import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_theme.dart';
import '../../app/providers.dart';
import '../../services/milestone_service.dart';
import '../../shared/empty_state.dart';
import '../../shared/pet_labels.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petSnapshotProvider);
    final events = ref.watch(eventsSnapshotProvider);

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('我的')),
        body: const EmptyState(
          title: '档案未加载',
          subtitle: '请稍候，或从底部返回首页后重试。',
          icon: Icons.pets_outlined,
        ),
      );
    }

    final m = MilestoneService.compute(
      today: DateTime.now(),
      pet: pet,
      events: events,
    );

    final weight =
        pet.latestWeight != null ? '${pet.latestWeight!.toStringAsFixed(1)} kg' : '—';

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(ChongbanTokens.spacePage),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(ChongbanTokens.spaceCard + 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        ChongbanTokens.primary.withValues(alpha: 0.2),
                    child: Text(
                      pet.name.isNotEmpty
                          ? Characters(pet.name).first
                          : '?',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: ChongbanTokens.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${petGenderLabel(pet.gender)} · ${pet.breed}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '生日 ${DateFormat('yyyy-MM-dd').format(pet.birthday)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '到家 ${DateFormat('yyyy-MM-dd').format(pet.adoptionDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ChongbanTokens.spaceCard),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(ChongbanTokens.spaceCard + 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '关键指标',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _metricRow(context, '当前体重', weight),
                  _metricRow(context, '到家天数', '${m.daysSinceAdoption} 天'),
                  _metricRow(
                    context,
                    '距上次驱虫',
                    m.labelOrPending(m.daysSinceDeworm, suffix: ' 天'),
                  ),
                  _metricRow(
                    context,
                    '距上次疫苗',
                    m.labelOrPending(m.daysSinceVaccine, suffix: ' 天'),
                  ),
                  _metricRow(
                    context,
                    '绝育后',
                    m.labelOrPending(m.daysSinceSpayNeuter, suffix: ' 天'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.push('/pet/edit'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('编辑宠物档案'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/reminders'),
            icon: const Icon(Icons.notifications_outlined),
            label: const Text('本地提醒与通知'),
          ),
          const SizedBox(height: 24),
          Text(
            '说明：提醒数据仅存本机；系统通知需在设置中授予权限。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ChongbanTokens.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
