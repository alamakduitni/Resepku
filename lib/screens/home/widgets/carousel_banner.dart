import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class _BannerItem {
  final String image;
  final String caption;
  const _BannerItem({required this.image, required this.caption});
}

class CarouselBanner extends StatefulWidget {
  const CarouselBanner({super.key});

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  static const _items = [
    _BannerItem(
      image: 'assets/images/recipes/nasi_goreng_spesial.jpg',
      caption: 'Resep Favorit Minggu Ini',
    ),
    _BannerItem(
      image: 'assets/images/recipes/ayam_bakar_kecap.jpg',
      caption: 'Trending: Ayam Bakar Kecap',
    ),
    _BannerItem(
      image: 'assets/images/recipes/ikan_bakar_bumbu_kuning.jpg',
      caption: 'Segar & Sehat Hari Ini',
    ),
  ];

  late final PageController _controller;
  Timer? _timer;
  int _currentPage = 0;

  static const _autoSlideInterval = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoSlideInterval, (_) {
      if (!_controller.hasClients) return;
      final next = (_currentPage + 1) % _items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  void _pauseAutoSlide() => _timer?.cancel();

  void _resumeAutoSlide() => _startAutoSlide();

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _pauseAutoSlide();
              } else if (notification is ScrollEndNotification) {
                _resumeAutoSlide();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: _items.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) =>
                  _BannerSlide(item: _items[index]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final _BannerItem item;

  const _BannerSlide({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              item.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surfaceElevated,
                child: const Icon(Icons.restaurant,
                    color: AppColors.disabledForeground, size: 40),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                  stops: [0, 0.6],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Text(
                item.caption,
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
