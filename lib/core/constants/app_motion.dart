import 'package:flutter/widgets.dart';

/// Token durasi & kurva animasi yang dipakai di seluruh aplikasi, supaya
/// semua gerakan punya ritme yang sama.
class AppMotion {
  AppMotion._();

  static const Duration press = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration page = Duration(milliseconds: 380);
  static const Duration pageReverse = Duration(milliseconds: 260);
  static const Duration stagger = Duration(milliseconds: 45);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve bounce = Curves.easeOutBack;

  /// Delay bertingkat untuk item ke-[index], dibatasi agar daftar panjang
  /// tidak menunggu terlalu lama.
  static Duration staggerFor(int index, {int max = 8}) =>
      stagger * (index < max ? index : max);

  /// True bila pengguna mengaktifkan "kurangi animasi" di sistem.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}
