// App Constants
class AppConstants {
  // App Info
  static const String appName = 'AI ChatBot';
  static const String appVersion = '1.0.0';
  
  // API
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  // Limits
  static const int freeMessageLimit = 10;
  static const int premiumMessageLimit = -1; // Unlimited
  
  // Storage
  static const String conversationsCollection = 'conversations';
  static const String usersCollection = 'users';
  static const String messagesCollection = 'messages';
  
  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String isFirstTimeKey = 'is_first_time';
}