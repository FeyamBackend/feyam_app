import 'dart:convert';

import 'package:feyam/features/notifications/data/models/notifications_page_model.dart';
import 'package:http/http.dart' as http;

class NotificationsUnauthorizedException implements Exception {
  const NotificationsUnauthorizedException();
}

class NotificationsServerException implements Exception {
  const NotificationsServerException(this.statusCode);

  final int statusCode;
}

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource({
    required http.Client client,
    required String apiBaseUrl,
  }) : _client = client,
       _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  Future<NotificationsPageModel> getNotifications({
    required int skip,
    required int take,
  }) async {
    final uri = Uri.parse(
      '$_apiBaseUrl/api/notifications?skip=$skip&take=$take',
    );

    final response = await _client.get(uri);

    if (response.statusCode == 401) {
      throw const NotificationsUnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw NotificationsServerException(response.statusCode);
    }

    return NotificationsPageModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<int> getUnreadCount() async {
    final uri = Uri.parse('$_apiBaseUrl/api/notifications/unread-count');

    final response = await _client.get(uri);

    if (response.statusCode == 401) {
      throw const NotificationsUnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw NotificationsServerException(response.statusCode);
    }

    return jsonDecode(response.body) as int;
  }

  Future<void> markNotificationRead(String notificationId) async {
    final uri = Uri.parse(
      '$_apiBaseUrl/api/notifications/$notificationId/read',
    );

    final response = await _client.post(uri);

    if (response.statusCode == 401) {
      throw const NotificationsUnauthorizedException();
    }
    if (response.statusCode >= 300) {
      throw NotificationsServerException(response.statusCode);
    }
  }

  Future<void> markAllNotificationsRead() async {
    final uri = Uri.parse('$_apiBaseUrl/api/notifications/read-all');

    final response = await _client.post(uri);

    if (response.statusCode == 401) {
      throw const NotificationsUnauthorizedException();
    }
    if (response.statusCode >= 300) {
      throw NotificationsServerException(response.statusCode);
    }
  }

  Future<void> registerDeviceToken({
    required String fcmToken,
    required String platform,
    String? appVersion,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/api/notifications/devices');

    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fcmToken': fcmToken,
        'platform': platform,
        'appVersion': appVersion,
      }),
    );

    if (response.statusCode == 401) {
      throw const NotificationsUnauthorizedException();
    }
    if (response.statusCode >= 300) {
      throw NotificationsServerException(response.statusCode);
    }
  }

  Future<void> unregisterDeviceToken(String fcmToken) async {
    final uri = Uri.parse('$_apiBaseUrl/api/notifications/devices/unregister');

    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode == 401) {
      throw const NotificationsUnauthorizedException();
    }
    if (response.statusCode >= 300) {
      throw NotificationsServerException(response.statusCode);
    }
  }
}
