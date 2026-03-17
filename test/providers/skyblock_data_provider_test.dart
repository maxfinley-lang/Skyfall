import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        combatLvl: Skill(level: 10, currentXp: 0, maxXp: 1000000),
        miningLvl: Skill(level: 20, currentXp: 0, maxXp: 1000000),
        farmingLvl: Skill(level: 0, currentXp: 0, maxXp: 1000000),
        foragingLvl: Skill(level: 0, currentXp: 0, maxXp: 1000000),
        fishingLvl: Skill(level: 0, currentXp: 0, maxXp: 1000000),
        enchantingLvl: Skill(level: 0, currentXp: 0, maxXp: 1000000),
        alchemyLvl: Skill(level: 0, currentXp: 0, maxXp: 1000000),
        tamingLvl: Skill(level: 0, currentXp: 0, maxXp: 1000000),
        catacombsLvl: Skill(level: 5, currentXp: 0, maxXp: 1000000),
        carpentryLvl: Skill(level: 0, currentXp: 0, maxXp: 1000000),
        runecraftingLvl: Skill(level: 0, currentXp: 0, maxXp: 1000000),
        socialLvl: Skill(level: 0, currentXp: 0, maxXp: 1000000),
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
