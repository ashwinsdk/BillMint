/**
 * API Configuration
 * 
 * Configure your backend server URL here.
 * After changing, rebuild the app: flutter build apk --release
 */

class ApiConfig {
  // OPTION 1: Local server (for testing on same WiFi network)
  // Find your local IP: ifconfig | grep "inet " | grep -v 127.0.0.1
  // static const String baseUrl = 'http://192.168.1.100:3000/api';

  // OPTION 2: Production server (deployed on VPS/cloud)
  // static const String baseUrl = 'http://YOUR_SERVER_IP/api';
  // static const String baseUrl = 'https://yourdomain.com/api';

  // OPTION 3: Cloud deployment (Heroku, Railway, etc.)
  // static const String baseUrl = 'https://billmint-api-yourname.herokuapp.com/api';

  // CURRENT SETTING: No backend (local-only mode)
  // Set to null to use only local SQLite database
  static const String? baseUrl = null;

  // API endpoints
  static String get customers => '$baseUrl/customers';
  static String get products => '$baseUrl/products';
  static String get invoices => '$baseUrl/invoices';
  static String get backup => '$baseUrl/backup';
  static String get health => baseUrl!.replaceAll('/api', '/health');

  // API key (if using authentication)
  static const String? apiKey = null;

  // Timeout settings
  static const Duration timeout = Duration(seconds: 30);

  // Check if backend is configured
  static bool get isConfigured => baseUrl != null && baseUrl!.isNotEmpty;
}
