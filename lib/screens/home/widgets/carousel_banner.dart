import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/string_formatter.dart';
import '../../../data/models/recipe_model.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/recipe_image.dart';

class BannerItem {
  final RecipeModel recipe;
  final String caption;
  const BannerItem({required this.recipe, required this.caption});
}

class CarouselBanner extends StatefulWidget {
  final List<BannerItem> items;
  final ValueChanged<RecipeModel> onTap;
  final double height;

  const CarouselBanner({
    super.key,
    required this.items,
    required this.onTap,
    this.height = 180,
  });

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  PageController? _controller;
  double _viewport = 0;
  Timer? _timer;
  int _currentPage = 0;
  bool _reduced = false;

  static const _autoSlideInterval = Duration(seconds: 4);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = AppMotion.reduced(context);
    // Di layar lebar, kartu tetangga ikut terlihat sebagian.
    final width = MediaQuery.sizeOf(context).width;
    final viewport = width >= 900 ? 0.6 : (width >= 600 ? 0.75 : 0.9);
    if (viewport != _viewport) {
      _viewport = viewport;
      final old = _controller;
      _controller = PageController(
        viewportFraction: viewport,
        initialPage: _currentPage,
      );
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (_reduced || widget.items.length < 2) return;
    _timer = Timer.periodic(_autoSlideInterval, (_) {
      final controller = _controller;
      if (controller == null || !controller.hasClients) return;
      final next = (_currentPage + 1) % widget.items.length;
      controller.animateToPage(
        next,
        duration: AppMotion.slow,
        curve: AppMotion.emphasized,
      );
    });
  }

  void _pauseAutoSlide() => _timer?.cancel();

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;

    return MouseRegion(
      // Berhenti bergeser saat kursor berada di atas banner.
      onEnter: (_) => _pauseAutoSlide(),
      onExit: (_) => _startAutoSlide(),
      child: Column(
        children: [
          SizedBox(
            height: widget.height,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  _pauseAutoSlide();
                } else if (notification is ScrollEndNotification) {
                  _startAutoSlide();
                }
                return false;
              },
              child: PageView.builder(
                controller: controller,
                itemCount: widget.items.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      double delta = (index - _currentPage).toDouble();
                      if (controller.hasClients &&
                          controller.position.haveDimensions) {
                        delta = (controller.page ?? 0) - index;
                      }
                      final scale = (1 - delta.abs() * 0.08).clamp(0.9, 1.0);
                      return Transform.scale(
                        scale: scale,
                        child: _BannerSlide(
                          item: widget.items[index],
                          parallax: delta,
                          onTap: () => widget.onTap(widget.items[index].recipe),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: AppMotion.medium,
                curve: AppMotion.emphasized,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.primaryGradient : null,
                  color: isActive ? null : AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final BannerItem item;
  final double parallax;
  final VoidCallback onTap;

  const _BannerSlide({
    required this.item,
    required this.parallax,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = item.recipe;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Pressable(
        onTap: onTap,
        semanticLabel: '${item.caption}: ${recipe.name}',
        pressedScale: 0.98,
        hoverScale: 1.01,
        borderRadius: BorderRadius.circular(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gambar bergeser lebih lambat dari kartu → efek parallax.
              Transform.translate(
                offset: Offset(parallax * 40, 0),
                child: Transform.scale(
                  scale: 1.2,
                  child: RecipeImage(path: recipe.image, iconSize: 40),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xE6000000), Color(0x00000000)],
                    stops: [0, 0.75],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(AppIcons.fire,
                              size: 14, fill: 1, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(item.caption,
                              style: AppTextStyles.caption
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading1
                          .copyWith(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(AppIcons.schedule,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          StringFormatter.cookingTime(
                              recipe.cookingTimeMinutes),
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        const Icon(AppIcons.star,
                            size: 14, fill: 1, color: AppColors.star),
                        const SizedBox(width: 4),
                        Text(
                          StringFormatter.rating(recipe.rating),
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
