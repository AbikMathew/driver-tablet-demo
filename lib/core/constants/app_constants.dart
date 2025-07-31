class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://your-api-base-url.com/api';
  static const String authRequestOtp = '/auth/request-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String scheduleWeekUpdate = '/schedule/week/update';
  static const String scheduleDayUpdate = '/schedule/day/update';
  static const String scheduleDefaults = '/schedule/defaults';

  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userDataKey = 'user_data';
  static const String routeDataKey = 'route_data';
  static const String scheduleDataKey = 'schedule_data';

  // Hive Box Names
  static const String authBoxName = 'auth_box';
  static const String formsBoxName = 'forms_box';
  static const String routeBoxName = 'route_box';
  static const String settingsBoxName = 'settings_box';

  // Map Configuration
  static const String osmTileUrlTemplate =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String mapboxTileUrlTemplate =
      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}';

  // Cache Settings
  static const int tileCacheExpiryHours = 48;
  static const int routeCacheExpiryHours = 24;
  static const int formCacheMaxAge = 7; // days

  // OTP Settings
  static const int otpResendCooldownSeconds = 30;
  static const int maxOtpRetries = 3;
  static const int otpLength = 6;

  // Location Settings
  static const double defaultLocationAccuracy = 10.0; // meters
  static const int locationUpdateIntervalMs = 5000; // 5 seconds
  static const double significantLocationChangeMeters = 50.0;

  // Navigation
  static const String routeActiveDeepLink = 'myapp://route/active';

  // Tablet Breakpoints
  static const double tabletBreakpoint = 768.0;
  static const double largeTabletBreakpoint = 1024.0;

  // Touch Target Sizes (following Apple Human Interface Guidelines)
  static const double minTouchTarget = 44.0;
  static const double recommendedTouchTarget = 48.0;
}
