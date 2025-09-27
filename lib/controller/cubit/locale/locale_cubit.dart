import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleInitial()) {
    _loadLocale();
  }

  static const String _localeKey = 'selected_locale';

  // Supported languages with their locale codes and display names
  static const Map<String, String> supportedLanguages = {
    'English': 'en',
    'Spanish': 'es', 
    'French': 'fr',
    'German': 'de',
    'Italian': 'it',
    'Japanese': 'ja',
    'Chinese': 'zh',
    'Russian': 'ru',
    'Hindi': 'hi',
  };

  void _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey) ?? 'en';
      print('[LocaleCubit] Loading saved locale: $localeCode');
      emit(LocaleLoaded(locale: Locale(localeCode)));
    } catch (e) {
      print('[LocaleCubit] Error loading locale: $e');
      emit(const LocaleLoaded(locale: Locale('en')));
    }
  }

  void changeLocale(String languageName) async {
    try {
      final localeCode = supportedLanguages[languageName];
      print('[LocaleCubit] Changing locale by language name: $languageName -> $localeCode');
      if (localeCode != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localeKey, localeCode);
        emit(LocaleLoaded(locale: Locale(localeCode)));
        print('[LocaleCubit] Locale changed successfully to: $localeCode');
      } else {
        print('[LocaleCubit] Invalid language name: $languageName');
      }
    } catch (e) {
      print('[LocaleCubit] Error changing locale by language name: $e');
      // Handle error - stay with current locale
    }
  }

  void changeLocaleByCode(String localeCode) async {
    try {
      print('[LocaleCubit] Changing locale by code: $localeCode');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, localeCode);
      emit(LocaleLoaded(locale: Locale(localeCode)));
      print('[LocaleCubit] Locale changed successfully to: $localeCode');
    } catch (e) {
      print('[LocaleCubit] Error changing locale by code: $e');
      // Handle error - stay with current locale
    }
  }

  String getCurrentLanguageName() {
    if (state is LocaleLoaded) {
      final locale = (state as LocaleLoaded).locale;
      return supportedLanguages.entries
          .firstWhere(
            (entry) => entry.value == locale.languageCode,
            orElse: () => const MapEntry('English', 'en'),
          )
          .key;
    }
    return 'English';
  }

  Locale getCurrentLocale() {
    if (state is LocaleLoaded) {
      return (state as LocaleLoaded).locale;
    }
    return const Locale('en');
  }
}