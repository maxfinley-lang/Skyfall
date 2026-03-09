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
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(String title, dynamic sectionData) {
    if (sectionData == null || (sectionData is Map && sectionData.isEmpty)) return Container();
    
    final Map<String, dynamic> entries = sectionData is Map ? sectionData as Map<String, dynamic> : {};
    
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
              children: entries.entries.take(5).map((e) {
                final val = e.value;
                String displayVal = '0';
                if (val is Map) {
                   displayVal = val['level']?.toString() ?? val['value']?.toString() ?? '0';
                } else if (val is num) {
                   displayVal = val.toString();
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key.replaceAll('_', ' ').toUpperCase()),
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
