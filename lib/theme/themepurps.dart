import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const MaterialColor customSwatch = MaterialColor(
    0xFF000000, // black
    <int, Color>{
        50: Color(0xFFFFFFFF),   // white
        100: Color(0xFFE0E0E0),  // light gray
        200: Color(0xFFB0B0B0),  // gray
        300: Color(0xFF808080),  // medium gray
        400: Color(0xFF505050),  // dark gray
        500: Color(0xFF000000),  // black (primary)
        600: Color(0xFF000000),
        700: Color(0xFF000000),
        800: Color(0xFF000000),
        900: Color(0xFF000000),
    },
);

final ThemeData myTheme = ThemeData(
    // Using white as background
    scaffoldBackgroundColor: Colors.white,

    // Primary and secondary colors
    primaryColor: Colors.black,
    primarySwatch: customSwatch,

    // Text theme
    textTheme: GoogleFonts.notoSansTextTheme().apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
    ),

    // AppBar theme
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
    ),

    // Card theme
    cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 2),
        ),
    ),

    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
            ),
        ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
    ),
);