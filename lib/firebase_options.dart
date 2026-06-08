// File: lib/firebase_options.dart
// Được tạo thủ công dựa trên google-services.json
// Nếu bạn có flutterfire CLI, hãy chạy: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web chưa được cấu hình.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS chưa được cấu hình.');
      default:
        throw UnsupportedError('Nền tảng không được hỗ trợ.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAo3osclBsS5FF-tb3vp8tz5vxiSO2rzuo',
    appId: '1:523495731073:android:cb58d9ce193a8072b7c280',
    messagingSenderId: '523495731073',
    projectId: 'thongtinbenhnhan-8ab9b',
    storageBucket: 'thongtinbenhnhan-8ab9b.firebasestorage.app',
  );
}
