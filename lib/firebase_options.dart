import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
   apiKey: "AIzaSyDCbURZrM1VSorZEElfafmGqr8lyP2nrHA",
  authDomain: "flutterapps-df7fa.firebaseapp.com",
  projectId: "flutterapps-df7fa",
  storageBucket: "flutterapps-df7fa.firebasestorage.app",
  messagingSenderId: "181892874442",
  appId: "1:181892874442:web:44edea2b60536661123433",
  measurementId: "G-S2694F9FQ6"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: '1:181892874442:android:12c6374ee01265fe123433',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'YOUR-IOS-BUNDLE-ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyDCbURZrM1VSorZEElfafmGqr8lyP2nrHA",
  authDomain: "flutterapps-df7fa.firebaseapp.com",
  projectId: "flutterapps-df7fa",
  storageBucket: "flutterapps-df7fa.firebasestorage.app",
  messagingSenderId: "181892874442",
  appId: "1:181892874442:web:f6d7ea9e87cbc804123433",
  measurementId: "G-WHG9FPETH8"
  );
} 