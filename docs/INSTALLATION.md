# BillMint Installation Guide

This guide provides step-by-step instructions for setting up BillMint development environment and building for Android and iOS devices.

## Prerequisites for macOS

### Required Software

1. **Flutter SDK 3.9.2+**
```bash
# Download from https://flutter.dev/docs/get-started/install/macos
# Or use Homebrew
brew install --cask flutter

# Verify installation
flutter doctor
```

2. **Xcode 14+** (for iOS development)
```bash
# Install from Mac App Store
# After installation, accept license
sudo xcodebuild -license accept

# Set command line tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

3. **CocoaPods** (for iOS dependencies)
```bash
sudo gem install cocoapods
```

4. **Android Studio** (for Android development)
```bash
# Download from https://developer.android.com/studio
# Install Android SDK, Android SDK Platform-Tools, Android SDK Build-Tools

# Or set ANDROID_HOME to existing SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

5. **Node.js 18+** (for backend)
```bash
brew install node
```

## Project Setup

### 1. Clone Repository
```bash
git clone <repository-url>
cd BillMint
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Download and Place Assets

**Download Source Code Pro Font:**
1. Visit https://fonts.google.com/specimen/Source+Code+Pro
2. Click "Download family"
3. Extract ZIP file
4. Copy these files to `assets/fonts/`:
   - SourceCodePro-Regular.ttf
   - SourceCodePro-SemiBold.ttf
   - SourceCodePro-Bold.ttf

**Create or Place Logo:**
1. Create a 1024x1024px logo image
2. Save as `assets/logo.png`

### 4. Generate Database Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Generate App Icons
```bash
flutter pub run flutter_launcher_icons
```

### 6. Setup Backend
```bash
cd backend
npm install
cp .env.example .env
# Edit .env if needed
npm run migrate
cd ..
```

### 7. Run Automated Setup (Optional)
```bash
chmod +x scripts/setup_dev.sh
./scripts/setup_dev.sh
```

## Building for Android

### Setup Android Environment

1. **Install Android Studio**
   - Download from https://developer.android.com/studio
   - During installation, ensure these components are selected:
     - Android SDK
     - Android SDK Platform
     - Android SDK Build-Tools
     - Android SDK Command-line Tools

2. **Configure Android SDK in Flutter**
```bash
flutter config --android-sdk ~/Library/Android/sdk
```

3. **Accept Android Licenses**
```bash
flutter doctor --android-licenses
```

### Prepare Android Device

1. **Enable Developer Options:**
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Developer Options will appear in Settings

2. **Enable USB Debugging:**
   - Go to Settings > Developer Options
   - Enable "USB Debugging"

3. **Connect Device:**
   - Connect phone via USB cable
   - On phone, tap "Allow" when prompted to trust computer

4. **Verify Device Connection:**
```bash
flutter devices
```
Expected output:
```
Android SDK built for arm64 (mobile) • emulator-5554 • android-arm64 • Android 11 (API 30)
POCO X3 (mobile)                      • ABC123DEF456  • android-arm64 • Android 12 (API 31)
```

### Run App in Debug Mode

```bash
# Run on first available device
flutter run

# Run on specific device
flutter run -d ABC123DEF456

