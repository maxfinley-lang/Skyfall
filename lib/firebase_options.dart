import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError('Android options not provided yet.');
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS options not provided yet.');
      default:
        throw UnsupportedError('Platform not supported.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCghNlX8n_lhaWRo-rMqaV9LaaKDZ3r0sU',
    authDomain: 'skyfall-a11fd.firebaseapp.com',
    projectId: 'skyfall-a11fd',
    storageBucket: 'skyfall-a11fd.firebasestorage.app',
    messagingSenderId: '52273815958',
    appId: '1:52273815958:web:62cb8ec6f4bac20a88bdb7',
    measurementId: 'G-5EPYBRHJGS',
  );
}
