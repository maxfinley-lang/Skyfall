import 'dart:convert';
import 'package:http/http.dart' as http;

class MojangService {
  static const String _baseUrl = 'https://playerdb.co/api/player/minecraft';
  final http.Client _client;

  MojangService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> getUuid(String username) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/$username'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['player']['id'] as String?;
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch UUID from PlayerDB: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to UUID API: $e');
    }
  }
}
