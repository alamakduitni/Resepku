import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_motion.dart';

enum CuteAccessory { chefHat, bow, sprout, catEars, none }

/// Data tampilan satu karakter avatar.
class CuteAvatarData {
  final String name;
  final Color background;
  final Color skin;
  final Color shirt;
  final CuteAccessory accessory;
  final Color accessoryColor;

  const CuteAvatarData({
    required this.name,
    required this.background,
    required this.skin,
    required this.shirt,
    required this.accessory,
    required this.accessoryColor,
  });

  static const List<CuteAvatarData> presets = [
    CuteAvatarData(
      name: 'Chef Oren',
      background: AppColors.peach,
      skin: Color(0xFFFFE2C6),
      shirt: Colors.white,
      accessory: CuteAccessory.chefHat,
      accessoryColor: Colors.white,
    ),
    CuteAvatarData(
      name: 'Pita Stroberi',
      background: Color(0xFFFFB4C1),
      skin: Color(0xFFFFE6D3),
      shirt: Color(0xFFFF7A8A),
      accessory: CuteAccessory.bow,
      accessoryColor: Color(0xFFE84A64),
    ),
    CuteAvatarData(
      name: 'Tunas Matcha',
      background: AppColors.mint,
      skin: Color(0xFFFFE9CF),
      shirt: Color(0xFF3FAF83),
      accessory: CuteAccessory.sprout,
      accessoryColor: Color(0xFF2E9E6F),
    ),
    CuteAvatarData(
      name: 'Kucing Mochi',
      background: AppColors.lilac,
      skin: Color(0xFFFFF1E3),
      shirt: Color(0xFF8E6CE0),
      accessory: CuteAccessory.catEars,
      accessoryColor: Color(0xFFFFB4C1),
    ),
    CuteAvatarData(
      name: 'Koki Biru',
      background: AppColors.sky,
      skin: Color(0xFFF6D3B3),
      shirt: Colors.white,
      accessory: CuteAccessory.chefHat,
      accessoryColor: Colors.white,
    ),
    CuteAvatarData(
      name: 'Mentega',
      background: AppColors.butter,
      skin: Color(0xFFFFE2C6),
      shirt: Color(0xFFFF8C42),
      accessory: CuteAccessory.none,
      accessoryColor: Colors.transparent,
    ),
  ];

  /// Memilih preset secara konsisten berdasarkan teks (mis. nama pengguna).
  static CuteAvatarData fromSeed(String seed) {
    final hash =
        seed.codeUnits.fold<int>(7, (h, c) => (h * 31 + c) & 0x7fffffff);
    return presets[hash % presets.length];
  }
}

/// Avatar karakter lucu yang digambar dengan vektor: berkedip, melayang
/// pelan, menutup mata (mode "malu"), dan tersenyum lebar saat disentuh.
class CuteAvatar extends StatefulWidget {
  final CuteAvatarData data;
  final double size;

  /// Gerakan idle (melayang & berkedip).
  final bool animate;

  /// Menutup mata dengan tangan — dipakai saat mengetik kata sandi.
  final bool coverEyes;

  /// Paksa ekspresi gembira.
  final bool happy;

  /// Sentuh avatar untuk membuatnya tersenyum & melompat kecil.
  final bool interactive;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const CuteAvatar({
    super.key,
    required this.data,
    this.size = 48,
    this.animate = true,
    this.coverEyes = false,
    this.happy = false,
    this.interactive = true,
    this.onTap,
    this.semanticLabel,
  });

  @override
  State<CuteAvatar> createState() => _CuteAvatarState();
}

class _CuteAvatarState extends State<CuteAvatar> with TickerProviderStateMixin {
  // Satu siklus idle 4 detik: kedipan terjadi di ujung siklus.
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration:
        Duration(milliseconds: 3600 + (widget.data.name.length * 97) % 900),
  );
  late final AnimationController _joy = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _cover = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
    value: widget.coverEyes ? 1 : 0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncIdle();
  }

  @override
  void didUpdateWidget(covariant CuteAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coverEyes != widget.coverEyes) {
      widget.coverEyes ? _cover.forward() : _cover.reverse();
    }
    if (oldWidget.animate != widget.animate) _syncIdle();
  }

  void _syncIdle() {
    if (widget.animate && !AppMotion.reduced(context)) {
      if (!_idle.isAnimating) _idle.repeat();
    } else {
      _idle.stop();
      _idle.value = 0;
    }
  }

  void _celebrate() {
    HapticFeedback.lightImpact();
    if (AppMotion.reduced(context)) {
      _joy.value = 0.5;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _joy.value = 0;
      });
    } else {
      _joy.forward(from: 0);
    }
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _idle.dispose();
    _joy.dispose();
    _cover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = AnimatedBuilder(
      animation: Listenable.merge([_idle, _joy, _cover]),
      builder: (context, _) {
        final t = _idle.value;
        // Kedip singkat di 92%-98% siklus.
        double blink = 0;
        if (t > 0.92 && t < 0.98) {
          blink = 1 - ((t - 0.95).abs() / 0.03);
        }
        final joy = math.sin(_joy.value * math.pi); // 0 → 1 → 0
        final bob = math.sin(t * 2 * math.pi) * widget.size * 0.015;
        final hop = -joy * widget.size * 0.08;

        return Transform.translate(
          offset: Offset(0, bob + hop),
          child: Transform.scale(
            scale: 1 + joy * 0.06,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _CuteAvatarPainter(
                data: widget.data,
                blink: blink,
                happy: widget.happy ? 1 : joy,
                cover: _cover.value,
              ),
            ),
          ),
        );
      },
    );

    final labelled = Semantics(
      image: true,
      label: widget.semanticLabel ?? 'Avatar ${widget.data.name}',
      child: SizedBox.square(dimension: widget.size, child: avatar),
    );

    if (!widget.interactive) return labelled;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _celebrate,
        child: labelled,
      ),
    );
  }
}

