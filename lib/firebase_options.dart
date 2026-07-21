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
        return windows;
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
    apiKey: 'AIzaSyDEcxTCLy1-AxORVUqTfUVpoZirq4viOI4',
    appId: '1:365881480617:web:c51b1ec5a684cb499da0b8',
    messagingSenderId: '365881480617',
    projectId: 'purse-maison-5127b',
    authDomain: 'purse-maison-5127b.firebaseapp.com',
    storageBucket: 'purse-maison-5127b.firebasestorage.app',
    measurementId: 'G-RLRJY6JW57',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBckv6vYkG79fA81Bl7F4KbvSZL9XzCsvM',
    appId: '1:365881480617:android:10ecd87c3372599e9da0b8',
    messagingSenderId: '365881480617',
    projectId: 'purse-maison-5127b',
    storageBucket: 'purse-maison-5127b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxTC39XLX9H_1VQkyu5-rSdB5TR-LiFOg',
    appId: '1:365881480617:ios:dc3ba2923c54267c9da0b8',
    messagingSenderId: '365881480617',
    projectId: 'purse-maison-5127b',
    storageBucket: 'purse-maison-5127b.firebasestorage.app',
    iosBundleId: 'com.example.purseMaison',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCxTC39XLX9H_1VQkyu5-rSdB5TR-LiFOg',
    appId: '1:365881480617:ios:dc3ba2923c54267c9da0b8',
    messagingSenderId: '365881480617',
    projectId: 'purse-maison-5127b',
    storageBucket: 'purse-maison-5127b.firebasestorage.app',
    iosBundleId: 'com.example.purseMaison',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDEcxTCLy1-AxORVUqTfUVpoZirq4viOI4',
    appId: '1:365881480617:web:490a8d15f473e0ac9da0b8',
    messagingSenderId: '365881480617',
    projectId: 'purse-maison-5127b',
    authDomain: 'purse-maison-5127b.firebaseapp.com',
    storageBucket: 'purse-maison-5127b.firebasestorage.app',
    measurementId: 'G-D46F7X3WQB',
  );
}
