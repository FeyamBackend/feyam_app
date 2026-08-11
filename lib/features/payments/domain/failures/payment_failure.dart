enum PaymentFailureCode {
  unauthorized,
  sessionExpired,
  cancelled,
  networkError,
  serverError,
  notFound,
  unknown,
}

class PaymentFailure implements Exception {
  const PaymentFailure(this.code);

  final PaymentFailureCode code;
}
