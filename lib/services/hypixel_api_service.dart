import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/skyblock_profile.dart';

class HypixelApiService {
  // Using SkyShiiyu API (Proxy) which doesn't strictly require a user-provided API key, 
  // but it's good to keep the signature aligned with the app's credentials.
  static const String _baseUrl = 'https://sky.shiiyu.moe/api/v2';

  Future<List<SkyblockProfile>> getProfiles(String username, String apiKey) async {
    // Note: In a production app with the official Hypixel API, 
    // we would use the apiKey as a query parameter or header.
    // For SkyShiiyu, we proceed with username alone.
    
    final response = await http.get(
      Uri.parse('$_baseUrl/profile/$username'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      // SkyShiiyu returns a map of profile IDs to profile data under the 'profiles' key
      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('profiles')) {
        final profilesMap = jsonResponse['profiles'] as Map<String, dynamic>;
        
        return profilesMap.entries.map((entry) {
          final profileData = entry.value as Map<String, dynamic>;
          return SkyblockProfile(
            profileId: entry.key,
            cuteName: profileData['cute_name'] ?? 'Unknown',
            data: profileData,
          );
        }).toList();
      } else {
        throw Exception('Unexpected API response format');
      }
    } else if (response.statusCode == 404) {
      throw Exception('User not found or has no public Skyblock profiles. Check if your API settings are on in Hypixel.');
    } else {
      throw Exception('Failed to connect to Skyblock API (Status: ${response.statusCode})');
    }
  }
}
