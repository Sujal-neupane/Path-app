import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:path_app/features/auth/domain/entities/user.dart';
import 'package:path_app/features/auth/domain/repository/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Uses .value or wait for future. Since AuthRemoteDataSource is FutureProvider,
  // we might need to handle it properly or use requiresValue if it's already initialized.
  // For simplicity, let's assume it's injected asynchronously.
  throw UnimplementedError();
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl({required AuthRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<String> login(String email, String password) async {
    final userModel = await _remoteDatasource.loginUser(
      email: email,
      password: password,
    );
    // Return token or id based on your application logic
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
      email: email,
      fullName: fullname,
      password: password,
      phoneNumber: phonenumber,
    );
    return 'success';
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await _remoteDatasource.getCurrentUser();
      return User(
        id: userModel.id ?? '',
        name: userModel.fullName ?? '',
        email: userModel.email,
      );
    } catch (e) {
      return null; // Not logged in or token expired
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  @override
  Future<void> logout() async {
    // Clear storage/tokens via a secure storage service
  }
}