class _CuteAvatarPainter extends CustomPainter {
  final CuteAvatarData data;
  final double blink;
  final double happy;
  final double cover;

  _CuteAvatarPainter({
    required this.data,
    required this.blink,
    required this.happy,
    required this.cover,
  });

  static const _ink = Color(0xFF3A2416);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    canvas.drawCircle(center, radius, Paint()..color = data.background);

    canvas.save();
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Pola titik halus di latar.
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    for (final p in const [
      Offset(0.2, 0.25),
      Offset(0.82, 0.3),
      Offset(0.15, 0.7),
      Offset(0.86, 0.72)
    ]) {
      canvas.drawCircle(Offset(p.dx * w, p.dy * h), w * 0.03, dotPaint);
    }

    // Badan / baju.
    final shirtRect = Rect.fromCenter(
      center: Offset(w / 2, h * 1.04),
      width: w * 0.78,
      height: h * 0.5,
    );
    canvas.drawOval(shirtRect, Paint()..color = data.shirt);
    if (data.shirt == Colors.white) {
      // Kancing baju koki.
      final btn = Paint()..color = AppColors.primary;
      canvas.drawCircle(Offset(w * 0.46, h * 0.9), w * 0.022, btn);
      canvas.drawCircle(Offset(w * 0.54, h * 0.9), w * 0.022, btn);
    }

    final faceCenter = Offset(w / 2, h * 0.55);
    final faceR = w * 0.28;

    if (data.accessory == CuteAccessory.catEars) {
      _drawCatEars(canvas, faceCenter, faceR);
    }

    // Wajah.
    canvas.drawCircle(faceCenter, faceR, Paint()..color = data.skin);

    _drawEyes(canvas, faceCenter, faceR);
    _drawBlush(canvas, faceCenter, faceR);
    _drawMouth(canvas, faceCenter, faceR);

    switch (data.accessory) {
      case CuteAccessory.chefHat:
        _drawChefHat(canvas, faceCenter, faceR, w);
      case CuteAccessory.bow:
        _drawBow(canvas, faceCenter, faceR);
      case CuteAccessory.sprout:
        _drawSprout(canvas, faceCenter, faceR);
      case CuteAccessory.catEars:
      case CuteAccessory.none:
        break;
    }

    if (cover > 0) _drawHands(canvas, faceCenter, faceR, h);

