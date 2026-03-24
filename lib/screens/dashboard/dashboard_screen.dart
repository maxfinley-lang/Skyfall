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
      return const Center(child: Text('Please log in first.'));
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
                const Text(
                  'Slayers',
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
                    _buildSlayerCard('Revenant', activeProfile.slayers.zombie, Icons.sentiment_very_dissatisfied),
                    _buildSlayerCard('Tarantula', activeProfile.slayers.spider, Icons.bug_report),
                    _buildSlayerCard('Sven', activeProfile.slayers.wolf, Icons.pets),
                    _buildSlayerCard('Voidgloom', activeProfile.slayers.enderman, Icons.visibility),
                    _buildSlayerCard('Inferno', activeProfile.slayers.blaze, Icons.local_fire_department),
                    _buildSlayerCard('Riftstalker', activeProfile.slayers.vampire, Icons.bloodtype),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPetsSection(context, activeProfile),
                const SizedBox(height: 24),
                _buildAccessoryBag(context, activeProfile),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      );
  }

  Widget _buildPetsSection(BuildContext context, SkyblockProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pets',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (profile.pets.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: profile.pets.length,
              itemBuilder: (context, index) {
                final pet = profile.pets[index];
                return GestureDetector(
                  onTap: () => _showPetDetails(context, pet),
                  child: Card(
                    color: pet.active ? Colors.deepPurple.withValues(alpha: 0.1) : null,
                    child: Container(
                      width: 110,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets,
                            color: _getRarityColor(pet.rarity),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pet.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Lvl ${pet.level}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No pets found.'),
            ),
          ),
      ],
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toUpperCase()) {
      case 'COMMON': return Colors.grey;
      case 'UNCOMMON': return Colors.green;
      case 'RARE': return Colors.blue;
      case 'EPIC': return Colors.purple;
      case 'LEGENDARY': return Colors.orange;
      case 'MYTHIC': return Colors.pink;
      default: return Colors.grey;
    }
  }

  void _showPetDetails(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${pet.name} [Lvl ${pet.level}]'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rarity: ${pet.rarity}',
              style: TextStyle(color: _getRarityColor(pet.rarity), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Skills:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...pet.skills.map((skill) => Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('• $skill'),
            )),
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

  Widget _buildAccessoryBag(BuildContext context, SkyblockProfile profile) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.talismans.take(8).map((t) => ActionChip(
                  label: Text(t, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                  side: BorderSide(color: Colors.deepPurple.withValues(alpha: 0.3)),
                  onPressed: () {
                    _showTalismanDetails(context, t);
                  },
                )).toList(),
              ),
              if (profile.talismans.length > 8)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: TextButton.icon(
                    onPressed: () => _showAllTalismans(context, profile.talismans),
                    icon: const Icon(Icons.grid_view, size: 16),
                    label: Text('See all ${profile.talismans.length} accessories'),
                  ),
                ),
            ],
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

  Widget _buildSkillCard(String skillName, Skill skill, IconData icon) {
    String formatXp(double xp) {
      if (xp >= 1000000) return '${(xp / 1000000).toStringAsFixed(1)}M';
      if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
      return xp.toInt().toString();
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    skillName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Lvl ${skill.level}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: skill.progress,
                minHeight: 4,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${formatXp(skill.currentXp)} / ${formatXp(skill.maxXp)}',
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlayerCard(String boss, int level, IconData icon) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.redAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                boss,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: level == 9 ? Colors.red : Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$level',
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllTalismans(BuildContext context, List<String> talismans) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accessory Bag (${talismans.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: talismans.map((t) => ActionChip(
                label: Text(t, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                onPressed: () {
                  Navigator.pop(context);
                  _showTalismanDetails(context, t);
                },
              )).toList(),
            ),
          ),
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
