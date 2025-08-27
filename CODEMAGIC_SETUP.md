# Codemagic CI/CD Setup for Flutter AI ChatBot

This document provides comprehensive instructions for setting up Codemagic CI/CD for your Flutter AI ChatBot application.

## Prerequisites

1. **Codemagic Account**: Sign up at [codemagic.io](https://codemagic.io)
2. **Repository Access**: Connect your Git repository to Codemagic
3. **App Store Connect Account** (for iOS builds)
4. **Google Play Console Account** (for Android builds)
5. **Firebase Project** with configuration files
6. **API Keys** for OpenAI, Gemini, and Stripe

## Configuration Files

### 1. Main Configuration (`codemagic.yaml`)

The main configuration file includes three workflows:

- **flutter-ai-chatbot**: Full production workflow with iOS and Android builds
- **flutter-dev**: Quick development workflow for testing
- **flutter-release**: Release workflow triggered by Git tags

### 2. iOS Export Options (`ios/export_options.plist`)

Defines how iOS builds should be exported and signed.

## Environment Variables Setup

### Required Environment Variables

Add these as encrypted environment variables in your Codemagic app settings:

#### API Keys
```bash
OPENAI_API_KEY="your-openai-api-key"
GEMINI_API_KEY="your-gemini-api-key"
STRIPE_PUBLISHABLE_KEY="pk_live_your-stripe-publishable-key"
STRIPE_SECRET_KEY="sk_live_your-stripe-secret-key"
```

#### Firebase Configuration
```bash
FIREBASE_PROJECT_ID="your-firebase-project-id"
```

#### Android Signing
```bash
CM_KEYSTORE="base64-encoded-keystore-file"
CM_KEYSTORE_PASSWORD="your-keystore-password"
CM_KEY_ALIAS="your-key-alias"
CM_KEY_PASSWORD="your-key-password"
```

#### Google Play Store
```bash
GCLOUD_SERVICE_ACCOUNT_CREDENTIALS="your-service-account-json"
PACKAGE_NAME="com.yourcompany.ai_chatbot"
```

#### iOS & App Store Connect
```bash
APP_ID="1234567890"  # Your App Store Connect app ID
```

## Setup Steps

### 1. Repository Setup

1. Push your code to a Git repository (GitHub, GitLab, or Bitbucket)
2. Ensure the `codemagic.yaml` file is in the root directory
3. Add Firebase configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

### 2. Codemagic Project Setup

1. Log in to [Codemagic](https://codemagic.io)
2. Click "Add application"
3. Connect your Git repository
4. Select "Flutter App" as the project type
5. Choose "Codemagic YAML" as the configuration method

### 3. Environment Variables Configuration

1. Go to your app settings in Codemagic
2. Navigate to "Environment variables"
3. Add all required variables listed above
4. Make sure to mark sensitive variables as "Secure"

### 4. Code Signing Setup

#### Android
1. Generate a keystore file for release builds
2. Convert the keystore to base64: `base64 -i your-keystore.jks`
3. Add the base64 string as `CM_KEYSTORE` environment variable
4. Add keystore passwords and aliases

#### iOS
1. Set up App Store Connect integration in Codemagic
2. Configure automatic code signing
3. Update bundle identifier in `codemagic.yaml`
4. Update Team ID in `export_options.plist`

### 5. Store Publishing Setup

#### Google Play Store
1. Create a service account in Google Cloud Console
2. Enable Google Play Android Developer API
3. Grant access to the service account in Play Console
4. Download the service account JSON and add as environment variable

#### App Store Connect
1. Create an API key in App Store Connect
2. Add the API key to Codemagic integrations
3. Configure automatic submission settings

## Workflow Triggers

### Development Builds
- Triggered on pushes to `develop` and `feature/*` branches
- Runs tests and analysis only
- Builds debug APK for quick testing

### Production Builds
- Triggered on pushes to `main` and `release/*` branches
- Builds signed APK, AAB, and iOS IPA
- Publishes to internal testing tracks

### Release Builds
- Triggered on Git tags starting with `v` (e.g., `v1.0.0`)
- Builds and publishes to production stores
- Requires manual approval for store submission

## Build Artifacts

Each successful build produces:

- **Android**: APK and AAB files
- **iOS**: IPA file
- **Coverage**: Test coverage reports
- **Logs**: Build and test logs

## Notifications

Configure notifications in the `codemagic.yaml` file:

- **Email**: Build status notifications
- **Slack**: Integration with Slack channels
- **Discord**: Integration with Discord webhooks

## Troubleshooting

### Common Issues

1. **Build Timeout**: Increase `max_build_duration` if needed
2. **Code Signing Issues**: Verify certificates and provisioning profiles
3. **Environment Variables**: Ensure all required variables are set
4. **Firebase Configuration**: Verify configuration files are present

### Debug Tips

1. Check build logs for specific error messages
2. Verify all dependencies are properly configured
3. Test builds locally before pushing to repository
4. Use development workflow for quick iteration

## Security Best Practices

1. **Never commit sensitive data**: Use environment variables
2. **Encrypt all secrets**: Mark variables as secure in Codemagic
3. **Rotate API keys**: Regularly update API keys and certificates
4. **Review permissions**: Ensure minimal required permissions

## Performance Optimization

1. **Cache Dependencies**: Codemagic automatically caches Flutter dependencies
2. **Parallel Builds**: Use different workflows for different branches
3. **Artifact Management**: Clean up old artifacts regularly
4. **Build Triggers**: Configure smart triggers to avoid unnecessary builds

## Monitoring and Analytics

1. **Build Status**: Monitor build success rates
2. **Performance Metrics**: Track build times and optimize
3. **Store Analytics**: Monitor app performance in stores
4. **User Feedback**: Integrate crash reporting and analytics

## Support and Resources

- [Codemagic Documentation](https://docs.codemagic.io/)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [Google Play Console API](https://developers.google.com/android-publisher)

## Next Steps

1. Customize the configuration for your specific needs
2. Set up monitoring and alerting
3. Configure automatic deployment to staging environments
4. Implement feature flags for gradual rollouts
5. Set up comprehensive testing pipelines