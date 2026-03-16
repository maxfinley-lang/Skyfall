import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/skyblock_profile.dart';

class HypixelApiService {
  static const String _baseUrl = 'https://api.hypixel.net/v2';
  final http.Client _client;

  HypixelApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<SkyblockProfile>> getProfiles(String uuid, String apiKey) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/skyblock/profiles?uuid=$uuid'),
        headers: {
          'API-Key': apiKey,
          'Accept': 'application/json',
          'User-Agent': 'SkyFall-App/1.0.0 (Flutter)',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['profiles'] != null) {
          final List<dynamic> profilesList = jsonResponse['profiles'];
          
          return profilesList.map((profileData) {
            return SkyblockProfile.fromJson(profileData as Map<String, dynamic>);
          }).toList();
        } else {
          throw Exception('Hypixel API Error: ${jsonResponse['cause'] ?? 'Unknown error'}\nResponse: ${response.body}');
        }
      } else {
        // Detailed error for 403 (often CORS or API Key)
        String errorMsg = 'Failed to connect to Hypixel API (Status: ${response.statusCode})\nBody: ${response.body}';
        if (response.statusCode == 403) {
          errorMsg += '\nNote: If you are running on Web (Chrome), this might be a CORS block. Consider running as a Desktop/Mobile app or using a proxy.';
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network Error: $e');
    }
  }
}
