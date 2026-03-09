import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/skyblock_profile.dart';

class HypixelApiService {
  static const String _baseUrl = 'https://api.hypixel.net/v2';
  final http.Client _client;

  HypixelApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<SkyblockProfile>> getProfiles(String uuid, String apiKey) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/skyblock/profiles?key=$apiKey&uuid=$uuid'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['success'] == true && jsonResponse['profiles'] != null) {
        final List<dynamic> profilesList = jsonResponse['profiles'];
        
        return profilesList.map((profileData) {
          return SkyblockProfile.fromJson(profileData as Map<String, dynamic>);
        }).toList();
      } else {
        throw Exception('Hypixel API Error: ${jsonResponse['cause'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to connect to Hypixel API (Status: ${response.statusCode})');
    }
  }
}
