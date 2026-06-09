import 'package:path_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> register({
    required String fullname,
    required String email,
    required String password,
    required String phonenumber,
  });
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
  Future<String?> requestPasswordReset(String email);
  Future<void> resetPassword(String email, String token, String newPassword);
}
