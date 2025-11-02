# BillMint - Professional Invoice & Billing Management System# BillMint



A comprehensive Flutter-based mobile application for invoice generation, billing management, and business operations.Invoice and Billing Generator for Small Sellers in India



## Overview## Overview



BillMint is a professional-grade invoice and billing management system designed for small to medium-sized businesses. Built with Flutter for cross-platform compatibility, it provides a complete solution for managing customers, products, invoices, and business operations.BillMint is a complete Flutter mobile application for invoice and billing management designed for small sellers in India. It features offline-first local database storage with optional backend sync, GST calculation, PDF generation, and a polished dark theme optimized for low-end Android devices.



## Features## Features



### Core Functionality- Offline-first SQLite database with Drift ORM

- Invoice creation and management with GST calculations- Customer and product catalog management

- Customer relationship management (CRM)- GST-compliant invoicing (0%, 5%, 12%, 18%, 28%)

- Product catalog management- PDF invoice generation with QR codes for UPI payments

- Payment tracking (paid, unpaid, partial payments)- CSV export for data backup

- Professional PDF invoice generation- Manual backup/restore with backend sync

- Export and share invoices- Dark theme with black background and electric blue primary

- Local SQLite database for offline operations- Performance-optimized for low-end devices

- No authentication required

### Advanced Features

- Multi-currency support (INR with GST)## Quick Start

- HSN code tracking for tax compliance

- Discount management### Prerequisites

- Payment terms configuration

- Business settings management- Flutter 3.9.2+

- Dark mode support- Dart 3.0+

- Splash screen with animated branding- Node.js 18+ (for backend)

- Android Studio or Xcode (for device builds)

## Technology Stack

### Installation

### Mobile Application

- **Framework**: Flutter 3.35.7 / Dart 3.9.21. Clone repository:

- **State Management**: Riverpod 2.6.1```bash

- **Database**: Drift (SQLite) 2.23.0git clone <repo-url>

- **PDF Generation**: pdf 3.11.3cd BillMint

- **UI Components**: Material Design 3```



### Backend API (Optional)2. Run setup script:

- **Runtime**: Node.js 18+```bash

- **Framework**: Express.js 4.18.2chmod +x scripts/setup_dev.sh

- **Database**: SQLite3 5.1.6./scripts/setup_dev.sh

- **API Style**: RESTful with JSON```



## Project Structure3. Download and place assets:

   - Source Code Pro fonts in `assets/fonts/`

```   - Logo image as `assets/logo.png`

billmint/

├── lib/4. Start backend:

│   ├── config/            # Configuration files```bash

│   ├── data/              # Database models and providerscd backend

│   ├── providers/         # Riverpod state providersnpm run migrate

│   ├── screens/           # UI screensnpm run dev

│   ├── theme/             # App theming```

│   └── main.dart          # Application entry point

├── backend/5. Run app:

│   ├── src/               # Backend source code```bash

│   │   ├── index.js       # Express serverflutter run

│   │   ├── database.js    # Database operations```

│   │   ├── customers.js   # Customer endpoints

│   │   ├── products.js    # Product endpoints## Documentation

│   │   ├── invoices.js    # Invoice endpoints

│   │   └── migrate.js     # Database migrations- [INSTALLATION.md](docs/INSTALLATION.md) - Detailed setup for Android and iOS

│   ├── data/              # SQLite database storage- [API.md](docs/API.md) - Backend API documentation

│   └── package.json       # Node.js dependencies- [DEVOPS.md](docs/DEVOPS.md) - Deployment and server management

├── android/               # Android platform files- [PERFORMANCE.md](docs/PERFORMANCE.md) - Performance optimization guide

├── ios/                   # iOS platform files- [USAGE.md](docs/USAGE.md) - End-user guide

└── assets/                # Static assets- [CONTRIBUTING.md](docs/CONTRIBUTING.md) - Contribution guidelines

```

## Building for Devices

## System Requirements

### Android

### Development Environment

- macOS 15.6+ or Linux```bash

- Flutter SDK 3.35.7+# Debug

- Dart SDK 3.9.2+flutter run -d <device-id>

- Android Studio / Xcode

- Node.js 18+ (for backend)# Release APK

flutter build apk --release

### Target Devicesadb install build/app/outputs/flutter-apk/app-release.apk

- Android 5.0 (API 21) or higher```

- iOS 12.0 or higher

See INSTALLATION.md for signing configuration.

## Installation

### iOS

See [INSTALLATION.md](INSTALLATION.md) for detailed setup instructions.

```bash

### Quick Start# Install pods

cd ios && pod install && cd ..

1. Clone the repository

2. Install Flutter dependencies:# Run on device

   ```bashflutter run -d <device-id>

   flutter pub get

   ```# Build IPA

3. Run the application:flutter build ipa --export-method ad-hoc

   ```bash```

   flutter run

   ```See INSTALLATION.md for Xcode configuration.



## API Documentation## Backend Deployment



See [API.md](API.md) for complete backend API documentation.### Docker



### Available Endpoints```bash

