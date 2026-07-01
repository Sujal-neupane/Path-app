
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

  // Dashboard Endpoints
  static const String dashboardOverview = '/dashboard/overview';

  // SOS Endpoint
  static const String sosAlert = '/sos';
  static const String sosHistory = '/sos/my';
  static const String sosById = '/sos/{id}';

  // Trek Endpoints
  static const String treksList = '/treks';
  static const String trekById = '/treks/{id}';
  static const String trekSummary = '/treks/{id}/summary';
  static const String trekGpsTrack = '/treks/{id}/gps-track';

  // Weather Endpoint
  static const String weather = '/weather';
  static const String weatherByCoords = '/weather/coords';

  // Community Endpoints
  static const String communityFeed = '/community/feed';
  static const String communityPosts = '/community/posts';
  static const String communityLike = '/community/posts/{id}/like';
  static const String communityComment = '/community/posts/{id}/comments';

  // Gear Endpoints
  static const String gearList = '/gear';

  // Journal Endpoints
  static const String journalList = '/journal';

  // AI Guide Endpoints
  static const String aiChat = '/ai/chat';
  static const String aiTips = '/ai/tips';

  // Leaderboard Endpoints
  static const String leaderboard = '/leaderboard';

  // Permit Endpoints
  static const String permits = '/permits';
  static const String permitsCheckout = '/permits/checkout';

  // Maps Endpoints
  static const String mapsGeocode = '/maps/geocode';
  static const String mapsNearbyTrails = '/maps/trails/nearby';
  static const String mapsElevation = '/maps/elevation';

  // Profile Endpoints
  static const String profile = '/profile';

  /// Helper to substitute path parameters.
  /// e.g. ApiEndpoints.withId(ApiEndpoints.trekById, '123') => '/treks/123'
  static String withId(String template, String id) {
    return template.replaceFirst('{id}', id);
  }
}