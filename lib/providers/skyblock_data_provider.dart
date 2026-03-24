import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/skyblock_profile.dart';
import 'profile_provider.dart';

final skyblockDataProvider = FutureProvider.family<SkyblockProfile, String>((ref, uuid) async {
  final apiKey = ref.watch(apiKeyProvider).trim();
  
  // If no API Key is found, throw an exception so tests pass
  if (apiKey.isEmpty) {
    throw Exception('API Key not found in .env or credentials.');
  }

  // DEBUG PRINT for API Key testing
  if (apiKey.length >= 8) {
    debugPrint('DEBUG: Using API Key: ${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)} for UUID: $uuid');
  } else {
    debugPrint('DEBUG: Using short API Key: $apiKey for UUID: $uuid');
  }

  final service = ref.watch(hypixelApiServiceProvider);
  try {
    final profiles = await service.getProfiles(uuid, apiKey);

    if (profiles.isEmpty) {
      throw Exception('No SkyBlock profiles found for this user.');
    }

    // Auto-select the active profile (Step 2.2 logic integrated here)
    return profiles.firstWhere(
      (p) => p.isActive,
      orElse: () => profiles.first,
    );
  } catch (e) {
    debugPrint('ERROR: Failed to fetch profiles from Hypixel: $e');
    rethrow;
  }
});
