import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

// Language Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>(
  (ref) {
    final sharedPrefs = ref.watch(sharedPreferencesProvider);
    return sharedPrefs.when(
      data: (prefs) => LanguageNotifier(prefs),
      loading: () => LanguageNotifier(null),
      error: (_, __) => LanguageNotifier(null),
    );
  },
);

class LanguageNotifier extends StateNotifier<Locale> {
  final SharedPreferences? _prefs;
  static const String _key = 'app_language';

  LanguageNotifier(this._prefs) : super(_getInitialLanguage(_prefs));

  static Locale _getInitialLanguage(SharedPreferences? prefs) {
    if (prefs == null) return const Locale('en');
    final languageCode = prefs.getString(_key);
    switch (languageCode) {
      case 'ar':
        return const Locale('ar');
      case 'ku':
        return const Locale('ku');
      case 'en':
      default:
        return const Locale('en');
    }
  }

  void setLanguage(Locale locale) {
    state = locale;
    _prefs?.setString(_key, locale.languageCode);
  }
}

// Supported Languages
class SupportedLanguages {
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
    Locale('ku'), // Kurdish
  ];

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'ku':
        return 'کوردی';
      default:
        return 'English';
    }
  }

  static String getLanguageNativeName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'ku':
        return 'کوردی';
      default:
        return 'English';
    }
  }

  static IconData getLanguageIcon(String languageCode) {
    switch (languageCode) {
      case 'en':
        return Icons.language;
      case 'ar':
        return Icons.translate;
      case 'ku':
        return Icons.translate_outlined;
      default:
        return Icons.language;
    }
  }
}