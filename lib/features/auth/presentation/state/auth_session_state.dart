import 'package:equatable/equatable.dart';
import 'package:path_app/features/auth/domain/entities/user.dart';

class AuthSessionState extends Equatable {
  final bool isAuthenticated;
  final User? user;

  const AuthSessionState._({required this.isAuthenticated, required this.user});

  const AuthSessionState.unauthenticated()
    : this._(isAuthenticated: false, user: null);

  const AuthSessionState.authenticated(User user)
    : this._(isAuthenticated: true, user: user);

  @override
  List<Object?> get props => [isAuthenticated, user];
}
