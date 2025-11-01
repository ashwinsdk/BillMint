#!/bin/bash

# BillMint Development Environment Setup Script for macOS
# This script checks prerequisites and sets up the development environment

set -e

echo "========================================="
echo "BillMint Development Setup"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Flutter
echo "Checking Flutter..."
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✓ Flutter found:${NC} $(flutter --version | head -n 1)"
else
    echo -e "${RED}✗ Flutter not found${NC}"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install/macos"
    exit 1
fi

# Check Dart
echo "Checking Dart..."
if command -v dart &> /dev/null; then
    echo -e "${GREEN}✓ Dart found:${NC} $(dart --version 2>&1)"
else
    echo -e "${RED}✗ Dart not found${NC}"
    echo "Dart should be included with Flutter"
    exit 1
fi

# Check Node.js
echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js found:${NC} $NODE_VERSION"
else
    echo -e "${RED}✗ Node.js not found${NC}"
    echo "Install with: brew install node"
    exit 1
fi

# Check npm
echo "Checking npm..."
if command -v npm &> /dev/null; then
    echo -e "${GREEN}✓ npm found:${NC} $(npm --version)"
else
    echo -e "${RED}✗ npm not found${NC}"
    exit 1
fi

# Check CocoaPods (optional for iOS)
echo "Checking CocoaPods..."
if command -v pod &> /dev/null; then
    echo -e "${GREEN}✓ CocoaPods found:${NC} $(pod --version)"
else
    echo -e "${YELLOW}⚠ CocoaPods not found${NC}"
    echo "For iOS development, install with: sudo gem install cocoapods"
fi

# Check Android SDK (optional)
echo "Checking Android SDK..."
if [ -d "$HOME/Library/Android/sdk" ]; then
    echo -e "${GREEN}✓ Android SDK found${NC}"
elif [ -n "$ANDROID_HOME" ]; then
    echo -e "${GREEN}✓ Android SDK found at:${NC} $ANDROID_HOME"
else
    echo -e "${YELLOW}⚠ Android SDK not found${NC}"
    echo "For Android development, install Android Studio from https://developer.android.com/studio"
fi

echo ""
echo "========================================="
echo "Installing Dependencies"
echo "========================================="
echo ""

# Install Flutter dependencies
echo "Installing Flutter dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Flutter dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to install Flutter dependencies${NC}"
    exit 1
fi

# Generate Drift database code
echo "Generating database code..."
flutter pub run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database code generated${NC}"
else
    echo -e "${YELLOW}⚠ Database code generation had issues (may be OK if Drift not used yet)${NC}"
fi

# Install backend dependencies
echo "Installing backend dependencies..."
cd backend
npm install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backend dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to install backend dependencies${NC}"
    cd ..
    exit 1
fi

# Setup backend environment
if [ ! -f .env ]; then
    echo "Creating backend .env file..."
    cp .env.example .env
    echo -e "${GREEN}✓ Backend .env created${NC}"
    echo -e "${YELLOW}⚠ Please edit backend/.env to configure PORT and DB_PATH${NC}"
else
    echo -e "${GREEN}✓ Backend .env already exists${NC}"
fi

# Initialize database
echo "Initializing database..."
npm run migrate

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database initialized${NC}"
else
    echo -e "${RED}✗ Failed to initialize database${NC}"
    cd ..
    exit 1
fi

cd ..

# Install iOS pods if available
if command -v pod &> /dev/null; then
    if [ -d "ios" ]; then
        echo "Installing iOS CocoaPods..."
        cd ios
        pod install
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ iOS CocoaPods installed${NC}"
        else
            echo -e "${YELLOW}⚠ iOS CocoaPods installation had issues${NC}"
        fi
        cd ..
    fi
fi

echo ""
echo "========================================="
echo "Checking Assets"
echo "========================================="
echo ""

# Check for fonts
FONT_DIR="assets/fonts"
if [ ! -f "$FONT_DIR/SourceCodePro-Regular.ttf" ]; then
    echo -e "${YELLOW}⚠ Source Code Pro fonts not found${NC}"
    echo "Please download fonts from https://fonts.google.com/specimen/Source+Code+Pro"
    echo "and place TTF files in $FONT_DIR/"
else
    echo -e "${GREEN}✓ Fonts found${NC}"
fi

# Check for logo
if [ ! -f "assets/logo.png" ]; then
    echo -e "${YELLOW}⚠ Logo not found${NC}"
    echo "Please create or place logo.png (1024x1024px) in assets/"
else
    echo -e "${GREEN}✓ Logo found${NC}"
fi

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Place assets (fonts and logo) as instructed above"
echo "2. Run app:"
echo "   flutter run"
echo ""
echo "3. Start backend (in another terminal):"
echo "   cd backend"
echo "   npm run dev"
echo ""
echo "4. See INSTALLATION.md for building on devices"
echo ""
