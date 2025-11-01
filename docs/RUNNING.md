# Running BillMint

BillMint is a mobile-first application designed for Android and iOS. This guide explains how to run the app on different platforms.

## Quick Start (Recommended)

### Option 1: Android Device (Fastest - 5 minutes)

1. Enable Developer Options on your Android phone:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. Connect your phone to your computer via USB

3. Run the app:
   ```bash
   flutter devices  # Verify device is detected
   flutter run
   ```

### Option 2: Android Emulator (45+ minutes setup)

1. Install Android Studio from https://developer.android.com/studio

2. Open Android Studio > Tools > AVD Manager

3. Create a new Virtual Device:
   - Choose a device (e.g., Pixel 5)
   - Select a system image (e.g., Android 13)
   - Finish and start the emulator

4. Run the app:
   ```bash
   flutter run
   ```

### Option 3: iOS Simulator (Mac only, 1+ hour setup)

1. Install Xcode from App Store (10+ GB download)

2. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

3. Open Xcode, agree to license, install components

4. Start iOS Simulator:
   ```bash
   open -a Simulator
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Why Web/Desktop Don't Work by Default

### Web Browsers
BillMint uses SQLite for offline-first data storage, which requires native file system access. Web browsers don't have this capability without using IndexedDB adapters (not fully implemented yet).

**Error**: "Only JS interop members may be 'external'" - SQLite FFI doesn't work in browsers

### macOS Desktop  
Requires Xcode command line tools. Also, ARM64 macOS has SQLite3 FFI compatibility issues.

**Error**: "xcrun: error: unable to find utility 'xcodebuild'"

## Platform Support Status

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Fully Supported | Recommended platform |
| iOS | ✅ Fully Supported | Requires Xcode |
| Web | 🔧 Partial | IndexedDB implementation prepared |
| macOS | 🔧 Requires Setup | Need Xcode CLI tools |
| Windows | ✅ Should Work | Not tested |
| Linux | ✅ Should Work | Not tested |

## Troubleshooting

### No devices found
```bash
flutter doctor  # Check Flutter installation
adb devices     # Check Android devices
```

### Build fails
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Emulator not starting
- Check virtualization is enabled in BIOS
- Ensure sufficient RAM (4GB+ recommended)
- Try creating a new emulator with different system image

## Next Steps

Once the app is running:
1. Explore the home screen with customer, product, and invoice sections
2. Add test customers and products
3. Create sample invoices
4. Check the settings screen to configure your business information

For development, see CONTRIBUTING.md for code guidelines.
