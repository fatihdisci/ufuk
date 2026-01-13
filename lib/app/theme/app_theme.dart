import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Default to dark for premium feel
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}

class AppGradients {
  static const LinearGradient morning = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2C3E50), // Dark Blue
      Color(0xFF4CA1AF), // Muted Teal
    ],
  );

  static const LinearGradient noon = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF56CCF2), // Light Blue
      Color(0xFF2F80ED), // Deep Blue
    ],
  );
  
  static const LinearGradient sunset = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFff7e5f), // Coral
      Color(0xFFfeb47b), // Sunset Orange
    ],
  );

  static const LinearGradient night = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F2027), // Black/Blue
      Color(0xFF203A43),
      Color(0xFF2C5364),
    ],
  );
  
  // Default fallback
  static const LinearGradient defaultGradient = morning;
}
