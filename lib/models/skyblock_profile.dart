class SkyblockProfile {
  final String profileId;
  final String cuteName;
  final Map<String, dynamic> data;

  SkyblockProfile({
    required this.profileId,
    required this.cuteName,
    required this.data,
  });

  factory SkyblockProfile.fromJson(Map<String, dynamic> json) {
    return SkyblockProfile(
      profileId: json['profile_id'] ?? '',
      cuteName: json['cute_name'] ?? '',
      data: json,
    );
  }
}
