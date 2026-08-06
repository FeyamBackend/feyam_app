enum NotificationsFailureCode {
  unauthorized,
  sessionExpired,
  networkError,
  serverError,
  unknown,
}

class NotificationsFailure implements Exception {
  const NotificationsFailure(this.code);

  final NotificationsFailureCode code;
}
