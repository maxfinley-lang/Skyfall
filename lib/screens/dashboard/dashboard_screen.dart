import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/skyblock_profile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uuid = ref.watch(currentUserProvider);
    final profilesAsync = ref.watch(skyblockProfilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SkyBlock Dashboard')),
      body: profilesAsync.when(
        data: (profiles) {
          if (profiles.isEmpty) {
            return const Center(child: Text('No profiles found. Ensure your API settings are on in Hypixel.'));
          }

          // Step 2.2: Profile Logic - select active profile
          final activeProfile = profiles.firstWhere(
            (p) => p.isActive, 
            orElse: () => profiles.first,
          );

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(skyblockProfilesProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(uuid, activeProfile),
                const SizedBox(height: 24),
                _buildSkillCard('Combat', activeProfile.combatLvl, Icons.shield),
                _buildSkillCard('Mining', activeProfile.miningLvl, Icons.precision_manufacturing),
                _buildSkillCard('Catacombs', activeProfile.catacombsLvl, Icons.castle),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(skill, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          'Lvl $level',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
