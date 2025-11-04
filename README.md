# BillMint

Invoice and billing management app for small sellers in India.

## Tech Stack

- Flutter 3.35.7
- Node.js 18+ (backend)
- SQLite database (Drift ORM)
- GST-compliant invoicing

## Quick Setup

```bash
git clone https://github.com/ashwinsdk/BillMint.git
cd BillMint
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Backend

```bash
cd backend
npm install
node src/migrate.js
npm start
```

Backend runs on http://localhost:3000

## Run App

```bash
flutter run
```

## Build Android APK

```bash
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/`
- app-arm64-v8a-release.apk (20 MB)
- app-armeabi-v7a-release.apk (18 MB)
- app-x86_64-release.apk (22 MB)

## Build iOS IPA

```bash
cd ios && pod install && cd ..
flutter build ipa --export-method development
```

Output: `build/ios/ipa/billmint.ipa` (9 MB)

## Install APK on Device

```bash
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Install IPA on iPhone

Via Finder:
1. Connect iPhone
2. Open Finder
3. Drag IPA to device

Via command:
```bash
xcrun devicectl device install app --device <device-id> build/ios/ipa/billmint.ipa
```

## Database Code Generation

After modifying database schema:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## App Icons

Edit `flutter_launcher_icons.yaml`, then:
```bash
dart run flutter_launcher_icons
```

## Clean Build

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release --split-per-abi
```

## GitHub Releases

Create release by pushing a tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```

Builds run automatically, creating GitHub release with APK and IPA files.

View releases: https://github.com/ashwinsdk/BillMint/releases

## Backend API

Base URL: `http://localhost:3000/api`

Endpoints:
```
GET    /api/customers
POST   /api/customers
GET    /api/customers/:id
PUT    /api/customers/:id
DELETE /api/customers/:id

GET    /api/products
POST   /api/products
GET    /api/products/:id
PUT    /api/products/:id
DELETE /api/products/:id

GET    /api/invoices
POST   /api/invoices
GET    /api/invoices/:id
PUT    /api/invoices/:id
DELETE /api/invoices/:id

POST   /api/backup/upload
GET    /api/backup/download
```

## Backend Configuration

Edit `backend/.env`:
```
PORT=3000
DB_PATH=./data/billmint.sqlite
NODE_ENV=production
```

## App Configuration

Edit `lib/config/api_config.dart`:
```dart
static const String? baseUrl = 'http://192.168.1.100:3000/api';
```

## Backend Deployment

Docker:
```bash
cd backend
docker build -t billmint-backend .
docker run -d -p 3000:3000 -v /var/lib/billmint:/data billmint-backend
```

Systemd:
```bash
sudo cp backend/billmint-backend.service /etc/systemd/system/
sudo systemctl enable billmint-backend
sudo systemctl start billmint-backend
```

## Network Access

Find local IP:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Tailscale (private):
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Cloudflare Tunnel (public):
```bash
cloudflared tunnel create billmint
cloudflared tunnel route dns billmint billmint.yourdomain.com
cloudflared tunnel run billmint
```

ngrok (public):
```bash
ngrok http 3000
```

## Database Schema

Tables: customers, products, invoices, invoice_items, app_settings

## Development Commands

Run tests:
```bash
flutter test
```

Format code:
```bash
dart format .
```

Analyze code:
```bash
flutter analyze
```

## Troubleshooting

Build fails:
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Database errors:
```bash
cd backend
rm -rf data/
node src/migrate.js
```

ADB issues:
```bash
adb kill-server
adb start-server
adb devices
```

Backend won't start:
```bash
lsof -i :3000
kill -9 $(lsof -t -i:3000)
npm start
```

## License

Copyright 2025 BillMint. All rights reserved.[](LINSENCE)
 
## Support

GitHub: https://github.com/ashwinsdk/BillMint
Email: ashwin2005s@gmail.com
