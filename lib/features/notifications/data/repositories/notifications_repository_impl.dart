import 'dart:io';

import 'package:feyam/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:feyam/features/notifications/domain/entities/notifications_page.dart';
import 'package:feyam/features/notifications/domain/failures/notifications_failure.dart';
import 'package:feyam/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<NotificationsPage> getNotifications({
    required int skip,
    required int take,
  }) =>
      _guard(() => _remoteDataSource.getNotifications(skip: skip, take: take));

  @override
  Future<int> getUnreadCount() =>
      _guard(() => _remoteDataSource.getUnreadCount());

  @override
  Future<void> markNotificationRead(String notificationId) =>
      _guard(() => _remoteDataSource.markNotificationRead(notificationId));

  @override
  Future<void> markAllNotificationsRead() =>
      _guard(() => _remoteDataSource.markAllNotificationsRead());

  @override
  Future<void> registerDeviceToken({
    required String fcmToken,
    required String platform,
    String? appVersion,
  }) => _guard(
    () => _remoteDataSource.registerDeviceToken(
      fcmToken: fcmToken,
      platform: platform,
      appVersion: appVersion,
    ),
  );

  @override
  Future<void> unregisterDeviceToken(String fcmToken) =>
      _guard(() => _remoteDataSource.unregisterDeviceToken(fcmToken));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on NotificationsUnauthorizedException {
      throw const NotificationsFailure(NotificationsFailureCode.sessionExpired);
    } on NotificationsServerException {
      throw const NotificationsFailure(NotificationsFailureCode.serverError);
    } on SocketException {
      throw const NotificationsFailure(NotificationsFailureCode.networkError);
    } catch (_) {
      throw const NotificationsFailure(NotificationsFailureCode.unknown);
    }
  }
}
