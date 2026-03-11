class SkyblockProfile {
  final String profileId;
  final String cuteName;
  final Map<String, dynamic> data;
  final int combatLvl;
  final int miningLvl;
  final int farmingLvl;
  final int foragingLvl;
  final int fishingLvl;
  final int enchantingLvl;
  final int alchemyLvl;
  final int tamingLvl;
  final int catacombsLvl;
  final int carpentryLvl;
  final int runecraftingLvl;
  final int socialLvl;
  final bool isActive;

  SkyblockProfile({
    required this.profileId,
    required this.cuteName,
    required this.data,
    this.combatLvl = 0,
    this.miningLvl = 0,
    this.farmingLvl = 0,
    this.foragingLvl = 0,
    this.fishingLvl = 0,
    this.enchantingLvl = 0,
    this.alchemyLvl = 0,
    this.tamingLvl = 0,
    this.catacombsLvl = 0,
    this.carpentryLvl = 0,
    this.runecraftingLvl = 0,
    this.socialLvl = 0,
    this.isActive = false,
  });

  factory SkyblockProfile.fromJson(Map<String, dynamic> json) {
    // Basic level calculation
    int calculateLevel(double? xp) {
      if (xp == null) return 0;
      // Basic level calculation: roughly XP/1M up to 60 for MVP simplicity
      return (xp / 1000000).clamp(0, 60).toInt();
    }

    final members = json['members'] as Map<String, dynamic>? ?? {};
    final firstMember = members.isNotEmpty ? members.values.first as Map<String, dynamic> : {};

    return SkyblockProfile(
      profileId: json['profile_id'] ?? '',
      cuteName: json['cute_name'] ?? 'Unknown',
      data: json,
      combatLvl: calculateLevel((firstMember['experience_skill_combat'] as num?)?.toDouble()),
      miningLvl: calculateLevel((firstMember['experience_skill_mining'] as num?)?.toDouble()),
      farmingLvl: calculateLevel((firstMember['experience_skill_farming'] as num?)?.toDouble()),
      foragingLvl: calculateLevel((firstMember['experience_skill_foraging'] as num?)?.toDouble()),
      fishingLvl: calculateLevel((firstMember['experience_skill_fishing'] as num?)?.toDouble()),
      enchantingLvl: calculateLevel((firstMember['experience_skill_enchanting'] as num?)?.toDouble()),
      alchemyLvl: calculateLevel((firstMember['experience_skill_alchemy'] as num?)?.toDouble()),
      tamingLvl: calculateLevel((firstMember['experience_skill_taming'] as num?)?.toDouble()),
      carpentryLvl: calculateLevel((firstMember['experience_skill_carpentry'] as num?)?.toDouble()),
      runecraftingLvl: calculateLevel((firstMember['experience_skill_runecrafting'] as num?)?.toDouble()),
      socialLvl: calculateLevel((firstMember['experience_skill_social2'] as num?)?.toDouble()),
      catacombsLvl: calculateLevel((firstMember['dungeons']?['dungeon_types']?['catacombs']?['experience'] as num?)?.toDouble()),
      isActive: json['selected'] ?? false,
    );
  }
}
