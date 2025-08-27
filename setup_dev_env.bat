@echo off
setlocal enabledelayedexpansion

REM Local Development Environment Setup Script for Windows
REM This script helps set up your local environment to match Codemagic configuration

echo 🚀 Setting up Flutter AI ChatBot development environment...
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed. Please install Flutter first.
    echo Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Check Flutter version
for /f "tokens=2" %%i in ('flutter --version ^| findstr "Flutter"') do set FLUTTER_VERSION=%%i
echo [INFO] Flutter version: !FLUTTER_VERSION!

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo [ERROR] pubspec.yaml not found. Please run this script from the project root.
    pause
    exit /b 1
)

echo [INFO] Cleaning previous builds...
flutter clean

echo [INFO] Getting Flutter dependencies...
flutter pub get

REM Check if build_runner is available
flutter pub deps | findstr "build_runner" >nul 2>&1
if not errorlevel 1 (
    echo [INFO] Running code generation...
    flutter packages pub run build_runner build --delete-conflicting-outputs
) else (
    echo [WARNING] build_runner not found in dependencies. Skipping code generation.
)

echo [INFO] Running Flutter doctor...
flutter doctor

echo [INFO] Running static analysis...
flutter analyze --no-congratulate
if errorlevel 1 (
    echo [WARNING] ⚠️  Static analysis found issues
) else (
    echo [INFO] ✅ Static analysis passed
)

REM Run tests if they exist
if exist "test" (
    echo [INFO] Running tests...
    flutter test
    if errorlevel 1 (
        echo [WARNING] ⚠️  Some tests failed
    ) else (
        echo [INFO] ✅ All tests passed
    )
) else (
    echo [WARNING] No test directory found
)

REM Check for Firebase configuration
if not exist "android\app\google-services.json" (
    echo [WARNING] Android Firebase configuration not found: android\app\google-services.json
    echo Please add your Firebase configuration files before building.
)

if not exist "ios\Runner\GoogleService-Info.plist" (
    echo [WARNING] iOS Firebase configuration not found: ios\Runner\GoogleService-Info.plist
    echo Please add your Firebase configuration files before building.
)

REM Check for environment variables
echo [INFO] Checking environment variables...

set ENV_VARS=OPENAI_API_KEY GEMINI_API_KEY STRIPE_PUBLISHABLE_KEY FIREBASE_PROJECT_ID

for %%v in (%ENV_VARS%) do (
    if defined %%v (
        echo [INFO] ✅ %%v is configured
    ) else (
        echo [WARNING] Environment variable %%v is not set
    )
)

REM Create .env template if it doesn't exist
if not exist ".env.template" (
    echo [INFO] Creating .env template...
    (
        echo # Environment Variables Template
        echo # Copy this to .env and fill in your values
        echo # DO NOT commit .env to version control
        echo.
        echo # AI Service API Keys
        echo OPENAI_API_KEY=your_openai_api_key_here
        echo GEMINI_API_KEY=your_gemini_api_key_here
        echo.
        echo # Stripe Configuration
        echo STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
        echo STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
        echo.
        echo # Firebase Configuration
        echo FIREBASE_PROJECT_ID=your_firebase_project_id
        echo.
        echo # App Configuration
        echo APP_NAME=AI ChatBot
        echo APP_VERSION=1.0.0
        echo ENVIRONMENT=development
    ) > .env.template
    echo [INFO] ✅ Created .env.template
)

REM Build debug version to ensure everything works
echo [INFO] Building debug APK to verify setup...
flutter build apk --debug
if errorlevel 1 (
    echo [ERROR] ❌ Debug build failed
    pause
    exit /b 1
) else (
    echo [INFO] ✅ Debug build successful
    echo [INFO] APK location: build\app\outputs\flutter-apk\app-debug.apk
)

echo.
echo 🎉 Environment setup complete!
echo.
echo Next steps:
echo 1. Configure your environment variables ^(copy .env.template to .env^)
echo 2. Add Firebase configuration files
echo 3. Set up your Codemagic project using the provided codemagic.yaml
echo 4. Review CODEMAGIC_SETUP.md for detailed instructions
echo.
echo Happy coding! 🚀
echo.
pause