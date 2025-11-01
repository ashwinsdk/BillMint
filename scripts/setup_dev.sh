#!/bin/bash
# Development environment setup script for macOS/Linux

set -e

echo "🚀 Setting up BillMint development environment..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Check Node.js installation
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first:"
    echo "   https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js found: $(node --version)"

# Install Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Generate Drift code
echo "🔨 Generating database code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Install backend dependencies
echo "📦 Installing backend dependencies..."
cd backend
npm install
cd ..

# Run tests
echo "🧪 Running tests..."
flutter test

# Set up git hooks
echo "🔗 Setting up Git hooks..."
cat > .git/hooks/pre-commit << 'HOOK'
#!/bin/bash
# Pre-commit hook: format code and run tests

echo "Running pre-commit checks..."

# Format Dart code
dart format lib/ test/

# Run Flutter analyze
flutter analyze

# Run tests
flutter test

if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Commit aborted."
    exit 1
fi

echo "✅ Pre-commit checks passed"
HOOK

chmod +x .git/hooks/pre-commit

echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure backend/.env (copy from .env.example)"
echo "2. Start backend: cd backend && npm start"
echo "3. Run app: flutter run"