cd backend

**Base URL**: `http://localhost:3000/api`docker build -t billmint-backend .

docker run -d -p 3000:3000 -v /var/lib/billmint:/data billmint-backend

- `GET /health` - Health check```

- `GET /api/customers` - List all customers

- `POST /api/customers` - Create customer### Systemd

- `GET /api/products` - List all products

- `POST /api/products` - Create product```bash

- `GET /api/invoices` - List all invoicessudo cp backend/billmint-backend.service /etc/systemd/system/

- `POST /api/invoices` - Create invoicesudo systemctl enable billmint-backend

- `POST /api/backup/upload` - Backup databasesudo systemctl start billmint-backend

- `GET /api/backup/download` - Download backup```



## Building for Production### Expose Backend



### Android APK**Option 1: Tailscale (Private)**

```bash```bash

flutter build apk --release --split-per-abicurl -fsSL https://tailscale.com/install.sh | sh

```sudo tailscale up

# Use Tailscale IP in app

Output location: `build/app/outputs/flutter-apk/````



### iOS IPA**Option 2: Cloudflare Tunnel (Public)**

```bash```bash

flutter build ios --releasecloudflared tunnel create billmint

```cloudflared tunnel route dns billmint billmint.yourdomain.com

cloudflared tunnel run billmint

## Configuration```



### Application Settings**Option 3: ngrok (Public)**

Edit `lib/config/api_config.dart` to configure backend URL:```bash

```dartngrok http 3000

static const String? baseUrl = 'http://your-server:3000/api';# Use HTTPS URL in app

``````



### Backend SettingsSee DEVOPS.md for complete deployment guide.

Edit `backend/.env`:

```## Project Structure

PORT=3000

DB_PATH=./data/billmint.sqlite```

NODE_ENV=productionBillMint/

```├── android/          # Android native project

├── ios/              # iOS native project

## Database Schema├── lib/              # Flutter app code

│   ├── data/         # Database and API

### Invoices Table│   ├── screens/      # UI screens

- id, invoice_number, customer_id│   ├── theme/        # Theme configuration

- invoice_date, due_date│   └── utils/        # Utility functions

- subtotal, discount, taxable_value├── assets/           # Fonts and images

- cgst, sgst, igst, total├── backend/          # Node.js API

- payment_status, paid_amount│   ├── src/          # API source code

- notes, created_at, updated_at│   ├── Dockerfile    # Docker config

│   └── *.service     # Systemd config

### Customers Table├── docs/             # Documentation

- id, name, phone, email├── scripts/          # Development scripts

- address, gstin└── test/             # Unit tests

- created_at, updated_at```



### Products Table## Technology Stack

- id, name, description

- hsn_code, unit, price**Frontend:**

- gst_rate- Flutter 3.9.2+ with Dart

- created_at, updated_at- Riverpod for state management

- Drift for SQLite database

### Invoice Items Table- PDF generation with isolates

- id, invoice_id, product_id- QR codes for UPI payments

- name, quantity, unit

- price, gst_rate, amount**Backend:**

- Node.js 18+ with Express

## Performance Considerations- SQLite3 database

- CORS enabled for mobile app

- Local SQLite database for offline-first operation- No authentication (api/no-auth)

- Optimized PDF generation (single-page layout)

- Efficient state management with Riverpod## Development

- Minimal dependencies for faster build times

- Font tree-shaking enabled (99.6% reduction)### Run Tests



## Security```bash

flutter test

- No authentication required for local-only mode```

- Private network recommended for backend deployment

- Database encryption available via Drift### Format Code

- Proprietary license - unauthorized use prohibited

```bash

## Troubleshootingdart format .

```

### Common Issues

### Analyze Code

**Build failures**: Run `flutter clean && flutter pub get`

```bash

**Database errors**: Delete app data and restartflutter analyze

```

**PDF generation issues**: Ensure all invoice data is valid

### Install Pre-commit Hook

**Backend connection**: Verify server URL and network connectivity

```bash

## Version Historycp scripts/pre-commit .git/hooks/pre-commit

chmod +x .git/hooks/pre-commit

- **1.0.0** - Initial release```

  - Core invoice management

  - Customer and product management## License

  - PDF generation

  - Payment trackingMIT License - see LICENSE file

  - Professional splash screen

## Support

## License

Open an issue on GitHub for questions or problems.

Copyright (c) 2025 BillMint. All rights reserved.

## Changelog

This is proprietary software. See LICENSE file for details.

### v1.0.0 (November 2025)

## Support- Initial release

- Core database and API

For issues, questions, or licensing inquiries:- Dark theme UI foundation

- GitHub: https://github.com/ashwinsdk/BillMint- Invoice calculations

- Email: ashwinsdk@github.com- Project documentation


## Acknowledgments

Built with Flutter and modern mobile development best practices.
