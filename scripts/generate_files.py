#!/usr/bin/env python3
"""
BillMint Project File Generator
Generates all missing project files for the complete working state
"""

import os
import sys

PROJECT_ROOT = "/Users/ashwinsudhakar/Documents/Code/Projects/BillMint"

FILES = {
    "lib/providers/database_provider.dart": """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';

/// Provider for the app database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
""",
    
    "lib/providers/api_provider.dart": """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_service.dart';

/// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: 'http://localhost:3000');
});
""",
    
    "lib/providers/settings_provider.dart": """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import 'database_provider.dart';

/// Provider for app settings stream
final settingsProvider = StreamProvider<AppSetting?>((ref) {
  final database = ref.watch(databaseProvider);
  return database.select(database.appSettings).watchSingleOrNull();
});
""",
}

def main():
    """Generate all missing files"""
    print("🚀 Generating BillMint project files...")
    
    for filepath, content in FILES.items():
        full_path = os.path.join(PROJECT_ROOT, filepath)
        directory = os.path.dirname(full_path)
        
        # Create directory if it doesn't exist
        os.makedirs(directory, exist_ok=True)
        
        # Write file
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Created: {filepath}")
    
    print(f"\n✨ Generated {len(FILES)} files successfully!")

if __name__ == "__main__":
    main()
