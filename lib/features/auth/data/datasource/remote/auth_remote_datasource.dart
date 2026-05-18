import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';
import 'package:path_app/core/storage/token_storage_sevice.dart';
import 'package:path_app/features/auth/data/models/auth_api_model.dart';

final authRemoteDatasourceProvider = FutureProvider<AuthRemoteDatasource>((
  ref,
) async {
  return AuthRemoteDataSourceImpl(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenStorageServiceProvider),
  );
});

abstract class AuthRemoteDatasource {
  Future<AuthApiModel?> registerUser({
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

  AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
    required TokenStorageService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel> getUserById(String authId) async {
    final endpoint = ApiEndpoints.userById.replaceFirst('{id}', authId);
    final response = await _apiClient.get(endpoint);
    final payload = _asMap(response.data);
    final data = _extractDataMap(payload);
    if (response.statusCode == 200 && data != null) {
      return AuthApiModel.fromJson(data);
    }
    throw Exception(_message(payload, 'Failed to fetch user data'));
  }

  @override
  Future<AuthApiModel> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );

    final payload = _asMap(response.data);
    final token = _extractToken(payload);
    final userMap = _extractUserMap(payload);

    if (response.statusCode == 200 && token != null && userMap != null) {
      _apiClient.setAuthToken(token);
      await _tokenService.saveToken(token);

      final user = AuthApiModel.fromJson(userMap);
      if (user.id != null && user.id!.isNotEmpty) {
        await _tokenService.saveUserId(user.id!);
      }
      return user;
    }

    throw Exception(_message(payload, 'Login failed'));
  }

  @override
  Future<AuthApiModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.currentUser);
    final payload = _asMap(response.data);
    final userMap = _extractUserMap(payload) ?? _extractDataMap(payload);

    if (response.statusCode == 200 && userMap != null) {
      return AuthApiModel.fromJson(userMap);
    }

    throw Exception(_message(payload, 'Failed to get current user'));
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.requestPasswordReset,
      data: {'email': email},
    );
    final payload = _asMap(response.data);
    if (response.statusCode != 200) {
      throw Exception(_message(payload, 'Failed to request password reset'));
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {'email': email, 'token': token, 'newPassword': newPassword},
    );
    final payload = _asMap(response.data);
    if (response.statusCode != 200) {
      throw Exception(_message(payload, 'Failed to reset password'));
    }
  }

  @override
  Future<AuthApiModel?> registerUser({
    required String email,
    required String fullName,
    required String password,
    required String phoneNumber,
  }) async {
    final authModel = AuthApiModel(
      email: email,
      fullName: fullName,
      password: password,
      phoneNumber: phoneNumber,
    );

    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: authModel.toJson(),
    );

    final payload = _asMap(response.data);
    final token = _extractToken(payload);
    final userMap = _extractUserMap(payload) ?? _extractDataMap(payload);

    final isSuccessStatus =
        response.statusCode == 201 || response.statusCode == 200;
    if (!isSuccessStatus) {
      throw Exception(_message(payload, 'Registration failed'));
    }

    if (token != null && token.isNotEmpty) {
      _apiClient.setAuthToken(token);
      await _tokenService.saveToken(token);
    }

    if (userMap == null) {
      return null;
    }

    final user = AuthApiModel.fromJson(userMap);
    if (user.id != null && user.id!.isNotEmpty) {
      await _tokenService.saveUserId(user.id!);
    }
    return user;
  }

  @override
  Future<AuthApiModel> updateUser({
    String? email,
    String? fullName,
    String? password,
    String? phoneNumber,
  }) async {
    final Map<String, dynamic> data = {};
    if (email != null) data['email'] = email;
    if (fullName != null) data['fullName'] = fullName;
    if (password != null) data['password'] = password;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;

    final response = await _apiClient.put(ApiEndpoints.userUpdate, data: data);
    final payload = _asMap(response.data);
    final userMap = _extractUserMap(payload) ?? _extractDataMap(payload);
    if (response.statusCode == 200 && userMap != null) {
      return AuthApiModel.fromJson(userMap);
    }
    throw Exception(_message(payload, 'Failed to update user'));
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic>? _extractDataMap(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> payload) {
    final dataMap = _extractDataMap(payload);
    final nestedUser = dataMap?['user'];
    if (nestedUser is Map<String, dynamic>) return nestedUser;
    if (nestedUser is Map) return Map<String, dynamic>.from(nestedUser);
    return dataMap;
  }

  String? _extractToken(Map<String, dynamic> payload) {
    final dataMap = _extractDataMap(payload);
    final topLevelToken = payload['token'];
    if (topLevelToken is String && topLevelToken.isNotEmpty) {
      return topLevelToken;
    }

    final nestedToken = dataMap?['token'];
    if (nestedToken is String && nestedToken.isNotEmpty) return nestedToken;
    return null;
  }

  String _message(Map<String, dynamic> payload, String fallback) {
    final message = payload['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
