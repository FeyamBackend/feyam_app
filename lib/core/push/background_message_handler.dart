import 'package:firebase_messaging/firebase_messaging.dart';

/// Required top-level entry point for [FirebaseMessaging.onBackgroundMessage]. The OS already
/// renders the notification banner for backgrounded/terminated apps from the payload's
/// `notification` block — nothing to do here beyond giving FCM an isolate entry point to call.
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {}
