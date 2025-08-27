#!/bin/bash

# Local Development Environment Setup Script
# This script helps set up your local environment to match Codemagic configuration

set -e

echo "🚀 Setting up Flutter AI ChatBot development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
print_status "Flutter version: $FLUTTER_VERSION"

# Check if we're in the right directory
if [[ ! -f "pubspec.yaml" ]]; then
    print_error "pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

print_status "Cleaning previous builds..."
flutter clean

print_status "Getting Flutter dependencies..."
flutter pub get

# Check if build_runner is available
if flutter pub deps | grep -q "build_runner"; then
    print_status "Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
else
    print_warning "build_runner not found in dependencies. Skipping code generation."
fi

print_status "Running Flutter doctor..."
flutter doctor

print_status "Running static analysis..."
if flutter analyze --no-congratulate; then
    print_status "✅ Static analysis passed"
else
    print_warning "⚠️  Static analysis found issues"
fi

# Run tests if they exist
if [[ -d "test" ]]; then
    print_status "Running tests..."
    if flutter test; then
        print_status "✅ All tests passed"
    else
        print_warning "⚠️  Some tests failed"
    fi
else
    print_warning "No test directory found"
fi

# Check for Firebase configuration
if [[ ! -f "android/app/google-services.json" ]]; then
    print_warning "Android Firebase configuration not found: android/app/google-services.json"
    echo "Please add your Firebase configuration files before building."
fi

if [[ ! -f "ios/Runner/GoogleService-Info.plist" ]]; then
    print_warning "iOS Firebase configuration not found: ios/Runner/GoogleService-Info.plist"
    echo "Please add your Firebase configuration files before building."
fi

# Check for environment variables
print_status "Checking environment variables..."

ENV_VARS=(
    "OPENAI_API_KEY"
    "GEMINI_API_KEY" 
    "STRIPE_PUBLISHABLE_KEY"
    "FIREBASE_PROJECT_ID"
)

for var in "${ENV_VARS[@]}"; do
    if [[ -z "${!var}" ]]; then
        print_warning "Environment variable $var is not set"
    else
        print_status "✅ $var is configured"
    fi
done

# Create .env template if it doesn't exist
if [[ ! -f ".env.template" ]]; then
    print_status "Creating .env template..."
    cat > .env.template << EOF
# Environment Variables Template
# Copy this to .env and fill in your values
# DO NOT commit .env to version control

# AI Service API Keys
OPENAI_API_KEY=your_openai_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id

# App Configuration
APP_NAME=AI ChatBot
APP_VERSION=1.0.0
ENVIRONMENT=development
EOF
    print_status "✅ Created .env.template"
fi

# Build debug version to ensure everything works
print_status "Building debug APK to verify setup..."
if flutter build apk --debug; then
    print_status "✅ Debug build successful"
    print_status "APK location: build/app/outputs/flutter-apk/app-debug.apk"
else
    print_error "❌ Debug build failed"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Environment setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Configure your environment variables (copy .env.template to .env)"
echo "2. Add Firebase configuration files"
echo "3. Set up your Codemagic project using the provided codemagic.yaml"
echo "4. Review CODEMAGIC_SETUP.md for detailed instructions"
echo ""
echo "Happy coding! 🚀"