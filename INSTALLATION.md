# Installation Guide

Complete installation and setup guide for BillMint invoice management system.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Mobile App Setup](#mobile-app-setup)
3. [Backend Server Setup](#backend-server-setup)
4. [Device Installation](#device-installation)
5. [Configuration](#configuration)
6. [Deployment](#deployment)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

**For Mobile Development:**
- Flutter SDK 3.35.7 or higher
- Dart SDK 3.9.2 or higher
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- Git

**For Backend Development:**
- Node.js 18.0.0 or higher
- npm 9.0.0 or higher

### System Requirements

**Development Machine:**
- macOS 15.6+, Windows 10+, or Linux (Ubuntu 20.04+)
- 8GB RAM minimum (16GB recommended)
- 10GB free disk space

**Target Devices:**
- Android 5.0 (API 21) or higher
- iOS 12.0 or higher

## Mobile App Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/ashwinsdk/BillMint.git
cd BillMint
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

This will install all required packages:
- flutter_riverpod (state management)
- drift (database)
- pdf (PDF generation)
- intl (internationalization)
- And other dependencies

### Step 3: Verify Installation

```bash
flutter doctor
```

Ensure all required components are installed. Fix any issues reported.

### Step 4: Run in Debug Mode

**Connect an Android device or emulator:**
```bash
flutter devices
flutter run
```

**For specific device:**
```bash
flutter run -d <device-id>
```

### Step 5: Build Release APK

**Build for all architectures:**
```bash
flutter build apk --release
```

**Build optimized APKs (recommended):**
```bash
flutter build apk --release --split-per-abi
```

This generates three APK files:
- `app-arm64-v8a-release.apk` (20.5MB) - Modern Android devices
- `app-armeabi-v7a-release.apk` (18.4MB) - Older Android devices
- `app-x86_64-release.apk` (21.8MB) - Emulators and tablets

Output location: `build/app/outputs/flutter-apk/`

## Backend Server Setup

The backend server is optional and required only for multi-device synchronization.

### Step 1: Navigate to Backend Directory

```bash
cd backend
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Configure Environment

Create `.env` file:
```bash
cp .env.example .env
```

Edit `.env`:
```
PORT=3000
DB_PATH=./data/billmint.sqlite
NODE_ENV=development
```

### Step 4: Initialize Database

```bash
node src/migrate.js
```

This creates the SQLite database with required tables.

### Step 5: Start Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

### Step 6: Verify Server

Test the health endpoint:
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "success": true,
  "message": "BillMint API is running",
  "timestamp": 1762071475057
}
```

## Device Installation

### Android Installation

**Method 1: USB Installation (Recommended)**

1. Enable USB debugging on Android device:
   - Settings > About Phone > Tap "Build Number" 7 times
   - Settings > Developer Options > Enable USB Debugging

2. Connect device via USB

3. Verify connection:
   ```bash
   adb devices
   ```

4. Install APK:
   ```bash
   adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
   ```

**Method 2: Manual Installation**

1. Transfer APK to device (USB, Bluetooth, cloud storage)
2. On device: Settings > Security > Enable "Install from Unknown Sources"
3. Open APK file and tap Install

**Method 3: Cloud Distribution**

1. Upload APK to Google Drive, Dropbox, or file sharing service
2. Download on target device
3. Enable unknown sources and install

### iOS Installation

**Development Installation:**

1. Open project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Configure signing:
   - Select Runner target
   - General > Signing > Select development team

3. Connect iPhone via USB

4. Build and run:
   ```bash
   flutter run -d <iphone-device-id>
   ```

**App Store Distribution:**

1. Configure app signing with distribution certificate
2. Build IPA:
   ```bash
   flutter build ios --release
   ```
3. Upload to App Store Connect via Xcode or Transporter

## Configuration

### App Configuration

**Backend URL (Optional):**

Edit `lib/config/api_config.dart`:
```dart
static const String? baseUrl = 'http://192.168.1.100:3000/api';
```

Replace with your server IP address.

**Rebuild after configuration changes:**
```bash
flutter build apk --release --split-per-abi
```

### Backend Configuration

**Environment Variables:**

Edit `backend/.env`:
```
# Server port
PORT=3000

# Database path
DB_PATH=./data/billmint.sqlite

# Environment
NODE_ENV=production
```

**Network Access:**

Find your local IP address:
```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig
```

Access from mobile devices on same network:
```
http://<your-local-ip>:3000/api
```

## Deployment

### Local Network Deployment

**Setup:**
1. Start backend server on main computer
2. Note the IP address
3. Configure app with server IP
4. Install app on all devices
5. Ensure all devices on same WiFi

**Access:**
- Server: `http://192.168.1.100:3000`
- API: `http://192.168.1.100:3000/api`

### Cloud Deployment (VPS)

**Recommended Providers:**
- DigitalOcean (starting $5/month)
- AWS Lightsail (starting $3.50/month)
- Linode (starting $5/month)

**Deployment Steps:**

1. Create Ubuntu 22.04 server
2. SSH into server
3. Install Node.js 18:
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt install -y nodejs
   ```

4. Upload backend code:
   ```bash
   scp -r backend/ user@server:/var/www/billmint/
   ```

5. Install dependencies:
   ```bash
   cd /var/www/billmint/backend
   npm install --production
   ```

6. Install PM2 for process management:
   ```bash
   sudo npm install -g pm2
   pm2 start src/index.js --name billmint-api
   pm2 startup
   pm2 save
   ```

7. Configure firewall:
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw --force enable
   ```

8. Setup Nginx reverse proxy (optional):
   ```bash
   sudo apt install nginx
   sudo nano /etc/nginx/sites-available/billmint
   ```

   Add configuration:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location /api {
           proxy_pass http://localhost:3000/api;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

   Enable site:
   ```bash
   sudo ln -s /etc/nginx/sites-available/billmint /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

## Troubleshooting

### Common Issues

**Flutter build fails:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

**Database initialization errors:**
```bash
cd backend
rm -rf data/
node src/migrate.js
```

**ADB device not found:**
```bash
adb kill-server
adb start-server
adb devices
```

**Backend won't start:**
```bash
# Check port availability
lsof -i :3000

# Kill process on port 3000
kill -9 $(lsof -t -i:3000)

# Restart
npm start
```

**Cannot connect to backend from mobile:**
- Verify server is running: `curl http://localhost:3000/health`
- Check firewall settings
- Ensure devices on same network
- Verify IP address in app configuration

**PDF generation fails:**
- Check invoice data is complete
- Ensure all required fields are filled
- Verify GST calculations are valid

**App crashes on startup:**
- Clear app data and cache
- Reinstall application
- Check device compatibility (Android 5.0+ required)

### Logs and Debugging

**Flutter logs:**
```bash
flutter logs
```

**Backend logs:**
```bash
# If using PM2
pm2 logs billmint-api

# Direct output
node src/index.js
```

**Android device logs:**
```bash
adb logcat | grep flutter
```

### Getting Help

For issues not covered in this guide:
1. Check GitHub Issues: https://github.com/ashwinsdk/BillMint/issues
2. Contact support: ashwinsdk@github.com
3. Review API documentation: See API.md

## Version Information

- Flutter: 3.35.7
- Dart: 3.9.2
- Node.js: 18.0.0+
- Android: API 21+ (5.0+)
- iOS: 12.0+

## Next Steps

After successful installation:
1. Configure business settings in app
2. Add customers and products
3. Create test invoice
4. Generate and share PDF
5. Configure backend for multi-device sync (optional)

For API integration and advanced features, see [API.md](API.md).
