import 'package:flutter/material.dart';

class AppColors {
  // ─── Dark Theme Base ───
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF141929);
  static const Color surfaceLight = Color(0xFF1C2137);
  static const Color cardDark = Color(0xFF161B2E);
  
  // ─── Accent Colors ───
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFB388FF);
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentGreen = Color(0xFF69F0AE);
  
  // ─── Text ───
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF8F93A8);
  static const Color textMuted = Color(0xFF5A5F7A);
  
  // ─── Utilities ───
  static const Color border = Color(0xFF2A2F45);
  static const Color borderLight = Color(0xFF353A52);
  static const Color success = Color(0xFF69F0AE);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFAB40);
  
  // ─── Glass Effect ───
  static const Color glassWhite = Color(0x15FFFFFF);
  static const Color glassBorder = Color(0x25FFFFFF);
  
  // ─── Gradients ───
  static const List<Color> primaryGradient = [
    Color(0xFF7C4DFF),
    Color(0xFFB388FF),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF00E5FF),
    Color(0xFF7C4DFF),
  ];
  
  static const List<Color> pinkGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFFF8A65),
  ];
  
  static const List<Color> greenGradient = [
    Color(0xFF69F0AE),
    Color(0xFF00E5FF),
  ];

  static const List<Color> sunsetGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFFAB40),
  ];

  // ─── Shadows ───
  static final BoxShadow softShadow = BoxShadow(
    color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
  
  static final BoxShadow glowShadow = BoxShadow(
    color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
    blurRadius: 32,
    offset: const Offset(0, 4),
  );

  // ─── Light Theme (Optional Toggle) ───
  static const Color backgroundLight = Color(0xFFF5F7FF);
  static const Color surfaceLightTheme = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color borderLightTheme = Color(0xFFE5E7EB);
}

