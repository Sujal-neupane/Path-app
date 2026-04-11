
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';
import 'package:path_app/core/storage/token_storage_sevice.dart';
import 'package:path_app/features/auth/data/models/auth_api_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenStorageServiceProvider = FutureProvider<TokenStorageService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return TokenStorageService(prefs);
});

final authRemoteDatasourceProvider = FutureProvider<AuthRemoteDatasource>((ref) async {
  return AuthRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider), tokenService: await ref.read(tokenStorageServiceProvider.future));
});

abstract class AuthRemoteDatasource {
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
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String email, String token, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDatasource {
  final ApiClient _apiClient;
  final TokenStorageService _tokenService;

  AuthRemoteDataSourceImpl({required ApiClient apiClient, required TokenStorageService tokenService})
      : _apiClient = apiClient,
        _tokenService = tokenService;

        @override 
        Future<AuthApiModel> getUserById(String authId) async {
          try{
            final response = await _apiClient.get(ApiEndpoints.userById);

            if (response.statusCode ==200){
              if(response.data ['success'] == true){
                final data = response.data['data'] as Map<String, dynamic>;
                return AuthApiModel.fromJson(data);
              }
            }
            throw Exception('Failed to fetch user data');
          } catch (e){
            throw Exception('Error fetching user data: $e');
            
          }
        }
        

        @override  
        Future<AuthApiModel> loginUser({required String email, required String password}) async {
          try{
            final response = await _apiClient.post(ApiEndpoints.userLogin, data: {
              'email': email,
              'password': password,
            });

            if (response.statusCode == 200){
              if(response.data['success'] == true){
                final responseData = response.data['data'] as Map<String, dynamic>;
                final token = responseData['token'] as String;
                final userData = responseData['user'] as Map<String, dynamic>;
                
                final loggedInUser = AuthApiModel.fromJson(userData);
                
                _apiClient.setAuthToken(token);
                await _tokenService.saveToken(token);
                
                return loggedInUser;
              }
            }
            throw Exception(response.data['message'] ?? 'Login failed');
          } catch (e) {
            throw Exception('Login failed: ${e.toString()}');
          }
        }

  @override
  Future<AuthApiModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.currentUser);

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final data = response.data['data'] as Map<String, dynamic>;
          return AuthApiModel.fromJson(data);
        }
      }
      throw Exception('Failed to get current user');
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.requestPasswordReset, data: {
        'email': email,
      });

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to request reset');
      }
    } catch (e) {
      throw Exception('Password reset request error: $e');
    }
  }

  @override
  Future<void> resetPassword(String email, String token, String newPassword) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.resetPassword, data: {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      });

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception('Password reset execution error: $e');
    }
  }

  @override
  Future<void> registerUser({
    required String email,
    required String fullName,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final authModel = AuthApiModel(
        email: email,
        fullName: fullName,
        password: password,
        phoneNumber: phoneNumber,
      );
      final response = await _apiClient.post(ApiEndpoints.userRegister, data: authModel.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['success'] == true) {
          // Set auth token if available - token is at root level in response
          if (response.data['token'] != null) {
            _apiClient.setAuthToken(response.data['token']);

            // Save token to storage for later use
            final prefs = await SharedPreferences.getInstance();
            final tokenService = TokenStorageService(prefs);
            await tokenService.saveToken(response.data['token']);
          }
          return;
        }
      }
      throw Exception(response.data['message'] ?? 'Registration failed');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthApiModel> updateUser({
    String? email,
    String? fullName,
    String? password,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (email != null) data['email'] = email;
      if (fullName != null) data['fullName'] = fullName;
      if (password != null) data['password'] = password;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;

      final response = await _apiClient.put(ApiEndpoints.userUpdate, data: data);
      
      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final userData = response.data['data'] as Map<String, dynamic>;
          return AuthApiModel.fromJson(userData);
        }
      }
      throw Exception('Failed to update user');
    } catch (e) {
      throw Exception('Update user failed: ${e.toString()}');
    }
  }
}
  