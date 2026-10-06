import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_motion.dart';
import '../data/api/api_client.dart';
import '../data/stores/recipe_store.dart';
import 'app_snackbar.dart';

/// Tombol hati yang tersinkron dengan [RecipeStore]: meletup kecil
/// dengan percikan partikel saat resep difavoritkan.
class FavoriteButton extends StatefulWidget {
  final String recipeId;
  final double size;
  final Color background;

  const FavoriteButton({
    super.key,
    required this.recipeId,
    this.size = 36,
    this.background = const Color(0xCC15100C),
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  static final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.35), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.9, end: 1), weight: 40),
  ]);

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final store = RecipeStore.instance;
    final willBeFavorite = !store.isFavorite(widget.recipeId);
    HapticFeedback.lightImpact();
    if (willBeFavorite && !AppMotion.reduced(context)) {
      _pop.forward(from: 0);
    }
    try {
      await store.toggleFavorite(widget.recipeId);
    } on ApiException catch (e) {
      if (mounted) {
        AppSnackbar.show(context, e.message, type: AppSnackbarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: RecipeStore.instance.favoriteIds,
      builder: (context, ids, _) {
        final isFav = ids.contains(widget.recipeId);
        return Semantics(
          button: true,
          toggled: isFav,
          label: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
          child: Tooltip(
            message: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggle,
                // Area sentuh minimal 44px walau ikon kecil.
                child: SizedBox.square(
                  dimension: math.max(44, widget.size),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pop,
                      builder: (context, child) => CustomPaint(
                        painter: _BurstPainter(progress: _pop.value),
                        child: Transform.scale(
                          scale: _scale.transform(_pop.value),
                          child: child,
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          color: isFav
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : widget.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFav
                                ? AppColors.primary.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: isFav ? 1 : 0),
                          duration: AppMotion.medium,
                          builder: (context, fill, _) => Icon(
                            AppIcons.favorite,
                            size: widget.size * 0.5,
                            fill: fill,
                            color: Color.lerp(
                                AppColors.textPrimary, AppColors.primary, fill),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double progress;

  _BurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;
    final center = size.center(Offset.zero);
    final base = size.width / 2;
    final t = Curves.easeOut.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0);

    canvas.drawCircle(
      center,
      base * (0.8 + t * 0.7),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * (1 - t)
        ..color = AppColors.primary.withValues(alpha: opacity),
    );

    const colors = [AppColors.primary, AppColors.butter, AppColors.blush];
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final d = base * (0.9 + t * 0.9);
      canvas.drawCircle(
        center + Offset(math.cos(angle) * d, math.sin(angle) * d),
        2.6 * (1 - t) + 0.6,
        Paint()..color = colors[i % 3].withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.progress != progress;
}
