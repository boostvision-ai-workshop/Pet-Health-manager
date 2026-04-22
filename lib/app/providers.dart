import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/pet_repository.dart';
import '../models/models.dart';
import 'app_router.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  throw UnimplementedError('override petRepositoryProvider in ProviderScope');
});

/// UI 刷新计数：仓储变更后 `ref.bumpAppData()`。
final appDataRevisionProvider = StateProvider<int>((ref) => 0);

final petSnapshotProvider = Provider<Pet?>((ref) {
  ref.watch(appDataRevisionProvider);
  return ref.watch(petRepositoryProvider).getPet();
});

final eventsSnapshotProvider = Provider<List<HealthEvent>>((ref) {
  ref.watch(appDataRevisionProvider);
  final list = ref.watch(petRepositoryProvider).getEvents();
  return List.unmodifiable(list);
});

final remindersSnapshotProvider = Provider<List<Reminder>>((ref) {
  ref.watch(appDataRevisionProvider);
  final list = ref.watch(petRepositoryProvider).getReminders();
  return List.unmodifiable(list);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final repo = ref.watch(petRepositoryProvider);
  return buildAppRouter(repo);
});

extension AppDataBump on WidgetRef {
  void bumpAppData() {
    read(appDataRevisionProvider.notifier).state++;
  }
}

extension AppDataBumpRef on Ref {
  void bumpAppData() {
    read(appDataRevisionProvider.notifier).state++;
  }
}
