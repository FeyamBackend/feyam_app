enum AuthFailureCode {
  invalidEmail,
  invalidCredential,
  userDisabled,
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  operationNotAllowed,
  tooManyRequests,
  accountExistsWithDifferentCredential,
  networkRequestFailed,
  cancelled,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthFailureCode code;
}