import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/skyblock_data_provider.dart';
import '../../models/skyblock_profile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uuid = ref.watch(currentUserProvider);

    if (uuid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in first.')),
      );
    }

    final profileAsync = ref.watch(skyblockDataProvider(uuid));

    return profileAsync.when(
        data: (activeProfile) {
          return RefreshIndicator(
            onRefresh: () async {
              // Step 2.3: Call ref.refresh(skyblockDataProvider(uuid))
              return ref.refresh(skyblockDataProvider(uuid).future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(uuid, activeProfile),
                const SizedBox(height: 24),
                const Text(
                  'Skill Levels',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3,
                  children: [
                    _buildSkillCard('Combat', activeProfile.combatLvl, Icons.shield),
                    _buildSkillCard('Mining', activeProfile.miningLvl, Icons.precision_manufacturing),
                    _buildSkillCard('Farming', activeProfile.farmingLvl, Icons.agriculture),
                    _buildSkillCard('Foraging', activeProfile.foragingLvl, Icons.park),
                    _buildSkillCard('Fishing', activeProfile.fishingLvl, Icons.phishing),
                    _buildSkillCard('Enchanting', activeProfile.enchantingLvl, Icons.auto_stories),
                    _buildSkillCard('Alchemy', activeProfile.alchemyLvl, Icons.science),
                    _buildSkillCard('Taming', activeProfile.tamingLvl, Icons.pets),
                    _buildSkillCard('Catacombs', activeProfile.catacombsLvl, Icons.castle),
                    _buildSkillCard('Carpentry', activeProfile.carpentryLvl, Icons.construction),
                    _buildSkillCard('Runecrafting', activeProfile.runecraftingLvl, Icons.diamond),
                    _buildSkillCard('Social', activeProfile.socialLvl, Icons.groups),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      );
  }

  Widget _buildHeader(String? uuid, SkyblockProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (uuid != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://crafatar.com/avatars/$uuid?size=64&overlay',
                  width: 64,
                  height: 64,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 64),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Profile',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    profile.cuteName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard(String skill, int level, IconData icon) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                skill,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Lvl $level',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
