import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _redirectDelay = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _scheduleRedirect();
  }

  void _scheduleRedirect() {
    Future.delayed(_redirectDelay, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: Lottie.asset(
                'assets/lottie/splash_cooking.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF3D2B1F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.soup_kitchen,
                      size: 72,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Resepku',
                style:
                    AppTextStyles.heading1.copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('Masak mudah, hasil istimewa', style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}
