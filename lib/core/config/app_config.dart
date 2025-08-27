/// App configuration and constants
class AppConfig {
  // App Information
  static const String appName = 'AI ChatBot';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // API Configuration
  static const String openAIApiUrl = 'https://api.openai.com/v1';
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'ai-chatbot-flutter';
  static const String firestoreRegion = 'us-central1';
  
  // Stripe Configuration
  static const String stripePublishableKey = 'pk_test_your_stripe_key';
  static const String stripeWebhookSecret = 'whsec_your_webhook_secret';
  
  // App Store URLs
  static const String appStoreUrl = 'https://apps.apple.com/app/ai-chatbot';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.ai_chatbot';
  
  // Support URLs
  static const String supportEmail = 'support@aichatbot.com';
  static const String privacyPolicyUrl = 'https://aichatbot.com/privacy';
  static const String termsOfServiceUrl = 'https://aichatbot.com/terms';
  static const String helpCenterUrl = 'https://help.aichatbot.com';
  
  // Social Media
  static const String twitterUrl = 'https://twitter.com/aichatbot';
  static const String githubUrl = 'https://github.com/yourusername/ai-chatbot';
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePushNotifications = true;
  static const bool enableBiometricAuth = true;
  static const bool enableOfflineMode = false;
  static const bool enableBetaFeatures = false;
  
  // Chat Configuration
  static const int maxMessageLength = 4000;
  static const int maxConversationTitle = 100;
  static const int messagesPerPage = 50;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> supportedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
  
  // Subscription Limits
  static const int freeMessageLimit = 10;
  static const int premiumMessageLimit = -1; // Unlimited
  static const int premiumPlusMessageLimit = -1; // Unlimited
  
  // AI Model Configuration
  static const String defaultModel = 'gpt-3.5-turbo';
  static const String premiumModel = 'gpt-4';
  static const String geminiModel = 'gemini-pro';
  static const double defaultTemperature = 0.7;
  static const int maxTokens = 4096;
  
  // Animation Configuration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  static const Duration typingAnimationSpeed = Duration(milliseconds: 50);
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCachedMessages = 1000;
  static const int maxCachedConversations = 100;
  
  // Network Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;
  
  // UI Configuration
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Responsive Breakpoints
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
  
  // Database Configuration
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';
  static const String usersCollection = 'users';
  static const String subscriptionsCollection = 'subscriptions';
  static const String usageDataCollection = 'usage_data';
  
  // Security Configuration
  static const int passwordMinLength = 6;
  static const int otpCodeLength = 6;
  static const Duration otpValidityDuration = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // Notification Configuration
  static const String notificationChannelId = 'ai_chatbot_notifications';
  static const String notificationChannelName = 'AI ChatBot Notifications';
  static const String notificationChannelDescription = 'Notifications for AI ChatBot app';
  
  // Development Configuration
  static const bool debugMode = true;
  static const bool enableLogging = true;
  static const bool enableNetworkLogging = true;
  static const bool enablePerformanceMonitoring = true;
}

/// Environment-specific configuration
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;
  
  static Environment get current => _currentEnvironment;
  
  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }
  
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;
  
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'https://dev-api.aichatbot.com';
      case Environment.staging:
        return 'https://staging-api.aichatbot.com';
      case Environment.production:
        return 'https://api.aichatbot.com';
    }
  }
  
  static String get firebaseProjectId {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'ai-chatbot-dev';
      case Environment.staging:
        return 'ai-chatbot-staging';
      case Environment.production:
        return 'ai-chatbot-prod';
    }
  }
}

/// App constants that don't change
class AppConstants {
  // Asset paths
  static const String assetImagesPath = 'assets/images/';
  static const String assetIconsPath = 'assets/icons/';
  static const String assetAnimationsPath = 'assets/animations/';
  
  // Image assets
  static const String logoImage = '${assetImagesPath}logo.png';
  static const String splashImage = '${assetImagesPath}splash.png';
  static const String onboardingImage1 = '${assetImagesPath}onboarding1.png';
  static const String onboardingImage2 = '${assetImagesPath}onboarding2.png';
  static const String onboardingImage3 = '${assetImagesPath}onboarding3.png';
  static const String emptyStateImage = '${assetImagesPath}empty_state.png';
  
  // Animation assets
  static const String loadingAnimation = '${assetAnimationsPath}loading.json';
  static const String typingAnimation = '${assetAnimationsPath}typing.json';
  static const String successAnimation = '${assetAnimationsPath}success.json';
  static const String errorAnimation = '${assetAnimationsPath}error.json';
  
  // Local storage keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  // Default values
  static const String defaultLanguage = 'en';
  static const String defaultTheme = 'system';
  static const String defaultAvatarUrl = 'https://ui-avatars.com/api/?name=User&background=random';
  
  // Regex patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  
  // Error messages
  static const String genericErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  
  // Success messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String signupSuccessMessage = 'Account created successfully!';
  static const String updateSuccessMessage = 'Updated successfully!';
  static const String deleteSuccessMessage = 'Deleted successfully!';
  
  // Feature descriptions
  static const String premiumFeatureDescription = 'This feature is available for Premium subscribers only.';
  static const String comingSoonFeatureDescription = 'This feature is coming soon! Stay tuned.';
  static const String betaFeatureDescription = 'This is a beta feature. Please report any issues.';
}

/// App permissions
class AppPermissions {
  static const String camera = 'camera';
  static const String storage = 'storage';
  static const String microphone = 'microphone';
  static const String location = 'location';
  static const String notifications = 'notifications';
  static const String biometric = 'biometric';
  
  static const List<String> requiredPermissions = [
    storage,
    notifications,
  ];
  
  static const List<String> optionalPermissions = [
    camera,
    microphone,
    location,
    biometric,
  ];
}

/// Analytics events
class AnalyticsEvents {
  // User events
  static const String userSignUp = 'user_sign_up';
  static const String userSignIn = 'user_sign_in';
  static const String userSignOut = 'user_sign_out';
  static const String userProfileUpdate = 'user_profile_update';
  
  // Chat events
  static const String messageSent = 'message_sent';
  static const String messageReceived = 'message_received';
  static const String conversationCreated = 'conversation_created';
  static const String conversationDeleted = 'conversation_deleted';
  static const String fileUploaded = 'file_uploaded';
  
  // Subscription events
  static const String subscriptionStarted = 'subscription_started';
  static const String subscriptionUpgraded = 'subscription_upgraded';
  static const String subscriptionCanceled = 'subscription_canceled';
  static const String paymentSucceeded = 'payment_succeeded';
  static const String paymentFailed = 'payment_failed';
  
  // App events
  static const String appOpened = 'app_opened';
  static const String appClosed = 'app_closed';
  static const String errorOccurred = 'error_occurred';
  static const String featureUsed = 'feature_used';
  static const String onboardingCompleted = 'onboarding_completed';
}