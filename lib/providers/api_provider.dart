import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_service.dart';

/// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: 'http://localhost:3000');
});
