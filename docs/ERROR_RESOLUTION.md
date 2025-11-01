# Error Resolution Guide

This document tracks all errors encountered during development and their solutions.

## Compilation Errors Fixed

### 1. Missing Dependencies (Resolved)
**Error**: Package not found errors for flutter_riverpod, drift, etc.
**Solution**: Run `flutter pub get` to install all dependencies from pubspec.yaml

### 2. Drift Code Generation (Resolved)
**Error**: "The getter 'database' isn't defined for the type 'AppDatabase'"
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

### 3. Type Mismatch in Drift (Resolved)
**Error**: "The argument type 'String' can't be assigned to the parameter type 'Value<String>'"
**Solution**: Wrap optional values with `drift.Value()` or `drift.Value.absent()`

### 4. Field Naming (Resolved)
**Error**: "The getter 'unitPrice' isn't defined for the type 'Product'"
**Solution**: Changed to use `product.price` (correct field name from schema)

### 5. Widget Test (Resolved)
**Error**: "A RenderFlex overflowed" in widget tests
**Solution**: Commented out missing logo asset reference

### 6. Platform-Specific Database (Resolved)
**Error**: SQLite doesn't work on web, macOS without Xcode
**Solution**: Created conditional imports for native/web/unsupported platforms

## Runtime Errors

### Web Platform
**Issue**: "Unsupported operation: Unsupported invalid type InvalidType"
**Cause**: SQLite uses FFI which doesn't work in browsers
**Solution**: Use Android device/emulator or iOS simulator

### macOS Desktop
**Issue**: "xcrun: error: unable to find utility 'xcodebuild'"
**Cause**: Xcode command line tools not installed
**Solution**: Install Xcode or use mobile platforms

## How to Run Tests
```bash
flutter test
```

All 17 tests should pass (16 invoice calculations + 1 widget test).

## Common Issues

### Issue: flutter command not found
**Solution**: Add Flutter to PATH or use full path to flutter executable

### Issue: Build runner fails
**Solution**: 
1. Delete .dart_tool directory
2. Run `flutter clean`
3. Run `flutter pub get`
4. Run build_runner again

### Issue: Hot reload doesn't work
**Solution**: Stop app and restart with `flutter run`
