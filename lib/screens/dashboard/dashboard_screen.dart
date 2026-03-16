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
                const SizedBox(height: 24),
                _buildAccessoryBag(activeProfile),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      );
  }

  Widget _buildAccessoryBag(SkyblockProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Accessory Bag',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${profile.talismanCount} Talismans',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (profile.talismans.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.talismans.map((t) => ActionChip(
              label: Text(t, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
              side: BorderSide(color: Colors.deepPurple.withValues(alpha: 0.3)),
              onPressed: () {
                _showTalismanDetails(context, t);
              },
            )).toList(),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No talismans found or API data restricted.'),
            ),
          ),
      ],
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
                  Row(
                    children: [
                      Text(
                        profile.cuteName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SB Lvl ${profile.skyblockLevel.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Active Profile',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
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

  void _showTalismanDetails(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rarity: Legendary',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Power: +10 Strength'),
            const Text('Power: +5 Critical Damage'),
            const SizedBox(height: 12),
            Text(
              'This accessory provides unique bonuses to your SkyBlock stats while in your bag.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
