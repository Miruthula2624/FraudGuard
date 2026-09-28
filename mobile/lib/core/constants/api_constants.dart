/// Target environment for local development
enum ApiEnvironment {
  emulator,
  physicalDevice,
}

/// Central API Configuration for FraudGuard Mobile
class ApiConstants {
  // Toggle this to easily switch between Android Emulator and Physical Device
  static const ApiEnvironment currentEnvironment = ApiEnvironment.physicalDevice;

  // Development host definitions
  static const String emulatorHost = 'http://10.0.2.2:5000/api';
  static const String physicalDeviceHost = 'https://fraudguard-backend-86n8.onrender.com/api';

  /// Active base URL based on the selected environment
  static String get baseUrl {
    switch (currentEnvironment) {
      case ApiEnvironment.emulator:
        return emulatorHost;
      case ApiEnvironment.physicalDevice:
        return physicalDeviceHost;
    }
  }

  static ApiEnvironment get currentEnv => currentEnvironment;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Authentication Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String checkSessionEndpoint = '/auth/check-session';

  // Scanner Endpoints
  static const String scanTextEndpoint = '/scan/text';
  static const String scanFileEndpoint = '/scan/file';
  static const String mlStatusEndpoint = '/scan/ml-status';

  // History Endpoints
  static const String historyEndpoint = '/history';
  static String deleteHistoryEndpoint(int id) => '/history/$id';
}
