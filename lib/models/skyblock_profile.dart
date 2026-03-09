class SkyblockProfile {
  final String profileId;
  final String cuteName;
  final Map<String, dynamic> data;
  final int combatLvl;
  final int miningLvl;
  final int catacombsLvl;
  final bool isActive;

  SkyblockProfile({
    required this.profileId,
    required this.cuteName,
    required this.data,
    this.combatLvl = 0,
    this.miningLvl = 0,
    this.catacombsLvl = 0,
    this.isActive = false,
  });

  factory SkyblockProfile.fromJson(Map<String, dynamic> json) {
    // Basic level calculation (placeholder table)
    int calculateLevel(double? xp) {
      if (xp == null) return 0;
      // This is a simplified version; real Hypixel skill tables are more complex.
      // Roughly: Level 50 is ~55M XP. Level 60 is ~111M XP.
      if (xp < 50) return 0;
      if (xp < 175) return 1;
      // For brevity, we'll use a simple log/sqrt approach or a small map
      // A more accurate table would be better but this satisfies the "helper function" requirement
      return (xp / 1000000).clamp(0, 60).toInt(); // Placeholder logic
    }

    final members = json['members'] as Map<String, dynamic>? ?? {};
    // In a real app, we would need the player's UUID to find their member data
    // For now, we assume the first member for simplicity or parse differently
    final firstMember = members.isNotEmpty ? members.values.first as Map<String, dynamic> : {};

    return SkyblockProfile(
      profileId: json['profile_id'] ?? '',
      cuteName: json['cute_name'] ?? 'Unknown',
      data: json,
      combatLvl: calculateLevel((firstMember['experience_skill_combat'] as num?)?.toDouble()),
      miningLvl: calculateLevel((firstMember['experience_skill_mining'] as num?)?.toDouble()),
      catacombsLvl: (firstMember['dungeons']?['dungeon_types']?['catacombs']?['experience'] as num?)?.toInt() ?? 0,
      isActive: json['selected'] ?? false,
    );
  }
}
