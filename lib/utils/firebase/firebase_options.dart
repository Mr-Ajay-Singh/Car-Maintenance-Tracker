import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform is not supported - you need to add web configuration',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Unsupported platform ${defaultTargetPlatform.name}',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4THyax_iy1B69FAzjKe09HdbqBggBmpA',
    appId: '1:347035330815:android:6c1d104508faa81a8c44ca',
    messagingSenderId: '347035330815',
    projectId: 'protein-tracker-741aa',
    storageBucket: 'protein-tracker-741aa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: '347035330815',
    projectId: 'protein-tracker-741aa',
    storageBucket: 'protein-tracker-741aa.firebasestorage.app',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'com.invictus.proteintracker',
  );
}
