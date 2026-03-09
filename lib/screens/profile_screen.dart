import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../providers/navigation_provider.dart';
import 'leaderboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(credentialsProvider);
    final profilesAsyncValue = ref.watch(skyblockProfilesProvider);
    final selectedIndex = ref.watch(navigationProvider);

    final List<Widget> pages = [
      _buildProfileContent(profilesAsyncValue, credentials.username, ref),
      const LeaderboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? '${credentials.username}\'s Profiles' : 'Community'),
        actions: [
          if (selectedIndex == 0)
            IconButton(
              onPressed: () {
                ref.invalidate(skyblockProfilesProvider);
              },
              icon: const Icon(Icons.refresh),
            ),
          IconButton(
            onPressed: () => ref.read(credentialsProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(navigationProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Profiles'),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: 'Compare'),
        ],
      ),
    );
  }

  Widget _buildProfileContent(AsyncValue<List<SkyblockProfile>> profilesAsyncValue, String? username, WidgetRef ref) {
    return profilesAsyncValue.when(
      data: (profiles) {
        if (profiles.isEmpty) {
          return const Center(
            child: Text('No public profiles found for this user.'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  profile.cuteName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Profile ID: ${profile.profileId.substring(0, 8)}...'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileDetailScreen(profile: profile),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Error: $error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

class ProfileDetailScreen extends StatelessWidget {
  final SkyblockProfile profile;
  const ProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    // Assuming SkyShiiyu response format
    final Map<String, dynamic> data = profile.data['data'] ?? {};
    
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
            _buildDataSection('Skills', data['skills']),
            _buildDataSection('Collections', data['collections']),
            _buildDataSection('Slayers', data['slayers']),
            _buildDataSection('Dungeons', data['dungeons']),
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
