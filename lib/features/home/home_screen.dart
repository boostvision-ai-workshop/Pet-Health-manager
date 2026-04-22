import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_theme.dart';
import '../../app/providers.dart';
import 'widgets/milestone_section.dart';
import 'widgets/reminders_strip.dart';
import 'widgets/summary_card.dart';
import 'widgets/weight_trend_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petSnapshotProvider);
    final events = ref.watch(eventsSnapshotProvider);
    final reminders = ref.watch(remindersSnapshotProvider);

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('首页')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '正在加载档案…',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: ListView(
        padding: const EdgeInsets.all(ChongbanTokens.spacePage),
        children: [
          SummaryCard(
            pet: pet,
            events: events,
            reminders: reminders,
          ),
          const SizedBox(height: ChongbanTokens.spaceCard),
          MilestoneSection(pet: pet, events: events),
          const SizedBox(height: ChongbanTokens.spaceCard),
          WeightTrendCard(events: events),
          const SizedBox(height: ChongbanTokens.spaceCard),
          RemindersStrip(reminders: reminders),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/events/add'),
        icon: const Icon(Icons.add),
        label: const Text('记录'),
        backgroundColor: ChongbanTokens.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
