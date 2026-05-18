import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return const TokenStorageService();
});

class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';

  final FlutterSecureStorage _secureStorage;

  const TokenStorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return _secureStorage.read(key: _userIdKey);
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}
