import 'package:chongban_health/app/chongban_app.dart';
import 'package:chongban_health/app/providers.dart';
import 'package:chongban_health/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_repository.dart';

void main() {
  testWidgets('三 Tab 壳展示首页标题', (tester) async {
    final pet = Pet(
      id: 'pet_001',
      name: '奶油',
      birthday: DateTime(2024, 2, 12),
      gender: PetGender.female,
      breed: '英短',
      adoptionDate: DateTime(2024, 6, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          petRepositoryProvider.overrideWithValue(MemoryPetRepository(pet: pet)),
        ],
        child: const ChongbanApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
