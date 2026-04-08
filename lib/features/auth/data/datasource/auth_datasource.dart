import 'package:path_app/features/auth/data/models/auth_api_model.dart';

abstract interface class IAuthRemoteDataSource {
  Future<void> registerUser({
    required String email,
    required String fullName,
    required String password,
    required String phoneNumber,
  });
  Future<AuthApiModel> loginUser({
    required String email,
    required String password,
  });
  Future<AuthApiModel> getCurrentUser();
  Future<AuthApiModel> updateUser({
    String? email,
    String? fullName,
    String? password,
    String? phoneNumber,
  });
  Future<AuthApiModel> getUserById(String userId);
}