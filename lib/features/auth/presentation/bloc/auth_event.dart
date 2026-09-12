part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInPressed extends AuthEvent {}

class SignUpPressed extends AuthEvent {}

class SignOutPressed extends AuthEvent {}

class AuthSessionChecked extends AuthEvent {}

class SessionExpired extends AuthEvent {}

/// App volvió de background mientras había una sesión activa. Dispara un
/// refresh proactivo (en vez de esperar al próximo 401) para detectar una
/// sesión SSO/offline muerta apenas se reabre la app.
class AppResumed extends AuthEvent {}
