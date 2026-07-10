// File diadaptasi dari hasil FlutterFire CLI.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARc3S2uLcwqhJRa7IOi-83xqL4ZrCeDco',
    appId: '1:565645798732:android:7ba8ffc3578b659ce7f3e9',
    messagingSenderId: '565645798732',
    projectId: 'devadarlaundrydb',
    storageBucket: 'devadarlaundrydb.firebasestorage.app',
  );

  /// Opsi untuk Web Chrome / Edge.
  /// Diperlukan untuk menjalankan di browser.
  /// Dapatkan dari Firebase Console → Project Settings → Web App.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyARc3S2uLcwqhJRa7IOi-83xqL4ZrCeDco',
    appId: '1:565645798732:web:PLACEHOLDER',
    messagingSenderId: '565645798732',
    projectId: 'devadarlaundrydb',
    authDomain: 'devadarlaundrydb.firebaseapp.com',
    storageBucket: 'devadarlaundrydb.firebasestorage.app',
  );
}
