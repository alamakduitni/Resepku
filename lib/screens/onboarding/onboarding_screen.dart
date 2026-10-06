import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cute_avatar.dart';
import '../../widgets/pressable.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  int _currentPage = 0;

  static final List<_OnboardingData> _pages = [
    _OnboardingData(
      avatar: CuteAvatarData.presets[0],
      icons: const [AppIcons.manageSearch, AppIcons.ramenDining, AppIcons.cake],
      title: 'Temukan Ribuan\nResep',
      description: 'Jelajahi beragam resep masakan dari berbagai kategori, '
          'mulai dari cemilan hingga hidangan utama.',
    ),
    _OnboardingData(
      avatar: CuteAvatarData.presets[2],
      icons: const [AppIcons.listNumbered, AppIcons.timer, AppIcons.restaurant],
      title: 'Masak Mudah\nStep-by-Step',
      description: 'Ikuti panduan memasak yang jelas dan terurut, '
          'cocok untuk pemula sekalipun.',
    ),
    _OnboardingData(
      avatar: CuteAvatarData.presets[1],
      icons: const [AppIcons.favorite, AppIcons.sparkle, AppIcons.cookie],
      title: 'Simpan Resep\nFavoritmu',
      description: 'Tandai resep kesukaanmu dan akses kembali '
          'kapan saja dengan mudah.',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _orbit.stop();
    } else if (!_orbit.isAnimating) {
      _orbit.repeat();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _orbit.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
    );
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final circleSize =
                    (math.min(height * 0.36, constraints.maxWidth * 0.72))
                        .clamp(180.0, 320.0);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 12, 0),
                      child: Row(
                        children: [
                          Text('Resepku',
                              style: AppTextStyles.heading3
                                  .copyWith(color: AppColors.primary)),
                          const Spacer(),
                          AnimatedOpacity(
                            opacity: isLast ? 0 : 1,
                            duration: AppMotion.fast,
                            child: IgnorePointer(
                              ignoring: isLast,
                              child: TextButton(
                                onPressed: _skip,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                ),
                                child: const Text('Lewati'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemBuilder: (context, index) => _OnboardingPage(
                          data: _pages[index],
                          index: index,
                          controller: _pageController,
                          orbit: _orbit,
                          circleSize: circleSize,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_pages.length, (index) {
                              final isActive = index == _currentPage;
                              return Pressable(
                                onTap: () => _goToPage(index),
                                semanticLabel: 'Halaman ${index + 1}',
                                selected: isActive,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 16),
                                  child: AnimatedContainer(
                                    duration: AppMotion.medium,
                                    curve: AppMotion.emphasized,
                                    width: isActive ? 32 : 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      gradient: isActive
                                          ? AppColors.primaryGradient
                                          : null,
                                      color: isActive
                                          ? null
                                          : AppColors.borderStrong,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: isLast ? 'Mulai Memasak' : 'Selanjutnya',
                            icon: isLast
                                ? AppIcons.restaurantMenu
                                : AppIcons.arrowForward,
                            onPressed: _goToNextPage,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final int index;
  final PageController controller;
  final Animation<double> orbit;
  final double circleSize;

  const _OnboardingPage({
    required this.data,
    required this.index,
    required this.controller,
    required this.orbit,
    required this.circleSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double delta = 0;
        if (controller.hasClients && controller.position.haveDimensions) {
          delta = (controller.page ?? 0) - index;
        }
        final fade = (1 - delta.abs()).clamp(0.0, 1.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Parallax: ilustrasi bergerak lebih lambat dari teks.
              Transform.translate(
                offset: Offset(delta * 80, 0),
                child: Transform.scale(
                  scale: 0.85 + fade * 0.15,
                  child: _Illustration(
                    data: data,
                    orbit: orbit,
                    size: circleSize,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Opacity(
                opacity: fade,
                child: Transform.translate(
                  offset: Offset(delta * -40, 0),
                  child: Column(
                    children: [
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Illustration extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> orbit;
  final double size;

  const _Illustration({
    required this.data,
    required this.orbit,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = size * 0.2;

    return SizedBox.square(
      dimension: size + bubble,
      child: AnimatedBuilder(
        animation: orbit,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      data.avatar.background.withValues(alpha: 0.35),
                      AppColors.primaryPale,
                    ],
                  ),
                  border: Border.all(
                    color: data.avatar.background.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
              ),
              CuteAvatar(data: data.avatar, size: size * 0.62),
              for (var i = 0; i < data.icons.length; i++)
                _orbitBubble(i, bubble),
            ],
          );
        },
      ),
    );
  }

  Widget _orbitBubble(int i, double bubble) {
    final angle =
        orbit.value * 2 * math.pi + i * (2 * math.pi / 3) - math.pi / 2;
    final r = size / 2;
    return Transform.translate(
      offset: Offset(math.cos(angle) * r, math.sin(angle) * r),
      child: Container(
        width: bubble,
        height: bubble,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(data.icons[i],
            color: AppColors.primary, size: bubble * 0.46, fill: 1),
      ),
    );
  }
}

class _OnboardingData {
  final CuteAvatarData avatar;
  final List<IconData> icons;
  final String title;
  final String description;

  const _OnboardingData({
    required this.avatar,
    required this.icons,
    required this.title,
    required this.description,
  });
}
