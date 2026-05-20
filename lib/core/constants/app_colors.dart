import 'package:flutter/material.dart';

class AppColors {
  // Primary — Premium Medical Emerald Green (New Design Tokens)
  static const primary = Color(0xFF1D9E75);
  static const primaryLight = Color(0xFF4DC89A);
  static const primaryDark = Color(0xFF0F6E56);
  static const primarySurface = Color(0xFFF0FBF6);
  static const primaryGradientStart = Color(0xFF1D9E75);
  static const primaryGradientEnd = Color(0xFF0F6E56);

  // Secondary — Deep Navy Blue
  static const secondary = Color(0xFF1A2E4A);
  static const secondaryLight = Color(0xFF2D4A6E);
  static const secondarySurface = Color(0xFFEBF0F8);

  // Accent — Warm Coral Orange
  static const accent = Color(0xFFFF6B35);
  static const accentLight = Color(0xFFFF8F65);
  static const accentSurface = Color(0xFFFFF0EB);

  // New — Soft Purple for health/wellness
  static const health = Color(0xFF7C3AED);
  static const healthLight = Color(0xFFA78BFA);
  static const healthSurface = Color(0xFFF5F3FF);

  // Neutrals — Premium Gray Scale
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F9FC);
  static const backgroundLight = Color(0xFFF7F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0FBF6);
  static const surfaceDark = Color(0xFFE8EDF2);

  // Text — Premium Dark
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textOnDark = Color(0xFFF0F4F8);

  // Status
  static const success = Color(0xFF10B981);
  static const successSurface = Color(0xFFECFDF5);
  static const warning = Color(0xFFF59E0B);
  static const warningSurface = Color(0xFFFFFBEB);
  static const error = Color(0xFFEF4444);
  static const errorSurface = Color(0xFFFEF2F2);
  static const info = Color(0xFF3B82F6);
  static const infoSurface = Color(0xFFEFF6FF);

  // Borders
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);

  // Premium Shadows — More refined opacity
  static const shadow = Color(0x0A000000);
  static const shadowMedium = Color(0x1A000000);
  static const shadowHeavy = Color(0x29000000);
  static const shadowCard = Color(0x0F000000);

  // Enhanced Gradients
  static const gradientStart = Color(0xFF1D9E75);
  static const gradientEnd = Color(0xFF0F6E56);
  
  static const gradientGreen = LinearGradient(
    colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientGreenLight = LinearGradient(
    colors: [Color(0xFFF0FBF6), Color(0xFFD1FAE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientSunset = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8F65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientNavy = LinearGradient(
    colors: [Color(0xFF1A2E4A), Color(0xFF2D4A6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientPurple = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientCard = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientHero = LinearGradient(
    colors: [Color(0xFF1D9E75), Color(0xFF0F6E56), Color(0xFF0F6E56)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
