import 'package:flutter/material.dart';

/// Breakpoint sederhana yang dipakai di semua layar.
class Breakpoints {
  Breakpoints._();

  static const double compact = 600;
  static const double medium = 900;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;

  /// Gutter horizontal yang melebar di layar besar.
  static double gutter(double width) {
    if (width >= medium) return 32;
    if (width >= compact) return 24;
    return 20;
  }
}

/// Menjaga konten tetap di tengah dengan lebar maksimum di tablet/desktop,
/// sehingga tidak melar dari ujung ke ujung.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 1100,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
