import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsyZCwALWa0ZWZr_kMbYxCbRp7zTFmidQ',
    appId: '1:313628007425:ios:6c1316aaa58b97d5c97400',
    messagingSenderId: '313628007425',
    projectId: 'lumina-zilei',
    storageBucket: 'lumina-zilei.firebasestorage.app',
    iosBundleId: 'com.alinciubotariu.luminazilei',
  );
}
