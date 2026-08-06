import 'package:feyam/core/config/app_flavor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// PLACEHOLDER Firebase configuration — these are not real credentials and push will not
/// work until this file is replaced. Required manual setup, once per flavor (local/dev/stg/prod):
///
///   1. In the Firebase console, create one project and register an Android app (applicationId
///      per flavor — see the 4 `productFlavors` in android/app/build.gradle.kts) and an iOS app
///      (bundle id per flavor — see the 4 URL schemes in ios/Runner/Info.plist) for each flavor.
///   2. Run the FlutterFire CLI once per flavor, e.g.:
///        flutterfire configure --out=lib/core/config/firebase_options_dev.dart --project=PROJECT_ID
///      and update [firebaseOptionsFor] below to return that flavor's generated
///      `DefaultFirebaseOptions.currentPlatform` instead of this placeholder.
///   3. Download `google-services.json` into `android/app/src/<flavor>/google-services.json`,
///      and `GoogleService-Info.plist` into the matching iOS Xcode build configuration.
///   4. For iOS: enable the Push Notifications capability and upload an APNs key/certificate
///      to the Firebase project (Project settings → Cloud Messaging → Apple app configuration).
FirebaseOptions firebaseOptionsFor(AppFlavor flavor) {
  final isApple =
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
  return isApple ? _placeholderIos : _placeholderAndroid;
}

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
