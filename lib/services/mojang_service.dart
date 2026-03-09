import 'dart:convert';
import 'package:http/http.dart' as http;

class MojangService {
  static const String _baseUrl = 'https://api.mojang.com/users/profiles/minecraft';

  Future<String?> getUuid(String username) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$username'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as String?;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch UUID from Mojang API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to Mojang API: $e');
    }
  }
}
