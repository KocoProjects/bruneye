import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Art education color palette
class ArtEducationColors {
  // Primary colors
  static const Color primary = Color(0xFF4A6572);      // Slate blue
  static const Color secondary = Color(0xFFF9AA33);    // Warm amber
  static const Color accent = Color(0xFF8D6E63);       // Warm brown

  // Background colors
  static const Color background = Color(0xFFF5F5F5);   // Off-white
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color surfaceMedium = Color(0xFFF0F0F0); // Light gray

  // Text colors
  static const Color textPrimary = Color(0xFF212121);  // Near black
  static const Color textSecondary = Color(0xFF757575); // Medium gray
  static const Color textLight = Color(0xFFFFFFFF);    // White


}
// Art Education Theme
final ThemeData artEducationTheme = ThemeData(
  primaryColor: ArtEducationColors.primary,
  colorScheme: ColorScheme.light(
    primary: ArtEducationColors.primary,
    secondary: ArtEducationColors.secondary,
    tertiary: ArtEducationColors.accent,
    background: ArtEducationColors.background,
    surface: ArtEducationColors.surfaceLight,
  ),

  // Background colors
  scaffoldBackgroundColor: ArtEducationColors.background,
  canvasColor: ArtEducationColors.surfaceLight,

  // Typography - Using Poppins for headings and Roboto for body text
  textTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(
      color: ArtEducationColors.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: GoogleFonts.poppins(
      color: ArtEducationColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    displaySmall: GoogleFonts.poppins(
      color: ArtEducationColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: GoogleFonts.poppins(
      color: ArtEducationColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.poppins(
      color: ArtEducationColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.roboto(
      color: ArtEducationColors.textPrimary,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    bodyMedium: GoogleFonts.roboto(
      color: ArtEducationColors.textPrimary,
      fontWeight: FontWeight.w400,
    ),
  ),


  // Card theme - Softer edges for a more friendly feel
  cardTheme: CardTheme(
    color: ArtEducationColors.surfaceLight,
    elevation: 3,
    shadowColor: ArtEducationColors.primary.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAlias,
  ),

  // Button themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ArtEducationColors.secondary,
      foregroundColor: ArtEducationColors.textPrimary,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ArtEducationColors.primary,
      side: BorderSide(color: ArtEducationColors.primary, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ArtEducationColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
  ),

  // Input decoration
  inputDecorationTheme: InputDecorationTheme(
    fillColor: ArtEducationColors.surfaceLight,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ArtEducationColors.textSecondary.withOpacity(0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ArtEducationColors.textSecondary.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ArtEducationColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.redAccent, width: 1),
    ),
    labelStyle: GoogleFonts.roboto(
      color: ArtEducationColors.textSecondary,
    ),
    hintStyle: GoogleFonts.roboto(
      color: ArtEducationColors.textSecondary.withOpacity(0.6),
    ),
  ),

  // Divider theme
  dividerTheme: DividerThemeData(
    color: ArtEducationColors.textSecondary.withOpacity(0.2),
    thickness: 1,
    space: 24,
  ),

  // Chip theme for art categories or tags
  chipTheme: ChipThemeData(
    backgroundColor: ArtEducationColors.surfaceMedium,
    disabledColor: ArtEducationColors.surfaceMedium.withOpacity(0.5),
    selectedColor: ArtEducationColors.secondary,
    secondarySelectedColor: ArtEducationColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: GoogleFonts.roboto(
      color: ArtEducationColors.textPrimary,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: GoogleFonts.roboto(
      color: ArtEducationColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  // Tab theme
  tabBarTheme: TabBarTheme(
    labelColor: ArtEducationColors.secondary,
    unselectedLabelColor: ArtEducationColors.textSecondary,
    indicatorSize: TabBarIndicatorSize.label,
    labelStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    unselectedLabelStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
  ),

  // List tile theme
  listTileTheme: ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    dense: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    selectedColor: ArtEducationColors.secondary,
    iconColor: ArtEducationColors.primary,
    textColor: ArtEducationColors.textPrimary,
  ),
);
