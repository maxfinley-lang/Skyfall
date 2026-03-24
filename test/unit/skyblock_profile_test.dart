import 'package:flutter_test/flutter_test.dart';
import 'package:skyblock/models/skyblock_profile.dart';

void main() {
  group('SkyblockProfile Model Tests', () {
    test('fromJson should correctly parse profile data', () {
      final json = {
        'profile_id': '12345',
        'cute_name': 'Apple',
        'selected': true,
        'members': {
          'uuid_1': {
            'experience_skill_combat': 1500000.0,
            'experience_skill_mining': 5000000.0,
            'dungeons': {
              'dungeon_types': {
                'catacombs': {
                  'experience': 250000,
                }
              }
            }
          }
        }
      };

      final profile = SkyblockProfile.fromJson(json, 'uuid_1');

      expect(profile.profileId, '12345');
      expect(profile.cuteName, 'Apple');
      expect(profile.isActive, true);
      expect(profile.combatLvl.level, 1); // 1.5M / 1M = 1
      expect(profile.miningLvl.level, 5); // 5M / 1M = 5
      expect(profile.catacombsLvl.level, 0); // 250k / 1M = 0
    });

    test('fromJson should handle null or missing fields', () {
      final json = {
        'profile_id': '67890',
        'cute_name': 'Banana',
      };

      final profile = SkyblockProfile.fromJson(json, 'some_uuid');

      expect(profile.profileId, '67890');
      expect(profile.cuteName, 'Banana');
      expect(profile.isActive, false);
      expect(profile.combatLvl.level, 0);
      expect(profile.miningLvl.level, 0);
      expect(profile.catacombsLvl.level, 0);
    });
  });
}
