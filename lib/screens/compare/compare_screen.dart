import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/skyblock_data_provider.dart';
import '../../widgets/stat_row.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final _opponentController = TextEditingController();
  String? _opponentUuid;
  bool _isLoading = false;

  Future<void> _searchOpponent() async {
    final username = _opponentController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _isLoading = true;
      _opponentUuid = null;
    });

    try {
      final mojangService = ref.read(mojangServiceProvider);
      final uuid = await mojangService.getUuid(username);
      
      if (mounted) {
        setState(() {
          _opponentUuid = uuid;
          if (uuid == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opponent not found.')),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userUuid = ref.watch(currentUserProvider);
    if (userUuid == null) return const Center(child: Text('Login first'));

    final userProfileAsync = ref.watch(skyblockDataProvider(userUuid));

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _opponentController,
              decoration: InputDecoration(
                labelText: 'Enter opponent username',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.search),
                  onPressed: _isLoading ? null : _searchOpponent,
                ),
              ),
              onSubmitted: (_) => _searchOpponent(),
            ),
            const SizedBox(height: 24),
            userProfileAsync.when(
              data: (userProfile) {
                if (_opponentUuid == null) {
                  return const Center(child: Text('Search for an opponent to compare stats.'));
                }

                return Consumer(
                  builder: (context, ref, child) {
                    final opponentProfileAsync = ref.watch(skyblockDataProvider(_opponentUuid!));

                    return opponentProfileAsync.when(
                      data: (opponentProfile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              'Comparison vs ${opponentProfile.cuteName} (${_opponentController.text.trim()})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            StatRow(
                              label: 'SkyBlock Level',
                              valueA: userProfile.skyblockLevel.toInt(),
                              valueB: opponentProfile.skyblockLevel.toInt(),
                            ),
                            StatRow(
                              label: 'Combat Level',
                              valueA: userProfile.combatLvl.level,
                              valueB: opponentProfile.combatLvl.level,
                            ),
                            StatRow(
                              label: 'Mining Level',
                              valueA: userProfile.miningLvl.level,
                              valueB: opponentProfile.miningLvl.level,
                            ),
                            StatRow(
                              label: 'Farming Level',
                              valueA: userProfile.farmingLvl.level,
                              valueB: opponentProfile.farmingLvl.level,
                            ),
                            StatRow(
                              label: 'Foraging Level',
                              valueA: userProfile.foragingLvl.level,
                              valueB: opponentProfile.foragingLvl.level,
                            ),
                            StatRow(
                              label: 'Fishing Level',
                              valueA: userProfile.fishingLvl.level,
                              valueB: opponentProfile.fishingLvl.level,
                            ),
                            StatRow(
                              label: 'Enchanting Level',
                              valueA: userProfile.enchantingLvl.level,
                              valueB: opponentProfile.enchantingLvl.level,
                            ),
                            StatRow(
                              label: 'Alchemy Level',
                              valueA: userProfile.alchemyLvl.level,
                              valueB: opponentProfile.alchemyLvl.level,
                            ),
                            StatRow(
                              label: 'Taming Level',
                              valueA: userProfile.tamingLvl.level,
                              valueB: opponentProfile.tamingLvl.level,
                            ),
                            StatRow(
                              label: 'Catacombs Level',
                              valueA: userProfile.catacombsLvl.level,
                              valueB: opponentProfile.catacombsLvl.level,
                            ),
                            StatRow(
                              label: 'Carpentry Level',
                              valueA: userProfile.carpentryLvl.level,
                              valueB: opponentProfile.carpentryLvl.level,
                            ),
                            StatRow(
                              label: 'Runecrafting Level',
                              valueA: userProfile.runecraftingLvl.level,
                              valueB: opponentProfile.runecraftingLvl.level,
                            ),
                            StatRow(
                              label: 'Social Level',
                              valueA: userProfile.socialLvl.level,
                              valueB: opponentProfile.socialLvl.level,
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error fetching opponent: $err')),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      );
  }

  @override
  void dispose() {
    _opponentController.dispose();
    super.dispose();
  }
}
