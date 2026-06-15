enum CartFailureCode {
  unauthorized,
  networkError,
  serverError,
  unknown,
}

class CartFailure implements Exception {
  const CartFailure(this.code);

  final CartFailureCode code;
}
