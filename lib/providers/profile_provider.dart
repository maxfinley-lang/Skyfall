import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/hypixel_api_service.dart';
import '../services/firestore_service.dart';
import '../models/skyblock_profile.dart';
import 'current_user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hypixelApiServiceProvider = Provider((ref) => HypixelApiService());
final firestoreServiceProvider = Provider((ref) => FirestoreService());

final apiKeyProvider = Provider<String>((ref) {
  final credentials = ref.watch(credentialsProvider);
  if (credentials.apiKey != null && credentials.apiKey!.isNotEmpty) {
    return credentials.apiKey!.trim();
  }
  return (dotenv.env['HYPIXEL_API_KEY'] ?? '').trim();
});

class UserCredentials {
  final String? username;
  final String? apiKey;

  UserCredentials({this.username, this.apiKey});

  bool get isValid => username != null && username!.isNotEmpty && apiKey != null && apiKey!.isNotEmpty;
}

class CredentialsNotifier extends Notifier<UserCredentials> {
  static const String _usernameKey = 'skyblock_username';
  static const String _apiKeyKey = 'skyblock_api_key';

  @override
  UserCredentials build() {
    return UserCredentials();
  }

  Future<void> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    final apiKey = prefs.getString(_apiKeyKey);
    state = UserCredentials(username: username, apiKey: apiKey);
  }

  Future<void> setCredentials(String username, String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_apiKeyKey, apiKey);
    state = UserCredentials(username: username, apiKey: apiKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_apiKeyKey);
    state = UserCredentials();
  }
}

final credentialsProvider = NotifierProvider<CredentialsNotifier, UserCredentials>(CredentialsNotifier.new);

final skyblockProfilesProvider = FutureProvider<List<SkyblockProfile>>((ref) async {
  final uuid = ref.watch(currentUserProvider);
  final apiKey = ref.watch(apiKeyProvider).trim();
  
  if (uuid == null || apiKey.isEmpty) {
    throw Exception('UUID or API Key is missing.');
  }
  
  final service = ref.watch(hypixelApiServiceProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  
  try {
    final profiles = await service.getProfiles(uuid, apiKey);
    
    if (profiles.isEmpty) {
      return [];
    }

    // Save to Firestore so other users can see/compare (Step 2.4)
    if (profiles.isNotEmpty) {
      // For MVP, we use UUID as document ID if possible, or fallback to username
      await firestore.saveUserProfile(uuid, profiles.first);
    }
    
    return profiles;
  } catch (e) {
    rethrow;
  }
});

final allUsersProfilesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firestore = ref.watch(firestoreServiceProvider);
  return await firestore.getAllUserProfiles();
});
