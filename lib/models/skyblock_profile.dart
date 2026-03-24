class Pet {
  final String name;
  final String rarity;
  final int level;
  final List<String> skills;
  final bool active;

  Pet({
    required this.name,
    required this.rarity,
    required this.level,
    required this.skills,
    this.active = false,
  });
}

class SlayerProgress {
  final int zombie;
  final int spider;
  final int wolf;
  final int enderman;
  final int blaze;
  final int vampire;

  SlayerProgress({
    this.zombie = 0,
    this.spider = 0,
    this.wolf = 0,
    this.enderman = 0,
    this.blaze = 0,
    this.vampire = 0,
  });
}

class Skill {
  final int level;
  final double currentXp;
  final double maxXp;

  Skill({
    required this.level,
    required this.currentXp,
    required this.maxXp,
  });

  double get progress => (currentXp / maxXp).clamp(0.0, 1.0);
}

class SkyblockProfile {
  final String profileId;
  final String cuteName;
  final Map<String, dynamic> data;
  final double skyblockLevel;
  final Skill combatLvl;
  final Skill miningLvl;
  final Skill farmingLvl;
  final Skill foragingLvl;
  final Skill fishingLvl;
  final Skill enchantingLvl;
  final Skill alchemyLvl;
  final Skill tamingLvl;
  final Skill catacombsLvl;
  final Skill carpentryLvl;
  final Skill runecraftingLvl;
  final Skill socialLvl;
  final List<String> talismans;
  final int talismanCount;
  final List<Pet> pets;
  final SlayerProgress slayers;
  final bool isActive;

  SkyblockProfile({
    required this.profileId,
    required this.cuteName,
    required this.data,
    this.skyblockLevel = 0,
    required this.combatLvl,
    required this.miningLvl,
    required this.farmingLvl,
    required this.foragingLvl,
    required this.fishingLvl,
    required this.enchantingLvl,
    required this.alchemyLvl,
    required this.tamingLvl,
    required this.catacombsLvl,
    required this.carpentryLvl,
    required this.runecraftingLvl,
    required this.socialLvl,
    this.talismans = const [],
    this.talismanCount = 0,
    this.pets = const [],
    SlayerProgress? slayers,
    this.isActive = false,
  }) : slayers = slayers ?? SlayerProgress();

  factory SkyblockProfile.fromJson(Map<String, dynamic> json) {
    // Basic level calculation
    Skill calculateSkill(double? totalXp) {
      if (totalXp == null) return Skill(level: 0, currentXp: 0, maxXp: 1000000);
      
      // For MVP simplicity, every level is 1M XP. 
      // Real SkyBlock XP tables are complex, but this satisfies the UI requirement.
      int level = (totalXp / 1000000).floor().clamp(0, 60);
      double currentXp = totalXp % 1000000;
      return Skill(
        level: level,
        currentXp: currentXp,
        maxXp: 1000000,
      );
    }

    final members = json['members'] as Map<String, dynamic>? ?? {};
    final firstMember = members.isNotEmpty ? members.values.first as Map<String, dynamic> : {};
    
    // For MVP, we'll try to get the count from the bag if it exists as a simple field,
    // though usually it requires NBT parsing. We'll use a fallback for now.
    final talismanBag = firstMember['talisman_bag'] as Map<String, dynamic>?;

    final slayerData = firstMember['slayer_bosses'] as Map<String, dynamic>? ?? {};
    
    int getSlayerLvl(String boss) {
      final xp = slayerData[boss]?['xp'] as num? ?? 0;
      // Very rough slayer level estimation (0-9)
      if (xp >= 1000000) return 9;
      if (xp >= 400000) return 8;
      if (xp >= 100000) return 7;
      if (xp >= 20000) return 6;
      if (xp >= 5000) return 5;
      if (xp >= 1500) return 4;
      if (xp >= 250) return 3;
      if (xp >= 15) return 2;
      if (xp >= 5) return 1;
      return 0;
    }

    final petsList = (firstMember['pets'] as List<dynamic>? ?? []).map((p) {
      final petMap = p as Map<String, dynamic>;
      return Pet(
        name: petMap['type']?.toString().replaceAll('_', ' ') ?? 'Unknown Pet',
        rarity: petMap['tier']?.toString() ?? 'COMMON',
        level: (petMap['exp'] as num? ?? 0) ~/ 100000, // Very simplified level
        skills: [], // Requires more complex parsing or static data
        active: petMap['active'] ?? false,
      );
    }).toList();
    
    return SkyblockProfile(
      profileId: json['profile_id'] ?? '',
      cuteName: json['cute_name'] ?? 'Unknown',
      data: json,
      skyblockLevel: (firstMember['leveling']?['experience'] as num? ?? 0) / 100.0,
      combatLvl: calculateSkill((firstMember['experience_skill_combat'] as num?)?.toDouble()),
      miningLvl: calculateSkill((firstMember['experience_skill_mining'] as num?)?.toDouble()),
      farmingLvl: calculateSkill((firstMember['experience_skill_farming'] as num?)?.toDouble()),
      foragingLvl: calculateSkill((firstMember['experience_skill_foraging'] as num?)?.toDouble()),
      fishingLvl: calculateSkill((firstMember['experience_skill_fishing'] as num?)?.toDouble()),
      enchantingLvl: calculateSkill((firstMember['experience_skill_enchanting'] as num?)?.toDouble()),
      alchemyLvl: calculateSkill((firstMember['experience_skill_alchemy'] as num?)?.toDouble()),
      tamingLvl: calculateSkill((firstMember['experience_skill_taming'] as num?)?.toDouble()),
      carpentryLvl: calculateSkill((firstMember['experience_skill_carpentry'] as num?)?.toDouble()),
      runecraftingLvl: calculateSkill((firstMember['experience_skill_runecrafting'] as num?)?.toDouble()),
      socialLvl: calculateSkill((firstMember['experience_skill_social2'] as num?)?.toDouble()),
      catacombsLvl: calculateSkill((firstMember['dungeons']?['dungeon_types']?['catacombs']?['experience'] as num?)?.toDouble()),
      talismans: [], // Note: Real talismans require NBT parsing
      talismanCount: (firstMember['talisman_bag']?['bag_size'] as num? ?? 0).toInt(),
      pets: petsList,
      slayers: SlayerProgress(
        zombie: getSlayerLvl('zombie'),
        spider: getSlayerLvl('spider'),
        wolf: getSlayerLvl('wolf'),
        enderman: getSlayerLvl('enderman'),
        blaze: getSlayerLvl('blaze'),
        vampire: getSlayerLvl('vampire'),
      ),
      isActive: json['selected'] ?? false,
    );
  }

