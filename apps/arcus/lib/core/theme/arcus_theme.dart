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
}

class ArcusTheme {
  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: ArcusColors.moss,
      brightness: Brightness.light,
      primary: ArcusColors.spruce,
      secondary: ArcusColors.brass,
      surface: ArcusColors.mist,
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
          side: BorderSide(color: ArcusColors.spruce.withValues(alpha: 0.08)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: ArcusColors.spruce,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: ArcusColors.brass.withValues(alpha: 0.25),
        backgroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkNavy() {
    final base = ColorScheme.fromSeed(
      seedColor: ArcusColors.moss,
      brightness: Brightness.dark,
      primary: ArcusColors.brassSoft,
      secondary: ArcusColors.moss,
      surface: ArcusColors.navyCard,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: ArcusColors.navy,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: ArcusColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: ArcusColors.navyCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
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
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: ArcusColors.brass.withValues(alpha: 0.2),
        backgroundColor: ArcusColors.navyCard,
      ),
    );
  }
}
