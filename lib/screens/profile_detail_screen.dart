import 'package:flutter/material.dart';
import '../models/skyblock_profile.dart';

class ProfileDetailScreen extends StatelessWidget {
  final SkyblockProfile profile;
  const ProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    // Official Hypixel API response format
    final Map<String, dynamic> data = profile.data;
    
    return Scaffold(
      appBar: AppBar(title: Text(profile.cuteName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Data Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDataSection('General Info', {
              'Profile ID': profile.profileId,
              'Selected': data['selected']?.toString() ?? 'false',
              'Last Save': data['last_save']?.toString() ?? 'N/A',
            }),
            const SizedBox(height: 16),
            _buildDataSection('Skill Levels', {
              'Combat': profile.combatLvl,
              'Mining': profile.miningLvl,
              'Farming': profile.farmingLvl,
              'Foraging': profile.foragingLvl,
              'Fishing': profile.fishingLvl,
              'Enchanting': profile.enchantingLvl,
              'Alchemy': profile.alchemyLvl,
              'Taming': profile.tamingLvl,
              'Catacombs': profile.catacombsLvl,
              'Carpentry': profile.carpentryLvl,
              'Runecrafting': profile.runecraftingLvl,
              'Social': profile.socialLvl,
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(String title, Map<String, dynamic> entries) {
    if (entries.isEmpty) return Container();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: entries.entries.map((e) {
                final val = e.value;
                String displayVal = val.toString();
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key.toUpperCase()),
                      Text(displayVal),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