# Run in release mode (faster, optimized)
flutter run --release -d ABC123DEF456
```

### Build Release APK

1. **Build Unsigned APK** (for testing):
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

2. **Install APK on Device:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Build Signed APK (Production)

1. **Generate Keystore** (first time only):
```bash
keytool -genkey -v -keystore ~/billmint-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias billmint
```

Enter:
- Password (remember this!)
- Your name, organization, city, state, country

2. **Create Key Properties File:**
```bash
nano android/key.properties
```

Paste:
```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=billmint
storeFile=<path-to-keystore>
```

Example:
```properties
storePassword=mypassword123
keyPassword=mypassword123
keyAlias=billmint
storeFile=/Users/username/billmint-release-key.jks
```

3. **Configure Gradle for Signing:**

Edit `android/app/build.gradle.kts`:

Before `android {` block, add:
```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Inside `android {` block, add:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties['keyAlias']
        keyPassword = keystoreProperties['keyPassword']
        storeFile = file(keystoreProperties['storeFile'])
        storePassword = keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

4. **Build Signed APK:**
```bash
flutter build apk --release
```

5. **Install Signed APK:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Building for iOS

### Setup iOS Environment

1. **Install Xcode** from Mac App Store

2. **Install Xcode Command Line Tools:**
```bash
xcode-select --install
```

3. **Configure Xcode:**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

4. **Install CocoaPods:**
```bash
sudo gem install cocoapods
```

5. **Install iOS Pods:**
```bash
cd ios
pod install
cd ..
```

### Prepare iOS Device

1. **Connect iPhone via USB**

2. **Unlock Device and Trust Computer**
   - When prompted on iPhone, tap "Trust"
   - Enter iPhone passcode

3. **Verify Device Connection:**
```bash
flutter devices
```

Expected output:
```
iPhone 13 (mobile) • 00008030-001234567890ABCD • ios • iOS 16.0
```

### Configure Signing in Xcode

1. **Open Project in Xcode:**
```bash
open ios/Runner.xcworkspace
```

2. **Select Runner in Project Navigator**

3. **Go to Signing & Capabilities tab**

4. **Configure Team:**
   - If you have an Apple Developer account:
     - Select your team from dropdown
   - If using personal Apple ID:
     - Click "Add Account"
     - Sign in with Apple ID
     - Select your personal team

5. **Set Bundle Identifier:**
   - Change from `com.billmint.billmint` to `com.YOURNAME.billmint`
   - Must be unique

6. **Ensure "Automatically manage signing" is checked**

### Run App from Xcode

1. **Select Your Device** from device dropdown (top toolbar)

2. **Click Run button** or press `Cmd + R`

3. **First Time: Trust Developer on Device**
   - Go to Settings > General > VPN & Device Management
   - Tap your developer profile
   - Tap "Trust"

### Run App from Command Line

```bash
# Run in release mode
flutter run --release -d <device-id>

# Example
flutter run --release -d 00008030-001234567890ABCD
```

### Build IPA (Ad-Hoc Distribution)

1. **Build IPA:**
```bash
flutter build ipa --export-method ad-hoc
```

2. **Install via Xcode:**
   - Open Xcode
   - Go to Window > Devices and Simulators
   - Select your device
   - Click "+" and select IPA file
   - Or drag IPA onto device

3. **Install via ios-deploy:**
```bash
# Install ios-deploy
brew install ios-deploy

# Install IPA
ios-deploy --bundle build/ios/ipa/BillMint.ipa
```

### Build for App Store

```bash
flutter build ipa --export-method app-store
```

Upload via Xcode or Application Loader.

## Troubleshooting

### Android Issues

**Gradle Build Failed:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Device Not Detected:**
```bash
# Check ADB devices
adb devices

# Restart ADB server
adb kill-server
adb start-server
```

**USB Debugging Authorization:**
- Revoke USB debugging authorizations on phone
- Reconnect and re-authorize

### iOS Issues

**CocoaPods Issues:**
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
```

**Signing Failed:**
- Ensure bundle identifier is unique
- Check provisioning profiles in Xcode
- Try manual signing instead of automatic

**Device Not Trusted:**
- Settings > General > VPN & Device Management
- Trust your developer certificate

**Build Failed:**
```bash
cd ios
xcodebuild clean
cd ..
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

## Verify Installation

Run this checklist:

```bash
# Flutter doctor should show no issues
flutter doctor -v

# Test app runs
flutter run

# Test backend runs
cd backend
npm run migrate
npm start

# In another terminal, test API
curl http://localhost:3000/health
```

Expected output:
```json
{"success":true,"message":"BillMint API is running","timestamp":1699123456789}
```

## Next Steps

- See USAGE.md for how to use the app
- See DEVOPS.md for backend deployment
- See PERFORMANCE.md for optimization guide
- See CONTRIBUTING.md for development workflow
