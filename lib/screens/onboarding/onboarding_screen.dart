import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: AppIcons.manageSearch,
      title: 'Temukan Ribuan\nResep',
      description: 'Jelajahi beragam resep masakan dari\n'
          'berbagai kategori, mulai dari cemilan\n'
          'hingga hidangan utama.',
    ),
    _OnboardingData(
      icon: AppIcons.ramenDining,
      title: 'Masak Mudah Step-\nby-Step',
      description: 'Ikuti panduan memasak yang jelas dan\n'
          'terurut, cocok untuk pemula sekalipun.',
    ),
    _OnboardingData(
      icon: AppIcons.favoriteBorder,
      title: 'Simpan Resep\nFavoritmu',
      description: 'Tandai resep kesukaanmu dan akses\n'
          'kembali kapan saja dengan mudah.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final circleSize = (height * 0.29).clamp(220.0, 340.0);
            final titleSize = (width * 0.065).clamp(30.0, 42.0);
            final descriptionSize = (width * 0.032).clamp(17.0, 21.0);

            return Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 220,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: width * 0.07,
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.12,
                  left: 24,
                  right: 24,
                  bottom: height * 0.27,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];

                      return Column(
                        children: [
                          Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryPale,
                            ),
                            child: Icon(
                              page.icon,
                              size: circleSize * 0.35,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: height * 0.055),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.15,
                              letterSpacing: -0.8,
                            ),
                          ),
                          SizedBox(height: height * 0.018),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: descriptionSize,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 32,
                  right: 32,
                  bottom: height * 0.045,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          final isActive = index == _currentPage;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: isActive ? 40 : 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: height * 0.045),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _goToNextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? 'Mulai'
                                : 'Selanjutnya',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ========================================================================

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