  factory SkyblockProfile.mock() {
    return SkyblockProfile(
      profileId: 'mock-150-uuid',
      cuteName: 'Cucumber',
      data: {},
      skyblockLevel: 150.0,
      combatLvl: Skill(level: 45, currentXp: 750000, maxXp: 1000000),
      miningLvl: Skill(level: 42, currentXp: 120000, maxXp: 1000000),
      farmingLvl: Skill(level: 38, currentXp: 900000, maxXp: 1000000),
      foragingLvl: Skill(level: 30, currentXp: 50000, maxXp: 1000000),
      fishingLvl: Skill(level: 28, currentXp: 660000, maxXp: 1000000),
      enchantingLvl: Skill(level: 55, currentXp: 440000, maxXp: 1000000),
      alchemyLvl: Skill(level: 50, currentXp: 200000, maxXp: 1000000),
      tamingLvl: Skill(level: 40, currentXp: 850000, maxXp: 1000000),
      catacombsLvl: Skill(level: 35, currentXp: 500000, maxXp: 1000000),
      carpentryLvl: Skill(level: 50, currentXp: 100000, maxXp: 1000000),
      runecraftingLvl: Skill(level: 25, currentXp: 950000, maxXp: 1000000),
      socialLvl: Skill(level: 15, currentXp: 330000, maxXp: 1000000),
      talismans: [
        'Hegemony Artifact', 'Auto-Recombobulator', 'Wither Artifact', 'Seal of the Family',
        'End Game Artifact', 'Ender Artifact', 'Bat Artifact', 'Cheetah Talisman',
        'Frozen Chicken', 'King Bait', 'Great Spook Artifact', 'Nether Artifact',
        'Candy Relic', 'Dante Talisman', 'Campfire God Badge', 'Personal Deletor 7000',
        'Personal Compactor 7000', 'Ring of Love', 'Experience Artifact', 'Artifact of Control',
        'Beastmaster Crest', 'Cat Talisman', 'Wood Affinity Talisman', 'Zombie Artifact',
        'Spider Artifact', 'Tarantula Talisman', 'Survivor Cube', 'Melody\'s Hair',
        'Day Crystal', 'Night Crystal', 'Devour Ring', 'Piggy Bank',
        'Wolf Paw', 'Graveyard Talisman', 'Potion Badge', 'Magnetic Talisman',
        'Village Affinity Talisman', 'Mine Affinity Talisman', 'Intimidation Artifact', 'Scavenger Talisman',
        'Fire Talisman', 'Vaccine Talisman', 'Farmer Orb', 'Talent Tincture',
        'Speed Talisman', 'Feather Artifact', 'Sea Creature Talisman', 'Healing Talisman',
        'Haste Ring', 'Red Claw Artifact', 'Hunter Talisman', 'Bait Ring',
        'Spiked Atrocity', 'Mineral Talisman', 'Titanium Talisman', 'Jerry Artifact',
        'Candy Artifact', 'New Year Cake Bag', 'Compass Talisman', 'Zombie Ring',
        'Spider Ring', 'Wolf Ring', 'Bat Ring', 'Devour Talisman'
      ],
      talismanCount: 64,
      pets: [
        Pet(
          name: 'Golden Dragon',
          rarity: 'LEGENDARY',
          level: 200,
          skills: ['Gold Fusion', 'Dragon-Slayer', 'Legendary Power'],
          active: true,
        ),
        Pet(
          name: 'Ender Dragon',
          rarity: 'LEGENDARY',
          level: 100,
          skills: ['End-Slayer', 'One with the Dragon', 'Superior'],
        ),
        Pet(
          name: 'Blue Whale',
          rarity: 'LEGENDARY',
          level: 100,
          skills: ['Ingest', 'Bulk', 'Archimedes'],
        ),
        Pet(
          name: 'Wither Skeleton',
          rarity: 'LEGENDARY',
          level: 100,
          skills: ['Stronger Bones', 'Wither Resistance', 'Death\'s Touch'],
        ),
      ],
      slayers: SlayerProgress(
        zombie: 8,
        spider: 7,
        wolf: 7,
        enderman: 6,
        blaze: 3,
        vampire: 5,
      ),
      isActive: true,
    );
  }
}
