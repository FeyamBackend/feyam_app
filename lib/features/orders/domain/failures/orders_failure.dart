enum OrdersFailureCode {
  unauthorized,
  sessionExpired,
  networkError,
  serverError,
  notFound,
  unknown,
}

class OrdersFailure implements Exception {
  const OrdersFailure(this.code);

  final OrdersFailureCode code;
}
