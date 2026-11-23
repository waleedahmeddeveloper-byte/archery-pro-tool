import 'package:material_ui/material_ui.dart';

/// Original Arcus design tokens — spruce + brass (not the reference site).
abstract final class ArcusColors {
  static const spruce = Color(0xFF1B3A2F);
  static const spruceDeep = Color(0xFF0F241C);
  static const moss = Color(0xFF2F6B4F);
  static const brass = Color(0xFFC4A35A);
  static const brassSoft = Color(0xFFE2C98A);
  static const mist = Color(0xFFF3F1EA);
  static const ink = Color(0xFF14201A);
  static const navy = Color(0xFF0B1520);
  static const navyCard = Color(0xFF152433);
  static const danger = Color(0xFFB42318);
  /// High-contrast text on spruce/moss CTAs (≥4.5:1 on spruce).
  static const onSpruce = Color(0xFFFFFFFF);
  /// Slightly brighter than white70 for body on dark green banners.
  static const onSpruceMuted = Color(0xFFE8F0EB);
}

class ArcusTheme {
  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: ArcusColors.moss,
      brightness: Brightness.light,
      primary: ArcusColors.spruce,
      onPrimary: ArcusColors.onSpruce,
      secondary: ArcusColors.brass,
      onSecondary: ArcusColors.ink,
      surface: ArcusColors.mist,
      onSurface: ArcusColors.ink,
      onSurfaceVariant: const Color(0xFF3D4A42),
      error: ArcusColors.danger,
      onError: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: ArcusColors.mist,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: ArcusColors.mist,
        foregroundColor: ArcusColors.ink,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ArcusColors.spruce.withValues(alpha: 0.12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: ArcusColors.spruce,
          foregroundColor: ArcusColors.onSpruce,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: ArcusColors.spruce,
          side: const BorderSide(color: ArcusColors.spruce, width: 1.4),
        ),
      ),
      textTheme: ThemeData(brightness: Brightness.light).textTheme.apply(
            bodyColor: ArcusColors.ink,
            displayColor: ArcusColors.ink,
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: Color(0xFF3D4A42)),
        helperStyle: const TextStyle(color: Color(0xFF3D4A42)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: ArcusColors.brass.withValues(alpha: 0.35),
        backgroundColor: Colors.white,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? ArcusColors.spruce : const Color(0xFF3D4A42),
          );
        }),
      ),
    );
  }

  static ThemeData darkNavy() {
    final base = ColorScheme.fromSeed(
      seedColor: ArcusColors.moss,
      brightness: Brightness.dark,
      primary: ArcusColors.brassSoft,
      onPrimary: ArcusColors.navy,
      secondary: ArcusColors.moss,
      onSecondary: Colors.white,
      surface: ArcusColors.navyCard,
      onSurface: const Color(0xFFF2F5F7),
      onSurfaceVariant: const Color(0xFFC5D0D8),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: ArcusColors.navy,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: ArcusColors.navy,
        foregroundColor: Color(0xFFF2F5F7),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: ArcusColors.navyCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: ArcusColors.brass,
          foregroundColor: ArcusColors.navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: ArcusColors.brassSoft,
          side: const BorderSide(color: ArcusColors.brassSoft, width: 1.4),
        ),
      ),
      textTheme: ThemeData(brightness: Brightness.dark).textTheme.apply(
            bodyColor: const Color(0xFFF2F5F7),
            displayColor: const Color(0xFFF2F5F7),
          ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: ArcusColors.brass.withValues(alpha: 0.28),
        backgroundColor: ArcusColors.navyCard,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? ArcusColors.brassSoft
                : const Color(0xFFC5D0D8),
          );
        }),
      ),
    );
  }
}
