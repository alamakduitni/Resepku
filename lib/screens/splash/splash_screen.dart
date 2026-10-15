import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/stores/user_store.dart';
import '../../routes/app_routes.dart';
import '../../widgets/fade_slide_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _redirectDelay = Duration(seconds: 5);

  // Cek token tersimpan bersamaan dengan animasi splash.
  final Future<bool> _session = UserStore.instance.restoreSession();

  // Controller ini sekaligus menjadi progress bar & penghitung waktu
  // redirect, jadi tidak ada Future yang menggantung saat layar ditutup.
  late final AnimationController _progress =
      AnimationController(vsync: this, duration: _redirectDelay)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) _redirect();
        })
        ..forward();

  /// Sudah login → langsung ke Beranda; belum → onboarding.
  Future<void> _redirect() async {
    final loggedIn = await _session.catchError((_) => false);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
        loggedIn ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final lottieSize = (size.shortestSide * 0.7).clamp(200.0, 320.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Cahaya hangat di belakang ilustrasi.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 0.9,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.16),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeSlideIn(
                  beginScale: 0.85,
                  beginOffset: Offset.zero,
                  duration: const Duration(milliseconds: 700),
                  child: SizedBox(
                    width: lottieSize,
                    height: lottieSize,
                    child: Lottie.asset(
                      'assets/lottie/splash_cooking.json',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPale,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            AppIcons.restaurantMenu,
                            size: 72,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: ShaderMask(
                    shaderCallback: (rect) =>
                        AppColors.primaryGradient.createShader(rect),
                    child: Text(
                      'Resepku',
                      style: AppTextStyles.display
                          .copyWith(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const FadeSlideIn(
                  delay: Duration(milliseconds: 500),
                  child: Text('Masak mudah, hasil istimewa',
                      style: AppTextStyles.subtitle),
                ),
                const SizedBox(height: 32),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 700),
                  child: SizedBox(
                    width: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedBuilder(
                        animation: _progress,
                        builder: (context, _) => LinearProgressIndicator(
                          value: Curves.easeInOut.transform(_progress.value),
                          minHeight: 5,
                          backgroundColor: AppColors.surfaceElevated,
                          color: AppColors.primary,
                          semanticsLabel: 'Memuat aplikasi',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
