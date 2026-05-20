import 'package:firebase_core/firebase_core.dart' as core;

class FirebaseOptions extends core.FirebaseOptions {
    static const FirebaseOptions current = FirebaseOptions(
    apiKey: 'AIzaSyCZodvIf1T2oEAslDiA_AkhDXx1vx9kOqs',
    appId: '1:1019950249179:android:6d0ecaec1224e250ac48fe',
    messagingSenderId: '1019950249179',
    projectId: 'pharmacy-32ac4',
    storageBucket: 'pharmacy-32ac4.firebasestorage.app',
  );

  const FirebaseOptions({
    required super.apiKey,
    required super.appId,
    required super.messagingSenderId,
    required super.projectId,
    required super.storageBucket,
  });
}