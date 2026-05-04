import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  const AuthUserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, createdAt];
}