import 'dart:convert';
import 'package:blyft/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/theme_model.dart';

class ThemeService {
  static const String _themeKey = 'selected_theme';
  static ThemeService? _instance;
  SharedPreferences? _prefs;

  // Singleton pattern
  static ThemeService get instance {
    try {
      Log.d("THEME_SERVICE: Getting singleton instance");
      _instance ??= ThemeService._();
      return _instance!;
    } catch (e, stackTrace) {
      Log.e("THEME_SERVICE: Error getting singleton instance", e, stackTrace);
      _instance = ThemeService._();
      return _instance!;
    }
  }

  ThemeService._() {
    Log.d("THEME_SERVICE: Initializing ThemeService singleton");
  }

  // Initialize the service
  Future<void> init() async {
    try {
      Log.i("THEME_SERVICE: Initializing ThemeService");
      _prefs = await SharedPreferences.getInstance();
      Log.i("THEME_SERVICE: ThemeService initialized successfully");
    } catch (e, stackTrace) {
      Log.e("THEME_SERVICE: Error initializing ThemeService", e, stackTrace);
      throw Exception("Failed to initialize ThemeService: $e");
    }
  }

  // Save theme to local storage
  Future<bool> saveTheme(AppTheme theme) async {
    try {
      Log.i("THEME_SERVICE: Starting save theme - themeName: ${theme.name}");
      await _ensureInitialized();
      final themeJson = jsonEncode(theme.toJson());
      Log.d("THEME_SERVICE: Saving theme JSON: $themeJson");

      final result = await _prefs!.setString(_themeKey, themeJson);

      if (result) {
        Log.i("THEME_SERVICE: Theme saved successfully - ${theme.name}");
      } else {
        Log.e("THEME_SERVICE: Failed to save theme - ${theme.name}");
      }

      return result;
    } catch (e, stackTrace) {
      Log.e("THEME_SERVICE: Error saving theme", e, stackTrace);
      return false;
    }
  }

  // Load theme from local storage
  Future<AppTheme> loadTheme() async {
    try {
      Log.i("THEME_SERVICE: Starting load theme");
      await _ensureInitialized();
      final themeJson = _prefs!.getString(_themeKey);
      Log.d("THEME_SERVICE: Retrieved theme JSON: $themeJson");

      if (themeJson != null) {
        try {
          final themeMap = jsonDecode(themeJson) as Map<String, dynamic>;
          final loadedTheme = AppTheme.fromJson(themeMap);
          Log.i("THEME_SERVICE: Theme loaded successfully - ${loadedTheme.name}");
          return loadedTheme;
        } catch (e, stackTrace) {
          Log.e("THEME_SERVICE: Error parsing saved theme JSON", e, stackTrace);
          Log.w("THEME_SERVICE: Falling back to default theme due to parse error");
        }
      } else {
        Log.w("THEME_SERVICE: No saved theme found, using default");
      }
    } catch (e, stackTrace) {
      Log.e("THEME_SERVICE: Error loading theme", e, stackTrace);
    }

    // Return default theme if loading fails
    Log.i("THEME_SERVICE: Returning default theme");
    return AppTheme.defaultTheme;
  }

  // Clear saved theme
  Future<bool> clearTheme() async {
    try {
      Log.i("THEME_SERVICE: Starting clear theme");
      await _ensureInitialized();
      Log.d("THEME_SERVICE: Removing theme from preferences");

      final result = await _prefs!.remove(_themeKey);

      if (result) {
        Log.i("THEME_SERVICE: Theme cleared successfully");
      } else {
        Log.e("THEME_SERVICE: Failed to clear theme");
      }

      return result;
    } catch (e, stackTrace) {
      Log.e("THEME_SERVICE: Error clearing theme", e, stackTrace);
      return false;
    }
  }

  // Check if theme is saved
  Future<bool> hasTheme() async {
    try {
      Log.d("THEME_SERVICE: Checking if theme exists");
      await _ensureInitialized();
      final hasTheme = _prefs!.containsKey(_themeKey);
      Log.d("THEME_SERVICE: Theme exists check result: $hasTheme");
      return hasTheme;
    } catch (e, stackTrace) {
      Log.e("THEME_SERVICE: Error checking if theme exists", e, stackTrace);
      return false;
    }
  }

  // Get saved theme synchronously (for immediate access after initialization)
  AppTheme? getSavedThemeSync() {
    try {
      Log.d("THEME_SERVICE: Getting saved theme synchronously");

      if (_prefs == null) {
        Log.w("THEME_SERVICE: SharedPreferences not initialized for sync access");
        return null;
      }

      final themeJson = _prefs!.getString(_themeKey);
      if (themeJson != null) {
        try {
          final themeMap = jsonDecode(themeJson) as Map<String, dynamic>;
          final theme = AppTheme.fromJson(themeMap);
          Log.d("THEME_SERVICE: Retrieved theme synchronously - ${theme.name}");
          return theme;
        } catch (e, stackTrace) {
          Log.e("THEME_SERVICE: Error parsing theme in sync method", e, stackTrace);
        }
      } else {
        Log.d("THEME_SERVICE: No theme found in sync access");
      }
    } catch (e, stackTrace) {
      Log.e("THEME_SERVICE: Error getting saved theme synchronously", e, stackTrace);
    }
    return null;
  }

  // Ensure SharedPreferences is initialized
  Future<void> _ensureInitialized() async {
    try {
      if (_prefs == null) {
        Log.d("THEME_SERVICE: SharedPreferences not initialized, initializing now");
        _prefs = await SharedPreferences.getInstance();
        Log.d("THEME_SERVICE: SharedPreferences initialized in _ensureInitialized");
      } else {
        Log.d("THEME_SERVICE: SharedPreferences already initialized");
      }
    } catch (e, stackTrace) {
      Log.e("THEME_SERVICE: Error ensuring initialization", e, stackTrace);
      throw Exception("Failed to initialize SharedPreferences: $e");
    }
  }
}

