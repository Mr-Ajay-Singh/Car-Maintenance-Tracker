import 'package:flutter/material.dart';

/// AppTheme - Application theme configuration
class AppTheme {
  // Warm coral color palette for CarLog app
  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFF9816E), // Warm Coral
      onPrimary: Color(0xFFFFFFFF), // White
      secondary: Color(0xFFFFB5A8), // Soft Peach
      onSecondary: Color(0xFF4E3A2E), // Dark Warm Brown
      tertiary: Color(0xFFFFF8F6), // Soft Light Cream
      onTertiary: Color(0xFF1E3C40), // Dark Teal
      surface: Color(0xFFFFF8F6), // Very Light Rosy Off-White
      onSurface: Color(0xFF504442), // Dark Warm Gray
      error: Color(0xFFB71C1C), // Deep Red
      onError: Color(0xFFFFFFFF), // White
      errorContainer: Color(0xFFFFDAD6), // Light Red Container
      onErrorContainer: Color(0xFF410002), // Dark Red
      outline: Color(0xFF9A8C8A), // Muted Warm Gray
      outlineVariant: Color(0xFFEADFE0), // Light Rosy Gray
      scrim: Color(0xFF000000), // Black
      shadow: Color(0xFF000000), // Black
      surfaceDim: Color(0xFFFDEEEA), // Dim Surface
      surfaceBright: Color(0xFFFFFDFB), // Bright Surface
      surfaceContainerLowest: Color(0xFFFFFFFF), // Pure White
      surfaceContainerLow: Color(0xFFFEF1EE), // Light Warm
      surfaceContainer: Color(0xFFFCEAE5), // Rosy Peach
      surfaceContainerHigh: Color(0xFFF9E3DD), // Pronounced Tint
      surfaceContainerHighest: Color(0xFFF7DCD6), // Strongest Tint
      inverseSurface: Color(0xFF382E2D), // Dark Reddish Brown
      onInverseSurface: Color(0xFFFFF0EE), // Light Peachy Off-White
      inversePrimary: Color(0xFFFFB5A8), // Light Coral
      primaryContainer: Color(0xFFFFDAD6), // Light Coral Container
      onPrimaryContainer: Color(0xFF410002), // Dark on Container
      secondaryContainer: Color(0xFFFFEBE9), // Very Light Peach
      onSecondaryContainer: Color(0xFF2C1512), // Very Dark Brown
      tertiaryContainer: Color(0xFFE6F4EA), // Light Green Tint
      onTertiaryContainer: Color(0xFF002106), // Very Dark Green
    ),
    fontFamily: 'PTSerif',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFFB5A8), // Light Coral (inverse of light)
      onPrimary: Color(0xFF690003), // Dark Red
      secondary: Color(0xFFE2C1BD), // Light Peach
      onSecondary: Color(0xFF442926), // Dark Brown
      tertiary: Color(0xFFB3CDC2), // Light Teal
      onTertiary: Color(0xFF1F352D), // Dark Teal
      surface: Color(0xFF1A1110), // Very Dark Surface
      onSurface: Color(0xFFF0DEDD), // Light Rosy
      error: Color(0xFFFFB4AB), // Light Red
      onError: Color(0xFF690005), // Dark Red
      errorContainer: Color(0xFF93000A), // Dark Red Container
      onErrorContainer: Color(0xFFFFDAD6), // Light Red
      outline: Color(0xFF9A8C8A), // Muted Gray
      outlineVariant: Color(0xFF534341), // Dark Gray
      scrim: Color(0xFF000000), // Black
      shadow: Color(0xFF000000), // Black
      surfaceDim: Color(0xFF1A1110), // Dim Surface
      surfaceBright: Color(0xFF423735), // Bright Surface
      surfaceContainerLowest: Color(0xFF150C0B), // Darkest
      surfaceContainerLow: Color(0xFF231918), // Very Dark
      surfaceContainer: Color(0xFF271D1C), // Dark
      surfaceContainerHigh: Color(0xFF322826), // Medium Dark
      surfaceContainerHighest: Color(0xFF3D3231), // Light Dark
      inverseSurface: Color(0xFFF0DEDD), // Light Surface
      onInverseSurface: Color(0xFF382E2D), // Dark Text
      inversePrimary: Color(0xFFC00009), // Dark Coral
      primaryContainer: Color(0xFF93000A), // Dark Coral Container
      onPrimaryContainer: Color(0xFFFFDAD6), // Light on Container
      secondaryContainer: Color(0xFF5D3F3C), // Dark Peach Container
      onSecondaryContainer: Color(0xFFFFDAD6), // Light on Container
      tertiaryContainer: Color(0xFF374B44), // Dark Teal Container
      onTertiaryContainer: Color(0xFFCFE9DD), // Light on Container
    ),
    fontFamily: 'PTSerif',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
