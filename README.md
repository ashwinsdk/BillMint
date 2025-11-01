# BillMint

Invoice and Billing Generator for Small Sellers in India

## Overview

BillMint is a complete Flutter mobile application for invoice and billing management designed for small sellers in India. It features offline-first local database storage with optional backend sync, GST calculation, PDF generation, and a polished dark theme optimized for low-end Android devices.

## Features

- Offline-first SQLite database with Drift ORM
- Customer and product catalog management
- GST-compliant invoicing (0%, 5%, 12%, 18%, 28%)
- PDF invoice generation with QR codes for UPI payments
- CSV export for data backup
- Manual backup/restore with backend sync
- Dark theme with black background and electric blue primary
- Performance-optimized for low-end devices
- No authentication required

## Quick Start

### Prerequisites

- Flutter 3.9.2+
- Dart 3.0+
- Node.js 18+ (for backend)
- Android Studio or Xcode (for device builds)

### Installation

1. Clone repository:
```bash
git clone <repo-url>
cd BillMint
```

2. Run setup script:
```bash
chmod +x scripts/setup_dev.sh
./scripts/setup_dev.sh
```

3. Download and place assets:
   - Source Code Pro fonts in `assets/fonts/`
   - Logo image as `assets/logo.png`

4. Start backend:
```bash
cd backend
npm run migrate
npm run dev
```

5. Run app:
```bash
flutter run
```

## Documentation

- [INSTALLATION.md](docs/INSTALLATION.md) - Detailed setup for Android and iOS
- [API.md](docs/API.md) - Backend API documentation
- [DEVOPS.md](docs/DEVOPS.md) - Deployment and server management
- [PERFORMANCE.md](docs/PERFORMANCE.md) - Performance optimization guide
- [USAGE.md](docs/USAGE.md) - End-user guide
- [CONTRIBUTING.md](docs/CONTRIBUTING.md) - Contribution guidelines

## Building for Devices

### Android

```bash
# Debug
flutter run -d <device-id>

# Release APK
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

See INSTALLATION.md for signing configuration.

### iOS

```bash
# Install pods
cd ios && pod install && cd ..

# Run on device
flutter run -d <device-id>

# Build IPA
flutter build ipa --export-method ad-hoc
```

See INSTALLATION.md for Xcode configuration.

## Backend Deployment

### Docker

```bash
cd backend
docker build -t billmint-backend .
docker run -d -p 3000:3000 -v /var/lib/billmint:/data billmint-backend
```

### Systemd

```bash
sudo cp backend/billmint-backend.service /etc/systemd/system/
sudo systemctl enable billmint-backend
sudo systemctl start billmint-backend
```

### Expose Backend

**Option 1: Tailscale (Private)**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
# Use Tailscale IP in app
```

**Option 2: Cloudflare Tunnel (Public)**
```bash
cloudflared tunnel create billmint
cloudflared tunnel route dns billmint billmint.yourdomain.com
cloudflared tunnel run billmint
```

**Option 3: ngrok (Public)**
```bash
ngrok http 3000
# Use HTTPS URL in app
```

See DEVOPS.md for complete deployment guide.

## Project Structure

```
BillMint/
├── android/          # Android native project
├── ios/              # iOS native project
├── lib/              # Flutter app code
│   ├── data/         # Database and API
│   ├── screens/      # UI screens
│   ├── theme/        # Theme configuration
│   └── utils/        # Utility functions
├── assets/           # Fonts and images
├── backend/          # Node.js API
│   ├── src/          # API source code
│   ├── Dockerfile    # Docker config
│   └── *.service     # Systemd config
├── docs/             # Documentation
├── scripts/          # Development scripts
└── test/             # Unit tests
```

## Technology Stack

**Frontend:**
- Flutter 3.9.2+ with Dart
- Riverpod for state management
- Drift for SQLite database
- PDF generation with isolates
- QR codes for UPI payments

**Backend:**
- Node.js 18+ with Express
- SQLite3 database
- CORS enabled for mobile app
- No authentication (api/no-auth)

## Development

### Run Tests

```bash
flutter test
```

### Format Code

```bash
dart format .
```

### Analyze Code

```bash
flutter analyze
```

### Install Pre-commit Hook

```bash
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## License

MIT License - see LICENSE file

## Support

Open an issue on GitHub for questions or problems.

## Changelog

### v1.0.0 (November 2025)
- Initial release
- Core database and API
- Dark theme UI foundation
- Invoice calculations
- Project documentation
