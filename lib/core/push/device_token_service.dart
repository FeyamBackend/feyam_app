import 'dart:async';
import 'dart:io';

import 'package:feyam/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Registers/unregisters this device's FCM token with the backend, and keeps it in sync
/// across token refreshes. Depends on [NotificationsRepository] (not a raw datasource) so it
/// reuses the same auth/error handling as the rest of the notifications feature.
class DeviceTokenService {
  DeviceTokenService({required NotificationsRepository repository})
    : _repository = repository;

  final NotificationsRepository _repository;
  String? _lastKnownToken;
  StreamSubscription<String>? _refreshSubscription;

  Future<void> syncToken() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token != null) await _register(token);

    _refreshSubscription?.cancel();
    _refreshSubscription = messaging.onTokenRefresh.listen(_register);
  }

  Future<void> _register(String token) async {
    _lastKnownToken = token;
    try {
      await _repository.registerDeviceToken(
        fcmToken: token,
        platform: Platform.isIOS ? 'Ios' : 'Android',
        appVersion: null,
      );
    } catch (_) {
      // Best-effort — a failed registration just means no push until the next app open.
    }
  }

  Future<void> clearToken() async {
    await _refreshSubscription?.cancel();
    _refreshSubscription = null;

    final token = _lastKnownToken;
    _lastKnownToken = null;
    if (token == null) return;

    try {
      await _repository.unregisterDeviceToken(token);
    } catch (_) {
      // Best-effort logout cleanup — a stale token left registered just means one more
      // push the next holder of this device would silently ignore (wrong recipient copy).
    }
  }
}
