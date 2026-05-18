import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/storage/token_storage_sevice.dart';
import 'package:path_app/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:path_app/features/auth/data/models/auth_api_model.dart';
import 'package:path_app/features/auth/domain/entities/user.dart';
import 'package:path_app/features/auth/domain/repository/auth_repository.dart';

// Provides the concrete implementation as the abstract domain interface
// Using FutureProvider because the remote datasource may be a FutureProvider
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final remoteDatasource = await ref.watch(authRemoteDatasourceProvider.future);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(
    remoteDatasource: remoteDatasource,
    tokenStorage: tokenStorage,
    apiClient: apiClient,
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final TokenStorageService _tokenStorage;
  final ApiClient _apiClient;

  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required TokenStorageService tokenStorage,
    required ApiClient apiClient,
  }) : _remoteDatasource = remoteDatasource,
       _tokenStorage = tokenStorage,
       _apiClient = apiClient;

  @override
  Future<User> login(String email, String password) async {
    final userModel = await _remoteDatasource.loginUser(
      email: email,
      password: password,
    );
    final user = _toUser(userModel);
    if (user.id != null && user.id!.isNotEmpty) {
      await _tokenStorage.saveUserId(user.id!);
    }
    return user;
  }

  @override
  Future<User?> register({
    required String fullname,
    required String email,
    required String password,
    required String phonenumber,
  }) async {
    final userModel = await _remoteDatasource.registerUser(
      email: email,
      fullName: fullname,
      password: password,
      phoneNumber: phonenumber,
    );
    if (userModel == null) return null;

    final user = _toUser(userModel);
    if (user.id != null && user.id!.isNotEmpty) {
      await _tokenStorage.saveUserId(user.id!);
    }
    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    final hasSession = await isLoggedIn();
    if (!hasSession) {
      return null;
    }

    final userModel = await _remoteDatasource.getCurrentUser();
    final user = _toUser(userModel);
    if (user.id != null && user.id!.isNotEmpty) {
      await _tokenStorage.saveUserId(user.id!);
    }
    return user;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _tokenStorage.hasToken();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _remoteDatasource.requestPasswordReset(email);
  }

  @override
  Future<void> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    await _remoteDatasource.resetPassword(email, token, newPassword);
  }

  @override
  Future<void> logout() async {
    _apiClient.removeAuthToken();
    await _tokenStorage.clearAuthData();
  }

  User _toUser(AuthApiModel model) {
    return User(
      id: model.id,
      name: model.fullName,
      email: model.email,
      phoneNumber: model.phoneNumber,
    );
  }
}
