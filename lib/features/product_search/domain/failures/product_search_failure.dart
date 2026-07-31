enum ProductSearchFailureCode {
  sessionExpired,
  networkError,
  serverError,
  unknown,
}

class ProductSearchFailure implements Exception {
  const ProductSearchFailure(this.code);

  final ProductSearchFailureCode code;
}
