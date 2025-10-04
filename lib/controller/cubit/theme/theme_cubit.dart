import 'package:blyft/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/theme_model.dart';
import '../../services/theme_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeService _themeService;

  ThemeCubit({ThemeService? themeService})
      : _themeService = themeService ?? ThemeService.instance,
        super(ThemeState.initial());

  // Initialize theme from storage or use default
  Future<void> initializeTheme() async {
  Log.d('<THEME_CUBIT> Initializing theme...');
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      // Ensure ThemeService is initialized first
      await _themeService.init();

      // Load the saved theme
      final savedTheme = await _themeService.loadTheme();
  Log.i('<THEME_CUBIT> Theme initialized with: ${savedTheme.name}');

      emit(
        state.copyWith(
            currentTheme: savedTheme,
            status: ThemeStatus.loaded
        ),
      );
      Log.d('<THEME_CUBIT> Emitted loaded theme: ${savedTheme.name}');
    } catch (e) {
  Log.e('<THEME_CUBIT> Error initializing theme: $e');
      emit(
        state.copyWith(
          currentTheme: AppTheme.defaultTheme,
          status: ThemeStatus.error,
          errorMessage: 'Failed to load theme: $e',
        ),
      );
    }
  }

  // Change theme and persist it
  Future<void> changeTheme(AppTheme newTheme) async {
  Log.d('<THEME_CUBIT> Changing theme to: ${newTheme.name}');

    // Emit loading state
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      // Save the theme first
      final success = await _themeService.saveTheme(newTheme);

      if (success) {
        Log.i('<THEME_CUBIT> Theme saved successfully: ${newTheme.name}');
        emit(
          state.copyWith(
              currentTheme: newTheme,
              status: ThemeStatus.loaded,
              errorMessage: null
          ),
        );
        Log.d('<THEME_CUBIT> Emitted new theme: ${newTheme.name}');
      } else {
        Log.w('<THEME_CUBIT> Failed to save theme');
        emit(
          state.copyWith(
            status: ThemeStatus.error,
            errorMessage: 'Failed to save theme',
          ),
        );
        Log.d('<THEME_CUBIT> Emitted error state after failed save');
      }
    } catch (e) {
  Log.e('<THEME_CUBIT> Error changing theme: $e');
      emit(
        state.copyWith(
          status: ThemeStatus.error,
          errorMessage: 'Error changing theme: $e',
        ),
      );
    }
  }

  // Toggle dark mode
  Future<void> toggleDarkMode(bool isDarkMode) async {
  Log.d('<THEME_CUBIT> Toggling dark mode to: $isDarkMode');
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      // Create a new theme with updated dark mode setting
      final newTheme = state.currentTheme.copyWith(isDarkMode: isDarkMode);
      final success = await _themeService.saveTheme(newTheme);

      if (success) {
        Log.i('<THEME_CUBIT> Dark mode toggled successfully');
        emit(
          state.copyWith(
              currentTheme: newTheme,
              status: ThemeStatus.loaded,
              errorMessage: null
          ),
        );
        Log.d('<THEME_CUBIT> Emitted theme after toggling dark mode: ${newTheme.name}');
      } else {
        Log.w('<THEME_CUBIT> Failed to toggle dark mode');
        emit(
          state.copyWith(
            status: ThemeStatus.error,
            errorMessage: 'Failed to toggle dark mode',
          ),
        );
        Log.d('<THEME_CUBIT> Emitted error state after failed dark mode toggle');
      }
    } catch (e) {
      Log.e("Error toggling dark mode: $e");
      emit(
        state.copyWith(
          status: ThemeStatus.error,
          errorMessage: 'Error toggling dark mode: $e',
        ),
      );
    }
  }

  // Reset theme to default
  Future<void> resetTheme() async {
  Log.d('<THEME_CUBIT> Resetting theme to default');
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      // Clear saved theme and reset to default
      await _themeService.clearTheme();

      emit(
        state.copyWith(
            currentTheme: AppTheme.defaultTheme,
            status: ThemeStatus.loaded,
            errorMessage: null
        ),
      );

      Log.i('<THEME_CUBIT> Theme reset to default successfully: ${AppTheme.defaultTheme.name}');
      Log.d('<THEME_CUBIT> Emitted default theme: ${AppTheme.defaultTheme.name}');
    } catch (e) {
      Log.e("Error resetting theme: $e");
      emit(
        state.copyWith(
          status: ThemeStatus.error,
          errorMessage: 'Error resetting theme: $e',
        ),
      );
    }
  }

  // Get current theme for backward compatibility
  AppTheme get currentTheme => state.currentTheme;

  // Check if current theme is the default theme
  bool get isDefaultTheme => state.currentTheme == AppTheme.defaultTheme;

  // Get all available themes
  List<AppTheme> get availableThemes => AppTheme.availableThemes;

  // Check if a specific theme is currently selected
  bool isThemeSelected(AppTheme theme) => state.currentTheme == theme;

  // Get current theme status
  ThemeStatus get themeStatus => state.status;

  // Check if theme is loading
  bool get isLoading => state.status == ThemeStatus.loading;
}

