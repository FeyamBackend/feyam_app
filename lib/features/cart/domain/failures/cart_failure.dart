enum CartFailureCode {
  unauthorized,
  sessionExpired,
  networkError,
  serverError,

  /// The cart already produced a live order awaiting payment (HTTP 409) —
  /// retrying the submit can't succeed on its own; the customer needs to pay
  /// or resolve that order first.
  pendingOrder,
  unknown,
}

class CartFailure implements Exception {
  const CartFailure(this.code);

  final CartFailureCode code;
}
