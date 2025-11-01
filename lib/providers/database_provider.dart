import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';

/// Provider for the app database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
