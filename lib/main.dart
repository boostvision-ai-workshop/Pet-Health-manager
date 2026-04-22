import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/chongban_app.dart';
import 'app/providers.dart';
import 'data/pet_repository_hive.dart';
import 'services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final repo = await PetRepositoryHive.open();

  await LocalNotificationService.init();
  try {
    await LocalNotificationService.syncWithRepository(repo);
  } catch (e, st) {
    // 未捕获时会导致 runApp 不执行，界面一直停在系统闪屏
    debugPrint('LocalNotificationService.syncWithRepository: $e');
    if (kDebugMode) {
      debugPrintStack(stackTrace: st);
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        petRepositoryProvider.overrideWithValue(repo),
      ],
      child: const ChongbanApp(),
    ),
  );
}
