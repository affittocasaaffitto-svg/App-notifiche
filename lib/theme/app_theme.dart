import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette colori di SuperNotify AI - stile Material You vibrante
class AppColors {
  static const Color primary = Color(0xFF2D6FFF); // blu elettrico
  static const Color secondary = Color(0xFF6A4DFF); // viola
  static const Color primaryDark = Color(0xFF1B4FCC);
  static const Color secondaryDark = Color(0xFF4A33CC);

  // Tag AI
  static const Color tagHigh = Color(0xFFFF4D6D); // alta priorità (rosso)
  static const Color tagPromo = Color(0xFFFF9F1C); // promozione (arancione)
  static const Color tagGroup = Color(0xFF2EC4B6); // gruppo (verde acqua)
  static const Color tagPerson = Color(0xFF2D6FFF); // persona (blu)
  static const Color tagLow = Color(0xFF9E9E9E); // bassa (grigio)

  // Categorie
  static const Color catFamily = Color(0xFFFF6B9D);
  static const Color catWork = Color(0xFF2D6FFF);
  static const Color catSilenced = Color(0xFF9E9E9E);

  static const Color bgLight = Color(0xFFF6F7FB);
  static const Color cardLight = Colors.white;
  static const Color bgDark = Color(0xFF101018);
  static const Color cardDark = Color(0xFF1B1B26);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFF4A86FF), Color(0xFF8C6BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme)
          .apply(bodyColor: Colors.white, displayColor: Colors.white),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
