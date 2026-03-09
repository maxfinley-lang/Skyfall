import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyblock/screens/home/username_input_screen.dart';
import 'package:skyblock/services/mojang_service.dart';
import 'package:skyblock/providers/current_user_provider.dart';

class MockMojangService extends Mock implements MojangService {}

void main() {
  late MockMojangService mockMojangService;

  setUp(() {
    mockMojangService = MockMojangService();
  });

  group('UsernameInputScreen Widget Tests', () {
    testWidgets('should show error snackbar for empty username', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mojangServiceProvider.overrideWithValue(mockMojangService),
          ],
          child: const MaterialApp(home: UsernameInputScreen()),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(find.text('Please enter a username.'), findsOneWidget);
    });

    testWidgets('should call MojangService on valid input', (tester) async {
      const username = 'test_user';
      const uuid = 'test-uuid';
      
      when(() => mockMojangService.getUuid(username)).thenAnswer(
        (_) async => uuid,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mojangServiceProvider.overrideWithValue(mockMojangService),
          ],
          child: const MaterialApp(home: UsernameInputScreen()),
        ),
      );

      await tester.enterText(find.byType(TextField), username);
      await tester.tap(find.text('Go'));
      await tester.pump(); // Start async call

      verify(() => mockMojangService.getUuid(username)).called(1);
    });
  });
}
