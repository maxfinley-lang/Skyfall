import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skyblock_profile.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveUserProfile(String userId, SkyblockProfile profile) async {
    await _db.collection('users').doc(userId).set({
      'profile_id': profile.profileId,
      'cute_name': profile.cuteName,
      'data': profile.data,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllUserProfiles() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
