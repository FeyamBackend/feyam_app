import 'package:feyam/core/config/app_flavor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// Firebase configuration per flavor (local/dev/stg/prod), Android only so far — iOS is still
/// a PLACEHOLDER for every flavor until an iOS app is registered too (see step 4 below).
///
/// `local`/`dev`/`stg` all currently point at the same Firebase Android app (project
/// `feyam-test`, package `com.feyamuniversellc.feyam.stg` — the only one actually registered
/// in the console). This is a stopgap that works *because* bootstrap.dart calls
/// `Firebase.initializeApp(options: firebaseOptionsFor(flavor))` with explicit Dart options —
/// the SDK doesn't need a native `google-services.json` to initialize this way. The
/// `com.google.gms.google-services` Gradle plugin stays commented out in
/// android/app/build.gradle.kts for exactly this reason: it hard-fails the build unless every
/// flavor being built has its own json with a package_name matching that flavor's
/// applicationId exactly (verified — reusing one flavor's file for another breaks the build,
/// it doesn't just warn). Only `android/app/src/stg/google-services.json` exists and it's
/// unused while the plugin is off; it's kept as a reference for whenever `stg` gets registered
/// "for real" alongside the others. `prod` has no Firebase app registered at all yet.
///
/// To do this properly per flavor instead:
///   1. In the Firebase console, register an Android app (applicationId per flavor — see the
///      4 `productFlavors` in android/app/build.gradle.kts) and an iOS app (bundle id per
///      flavor — see the 4 URL schemes in ios/Runner/Info.plist) for each remaining flavor.
///      They can live in the same `feyam-test` project — no need for separate projects.
///   2. Copy that app's apiKey/appId/messagingSenderId/projectId (Firebase console → Project
///      settings → your apps) into a new `_<flavor>Android`/`_<flavor>Ios` const below, and
///      add its case to [firebaseOptionsFor].
///   3. Download `google-services.json` into `android/app/src/<flavor>/google-services.json`
///      (replacing the stopgap copy), and `GoogleService-Info.plist` into the matching iOS
///      Xcode build configuration.
///   4. For iOS: enable the Push Notifications capability and upload an APNs key/certificate
///      to the Firebase project (Project settings → Cloud Messaging → Apple app configuration).
FirebaseOptions firebaseOptionsFor(AppFlavor flavor) {
  final isApple =
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  if (isApple) return _placeholderIos;

  switch (flavor) {
    case AppFlavor.local:
    case AppFlavor.dev:
    case AppFlavor.stg:
      return _stgAndroid;
    case AppFlavor.prod:
      return _placeholderAndroid;
  }
}

// stg — project "feyam-test", from android/app/src/stg/google-services.json.
// Reused as a stopgap for local/dev too — see the class doc comment above.
const _stgAndroid = FirebaseOptions(
  apiKey: 'AIzaSyBr2ttbMbfy39A11phq20nJYKQS2leXCbg',
  appId: '1:672435011519:android:79f099acc7e26906dceb0a',
  messagingSenderId: '672435011519',
  projectId: 'feyam-test',
  storageBucket: 'feyam-test.firebasestorage.app',
);

const _placeholderAndroid = FirebaseOptions(
  apiKey: 'REPLACE_WITH_REAL_ANDROID_API_KEY',
  appId: 'REPLACE_WITH_REAL_ANDROID_APP_ID',
  messagingSenderId: 'REPLACE_WITH_REAL_SENDER_ID',
  projectId: 'REPLACE_WITH_REAL_FIREBASE_PROJECT_ID',
);

const _placeholderIos = FirebaseOptions(
  apiKey: 'REPLACE_WITH_REAL_IOS_API_KEY',
  appId: 'REPLACE_WITH_REAL_IOS_APP_ID',
  messagingSenderId: 'REPLACE_WITH_REAL_SENDER_ID',
  projectId: 'REPLACE_WITH_REAL_FIREBASE_PROJECT_ID',
  iosBundleId: 'com.feyamuniversellc.feyam',
);
