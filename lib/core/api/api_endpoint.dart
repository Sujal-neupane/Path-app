
class ApiEndpoints {
  ApiEndpoints._();


  static const String apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (apiBaseUrlOverride.isNotEmpty) {
      return apiBaseUrlOverride;
    }
    return 'http://127.0.0.1:5999'; // Use 127.0.0.1 for local backend
  }

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);


// Auth Endpoints
  static const String userLogin = '/auth/login';
  static const String userById = '/auth/user/{id}'; // Endpoint to fetch user by ID, e.g., /auth/user/{id}
  static const String userRegister = '/auth/register';
  static const String userUpdate = '/auth/update';
  static const String requestPasswordReset = '/auth/request-password-reset';
  static const String resetPassword = '/auth/reset-password';
  static const String currentUser = '/auth/me';

}