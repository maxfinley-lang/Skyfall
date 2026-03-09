import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProfilesAsync = ref.watch(allUsersProfilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Community Profiles')),
      body: allProfilesAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No community data yet. Refresh your own profile to join!'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user['cute_name'] ?? 'Unknown Profile'),
                  subtitle: Text('User: ${user['username'] ?? 'Anonymous'}'),
                  trailing: const Icon(Icons.compare_arrows),
                  onTap: () {
                    // Navigate to comparison details
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
