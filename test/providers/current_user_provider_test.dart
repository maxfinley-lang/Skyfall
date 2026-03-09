import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skyblock/providers/current_user_provider.dart';

void main() {
  group('CurrentUserProvider Provider Tests', () {
    test('initial state should be null', () {
      final container = ProviderContainer();
      expect(container.read(currentUserProvider), isNull);
    });

    test('setUuid should update the state', () {
      final container = ProviderContainer();
      const uuid = 'test-uuid';

      container.read(currentUserProvider.notifier).setUuid(uuid);

      expect(container.read(currentUserProvider), uuid);
    });
  });
}
