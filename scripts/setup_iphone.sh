#!/bin/bash
# Quick Setup Script for BillMint iPhone Testing

set -e

echo "🚀 BillMint Quick Setup for iPhone"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if in correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: Run this script from the BillMint project root${NC}"
    exit 1
fi

echo "Step 1: Checking prerequisites..."
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Flutter found${NC}"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found. Installing via Homebrew...${NC}"
    brew install node
else
    echo -e "${GREEN}✅ Node.js found: $(node --version)${NC}"
fi

# Check Xcode
if ! xcode-select -p &> /dev/null; then
    echo -e "${YELLOW}⚠️  Xcode Command Line Tools not found${NC}"
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Please complete the installation and run this script again."
    exit 0
else
    echo -e "${GREEN}✅ Xcode found${NC}"
fi

# Check CocoaPods
if ! command -v pod &> /dev/null; then
    echo -e "${YELLOW}⚠️  CocoaPods not found. Installing...${NC}"
    sudo gem install cocoapods
else
    echo -e "${GREEN}✅ CocoaPods found${NC}"
fi

echo ""
echo "Step 2: Setting up backend..."
echo ""

# Setup backend
cd backend

if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm install
else
    echo -e "${GREEN}✅ Backend dependencies already installed${NC}"
fi

if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo -e "${GREEN}✅ Created .env file${NC}"
else
    echo -e "${GREEN}✅ .env file exists${NC}"
fi

cd ..

echo ""
echo "Step 3: Setting up Flutter app..."
echo ""

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Generate database code
echo "Generating database code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Setup iOS
echo "Setting up iOS dependencies..."
cd ios
pod install
cd ..

echo ""
echo "Step 4: Checking iPhone connection..."
echo ""

# Check for connected devices
DEVICES=$(flutter devices 2>&1)

if echo "$DEVICES" | grep -q "iPhone"; then
    echo -e "${GREEN}✅ iPhone detected!${NC}"
    echo ""
    echo "$DEVICES" | grep "iPhone"
    echo ""
else
    echo -e "${YELLOW}⚠️  iPhone not detected${NC}"
    echo ""
    echo "Please:"
    echo "1. Connect your iPhone via USB cable"
    echo "2. Unlock your iPhone"
    echo "3. Tap 'Trust This Computer' when prompted"
    echo "4. Enable Developer Mode: Settings > Privacy & Security > Developer Mode"
    echo ""
    echo "Then run: flutter devices"
    echo ""
fi

echo ""
echo "================================================"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo "================================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Start backend (in one terminal):"
echo "   cd backend && npm start"
echo ""
echo "2. Run app on iPhone (in another terminal):"
echo "   flutter run"
echo ""
echo "See SETUP_GUIDE.md for detailed instructions."
echo ""
