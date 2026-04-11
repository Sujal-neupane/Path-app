
import 'package:path_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<void> logout();
  Future<String> register({
    required String fullname,
    required String email,
    required String password,
    required String phonenumber
  });
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String email, String token, String newPassword);
}