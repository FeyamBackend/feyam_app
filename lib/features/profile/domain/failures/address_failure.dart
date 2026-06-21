enum AddressFailureCode {
  unauthorized,
  sessionExpired,
  networkError,
  serverError,
  notFound,
  unknown,
}

class AddressFailure implements Exception {
  const AddressFailure(this.code);

  final AddressFailureCode code;
}
