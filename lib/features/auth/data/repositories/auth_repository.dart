import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:path_app/features/auth/domain/entities/user.dart';
import 'package:path_app/features/auth/domain/repository/auth_repository.dart';

// Provides the concrete implementation as the abstract domain interface
// Using FutureProvider because the remote datasource may be a FutureProvider
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final remoteDatasource = await ref.watch(authRemoteDatasourceProvider.future);
  return AuthRepositoryImpl(remoteDatasource: remoteDatasource);
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl({required AuthRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<String> login(String email, String password) async {
    final userModel = await _remoteDatasource.loginUser(email: email, password: password);
    return userModel.id ?? 'success'; 
  }

  @override
  Future<String> register({
    required String fullname,
    required String email,
    required String password,
    required String phonenumber,
  }) async {
    await _remoteDatasource.registerUser(
      email: email, fullName: fullname, password: password, phoneNumber: phonenumber,
    );
    return 'success';
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await _remoteDatasource.getCurrentUser();
      return User(id: userModel.id ?? '', name: userModel.fullName, email: userModel.email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async { return false; }
  
  @override
  Future<void> requestPasswordReset(String email) async {
    await _remoteDatasource.requestPasswordReset(email);
  }

  @override
  Future<void> resetPassword(String email, String token, String newPassword) async {
    await _remoteDatasource.resetPassword(email, token, newPassword);
  }

  @override
  Future<void> logout() async { }
}
