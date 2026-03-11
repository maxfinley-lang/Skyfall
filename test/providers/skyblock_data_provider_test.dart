import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyblock/providers/skyblock_data_provider.dart';
import 'package:skyblock/providers/profile_provider.dart';
import 'package:skyblock/services/hypixel_api_service.dart';
import 'package:skyblock/models/skyblock_profile.dart';

class MockHypixelApiService extends Mock implements HypixelApiService {}

void main() {
  group('SkyblockDataProvider Provider Tests', () {
    test('should throw exception if API key is empty', () async {
      final container = ProviderContainer(
        overrides: [
          apiKeyProvider.overrideWithValue(''),
          hypixelApiServiceProvider.overrideWithValue(MockHypixelApiService()),
        ],
      );
      
      AsyncValue? capturedState;
      container.listen(
        skyblockDataProvider('some-uuid'),
        (previous, next) {
          capturedState = next;
        },
        fireImmediately: true,
      );

      // Give it a bit of time
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(capturedState?.hasError, true);
      expect(capturedState?.error.toString(), contains('API Key not found in .env'));
    });

    test('should fetch data when API key is present', () async {
      final mockService = MockHypixelApiService();
      final profile = SkyblockProfile(
        profileId: 'p1',
        cuteName: 'Apple',
        isActive: true,
        data: {'selected': true},
        combatLvl: 10,
        miningLvl: 20,
        catacombsLvl: 5,
      );

      when(() => mockService.getProfiles('some-uuid', 'valid-key'))
          .thenAnswer((_) async => [profile]);

      final container = ProviderContainer(
        overrides: [
          apiKeyProvider.overrideWithValue('valid-key'),
          hypixelApiServiceProvider.overrideWithValue(mockService),
        ],
      );

      final result = await container.read(skyblockDataProvider('some-uuid').future);
      
      expect(result.profileId, 'p1');
      expect(result.cuteName, 'Apple');
    });
  });
}