    canvas.restore();
  }

  void _drawEyes(Canvas canvas, Offset c, double r) {
    final eyeY = c.dy - r * 0.02;
    final dx = r * 0.4;
    final ink = Paint()..color = _ink;

    if (happy > 0.45) {
      // Mata tersenyum ^ ^
      final stroke = Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.09
        ..strokeCap = StrokeCap.round;
      for (final sx in [-1, 1]) {
        final ex = c.dx + dx * sx;
        final path = Path()
          ..moveTo(ex - r * 0.13, eyeY + r * 0.05)
          ..quadraticBezierTo(
              ex, eyeY - r * 0.15, ex + r * 0.13, eyeY + r * 0.05);
        canvas.drawPath(path, stroke);
      }
      return;
    }

    final eyeH = r * 0.26 * (1 - blink * 0.88);
    for (final sx in [-1, 1]) {
      final ex = c.dx + dx * sx;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, eyeY), width: r * 0.2, height: eyeH),
        ink,
      );
      if (blink < 0.5) {
        canvas.drawCircle(
          Offset(ex + r * 0.035, eyeY - eyeH * 0.22),
          r * 0.045,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  void _drawBlush(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = AppColors.blush.withValues(alpha: 0.45 + happy * 0.25);
    for (final sx in [-1, 1]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + r * 0.62 * sx, c.dy + r * 0.28),
          width: r * 0.3,
          height: r * 0.17,
        ),
        paint,
      );
    }
  }

  void _drawMouth(Canvas canvas, Offset c, double r) {
    final y = c.dy + r * 0.32;
    if (happy > 0.2) {
      final open = r * 0.22 * happy.clamp(0.0, 1.0);
      final mouth = Path()
        ..moveTo(c.dx - r * 0.2, y)
        ..quadraticBezierTo(c.dx, y + open * 2, c.dx + r * 0.2, y)
        ..close();
      canvas.drawPath(mouth, Paint()..color = const Color(0xFF8A2E2E));
      canvas.save();
      canvas.clipPath(mouth);
      canvas.drawCircle(Offset(c.dx, y + open * 1.3), r * 0.12,
          Paint()..color = const Color(0xFFFF7A8A));
      canvas.restore();
      return;
    }
    final smile = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(c.dx - r * 0.13, y)
      ..quadraticBezierTo(c.dx, y + r * 0.14, c.dx + r * 0.13, y);
    canvas.drawPath(path, smile);
  }

  void _drawChefHat(Canvas canvas, Offset c, double r, double w) {
    final paint = Paint()..color = data.accessoryColor;
    final shade = Paint()..color = const Color(0xFFE9E1D8);
    final bandTop = c.dy - r * 1.18;
    final band = RRect.fromRectAndRadius(
      Rect.fromLTWH(c.dx - r * 0.82, bandTop, r * 1.64, r * 0.42),
      Radius.circular(r * 0.12),
    );
    for (final p in [
      Offset(c.dx - r * 0.5, bandTop - r * 0.12),
      Offset(c.dx + r * 0.5, bandTop - r * 0.12),
      Offset(c.dx, bandTop - r * 0.32),
    ]) {
      canvas.drawCircle(p, r * 0.44, paint);
    }
    canvas.drawRRect(band, paint);
    canvas.drawRect(
      Rect.fromLTWH(band.left, band.bottom - r * 0.08, band.width, r * 0.08),
      shade,
    );
  }

  void _drawBow(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = data.accessoryColor;
    final knot = Offset(c.dx + r * 0.55, c.dy - r * 0.82);
    final left = Path()
      ..moveTo(knot.dx, knot.dy)
      ..lineTo(knot.dx - r * 0.42, knot.dy - r * 0.26)
      ..lineTo(knot.dx - r * 0.42, knot.dy + r * 0.26)
      ..close();
    final right = Path()
      ..moveTo(knot.dx, knot.dy)
      ..lineTo(knot.dx + r * 0.42, knot.dy - r * 0.26)
      ..lineTo(knot.dx + r * 0.42, knot.dy + r * 0.26)
      ..close();
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
    canvas.drawCircle(knot, r * 0.12, Paint()..color = const Color(0xFFFF9EAE));
  }

  void _drawSprout(Canvas canvas, Offset c, double r) {
    final stem = Paint()
      ..color = data.accessoryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round;
    final top = Offset(c.dx, c.dy - r * 1.32);
    canvas.drawLine(Offset(c.dx, c.dy - r * 0.95), top, stem);
    final leaf = Paint()..color = data.accessoryColor;
    canvas.save();
    canvas.translate(top.dx, top.dy);
    canvas.rotate(-0.6);
    canvas.drawOval(
        Rect.fromLTWH(-r * 0.42, -r * 0.13, r * 0.42, r * 0.26), leaf);
    canvas.rotate(1.2);
    canvas.drawOval(Rect.fromLTWH(0, -r * 0.13, r * 0.42, r * 0.26), leaf);
    canvas.restore();
  }

  void _drawCatEars(Canvas canvas, Offset c, double r) {
    final outer = Paint()..color = data.skin;
    final inner = Paint()..color = data.accessoryColor;
    for (final sx in [-1, 1]) {
      final baseX = c.dx + r * 0.62 * sx;
      final ear = Path()
        ..moveTo(baseX - r * 0.36, c.dy - r * 0.55)
        ..lineTo(baseX + r * 0.12 * sx, c.dy - r * 1.22)
        ..lineTo(baseX + r * 0.36, c.dy - r * 0.55)
        ..close();
      canvas.drawPath(ear, outer);
      final innerEar = Path()
        ..moveTo(baseX - r * 0.2, c.dy - r * 0.62)
        ..lineTo(baseX + r * 0.1 * sx, c.dy - r * 1.04)
        ..lineTo(baseX + r * 0.2, c.dy - r * 0.62)
        ..close();
      canvas.drawPath(innerEar, inner);
    }
  }

  void _drawHands(Canvas canvas, Offset c, double r, double h) {
    final paint = Paint()..color = data.skin;
    final outline = Paint()
      ..color = _ink.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04;
    final targetY = c.dy - r * 0.02;
    final startY = h + r * 0.4;
    final y = startY + (targetY - startY) * Curves.easeOutBack.transform(cover);
    for (final sx in [-1, 1]) {
      final hand = Rect.fromCenter(
        center: Offset(c.dx + r * 0.4 * sx, y),
        width: r * 0.62,
        height: r * 0.5,
      );
      canvas.drawOval(hand, paint);
      canvas.drawOval(hand, outline);
    }
  }

  @override
  bool shouldRepaint(covariant _CuteAvatarPainter old) =>
      old.blink != blink ||
      old.happy != happy ||
      old.cover != cover ||
      old.data != data;
}
