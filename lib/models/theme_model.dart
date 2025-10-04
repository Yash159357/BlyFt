import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final int colorValue;
  final bool isDarkMode;

  const AppTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.colorValue,
    this.isDarkMode = true,
  });

  static const defaultTheme = AppTheme(
    name: 'Blue',
    primaryColor: Colors.blue,
    secondaryColor: Colors.blueAccent,
    colorValue: 0xFF2196F3,
  );

  static const availableThemes = [
    defaultTheme,
    AppTheme(
      name: 'Purple',
      primaryColor: Colors.purple,
      secondaryColor: Colors.purpleAccent,
      colorValue: 0xFF9C27B0,
    ),
    AppTheme(
      name: 'Green',
      primaryColor: Colors.green,
      secondaryColor: Colors.greenAccent,
      colorValue: 0xFF4CAF50,
    ),
    AppTheme(
      name: 'Orange',
      primaryColor: Colors.orange,
      secondaryColor: Colors.orangeAccent,
      colorValue: 0xFFFF9800,
    ),
    AppTheme(
      name: 'Red',
      primaryColor: Colors.red,
      secondaryColor: Colors.redAccent,
      colorValue: 0xFFF44336,
    ),
    AppTheme(
      name: 'Teal',
      primaryColor: Colors.teal,
      secondaryColor: Colors.tealAccent,
      colorValue: 0xFF009688,
    ),
    AppTheme(
      name: 'Pink',
      primaryColor: Colors.pink,
      secondaryColor: Colors.pinkAccent,
      colorValue: 0xFFE91E63,
    ),
    AppTheme(
      name: 'Indigo',
      primaryColor: Colors.indigo,
      secondaryColor: Colors.indigoAccent,
      colorValue: 0xFF3F51B5,
    ),
  ];

  Map<String, dynamic> toJson() => {
    'name': name,
    'colorValue': colorValue,
    'isDarkMode': isDarkMode,
  };

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      name: json['name'],
      primaryColor: Color(json['colorValue']),
      secondaryColor: Color(json['colorValue']).withAlpha((0.8 * 255).toInt()),
      colorValue: json['colorValue'],
      isDarkMode: json['isDarkMode'] ?? true,
    );
  }

  AppTheme copyWith({
    String? name,
    Color? primaryColor,
    Color? secondaryColor,
    int? colorValue,
    bool? isDarkMode,
  }) {
    return AppTheme(
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      colorValue: colorValue ?? this.colorValue,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

MaterialColor _createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = (color.r * 255.0).round() & 0xff, g = (color.g * 255.0).round() & 0xff, b = (color.b * 255.0).round() & 0xff;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (final strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.toARGB32(), swatch);
}

ThemeData createAppTheme(AppTheme appTheme) {
  final brightness = appTheme.isDarkMode ? Brightness.dark : Brightness.light;
  final surfaceColor = appTheme.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  final onSurfaceColor = appTheme.isDarkMode ? Colors.white : Colors.black87;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    primarySwatch: _createMaterialColor(appTheme.primaryColor),
    primaryColor: appTheme.primaryColor,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: appTheme.primaryColor,
      secondary: appTheme.secondaryColor,
      surface: surfaceColor,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: onSurfaceColor,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: onSurfaceColor,
      elevation: 0,
      iconTheme: IconThemeData(color: appTheme.primaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: appTheme.primaryColor,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return appTheme.primaryColor;
        }
        return Colors.grey[400];
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return appTheme.primaryColor.withAlpha((0.3 * 255).toInt());
        }
        return Colors.grey[800];
      }),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 1,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: onSurfaceColor),
      bodyMedium: TextStyle(color: onSurfaceColor),
      titleLarge: TextStyle(
        color: onSurfaceColor,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

