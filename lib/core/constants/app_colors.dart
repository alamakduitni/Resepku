import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF15100C);
  static const Color surface = Color(0xFF241C15);
  static const Color surfaceVariant = surface;
  static const Color surfaceElevated = Color(0xFF2E2318);
  static const Color surfaceHover = Color(0xFF33271B);
  static const Color primary = Color(0xFFFF8C42);
  static const Color primaryLight = Color(0xFFFFB380);
  static const Color primaryDark = Color(0xFFE56A1F);
  static const Color primaryPale = Color(0xFF402A16);
  static const Color primaryMuted = Color(0x33FF8C42);
  static const Color textPrimary = Color(0xFFF6EEE4);
  static const Color textSecondary = Color(0xFFB7AA9C);
  // Dinaikkan dari 0xFF8A7A68 agar kontras teks kecil tetap >= 4.5:1.
  static const Color textMuted = Color(0xFF9C8B78);
  static const Color textOnPrimary = Colors.white;
  static const Color disabledForeground = Color(0xFF8A7A68);
  static const Color disabledBackground = Color(0xFF1E1712);
  static const Color border = Color(0xFF3B2E22);
  static const Color borderStrong = Color(0xFF55412F);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF42A5F5);
  static const Color star = Color(0xFFFFC542);

  // Warna aksen untuk avatar lucu & ilustrasi.
  static const Color blush = Color(0xFFFF7A8A);
  static const Color mint = Color(0xFF7ED6B4);
  static const Color sky = Color(0xFF8CC8FF);
  static const Color lilac = Color(0xFFC3A6FF);
  static const Color butter = Color(0xFFFFD66B);
  static const Color peach = Color(0xFFFFB38A);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFA25F), Color(0xFFF2711C)],
  );

  static List<BoxShadow> glow(Color color, {double strength = 0.35}) => [
        BoxShadow(
          color: color.withValues(alpha: strength),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}
