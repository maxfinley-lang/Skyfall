import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../providers/current_user_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'compare/compare_screen.dart';

class MainNavigator extends ConsumerWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);

    final pages = [
      const DashboardScreen(),
      const CompareScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? 'SkyBlock Dashboard' : 'Compare Stats'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(currentUserProvider.notifier).setUuid(null);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(navigationProvider.notifier).setIndex(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: 'Compare'),
        ],
      ),
    );
  }
}
