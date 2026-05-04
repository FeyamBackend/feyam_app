part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInPressed extends AuthEvent {}

class SignOutPressed extends AuthEvent {}

class AuthSessionChecked extends AuthEvent {}
