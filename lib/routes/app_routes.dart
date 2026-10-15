import 'package:flutter/material.dart';
import '../core/constants/app_motion.dart';
import '../screens/add_recipe/add_recipe_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/detail/recipe_detail_screen.dart';
import '../screens/favorite/favorite_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/splash/splash_screen.dart';

enum _Transition { fade, slideUp, slideRight }

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String search = '/search';
  static const String favorite = '/favorite';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String addRecipe = '/add-recipe';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(const SplashScreen(), settings, _Transition.fade);
      case onboarding:
        return _page(const OnboardingScreen(), settings, _Transition.fade);
      case login:
        return _page(const LoginScreen(), settings, _Transition.fade);
      case register:
        return _page(const RegisterScreen(), settings, _Transition.slideRight);
      // Tab utama: crossfade agar terasa seperti berpindah tab, bukan
      // masuk lebih dalam.
      case home:
        return _page(const HomeScreen(), settings, _Transition.fade);
      case search:
        return _page(const SearchScreen(), settings, _Transition.fade);
      case favorite:
        return _page(const FavoriteScreen(), settings, _Transition.fade);
      case profile:
        return _page(const ProfileScreen(), settings, _Transition.fade);
      case editProfile:
        return _page(
            const EditProfileScreen(), settings, _Transition.slideRight);
      case detail:
        return _page(
            const RecipeDetailScreen(), settings, _Transition.slideRight);
      case addRecipe:
        return _page(const AddRecipeScreen(), settings, _Transition.slideUp);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body:
                Center(child: Text('Route "${settings.name}" belum tersedia')),
          ),
          settings: settings,
        );
    }
  }

  static PageRouteBuilder<dynamic> _page(
    Widget screen,
    RouteSettings settings,
    _Transition transition,
  ) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: AppMotion.page,
      reverseTransitionDuration: AppMotion.pageReverse,
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (context, animation, secondary, child) {
        if (AppMotion.reduced(context)) return child;

        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.emphasized,
          reverseCurve: AppMotion.exit,
        );
        final fade = FadeTransition(opacity: curved, child: child);

        switch (transition) {
          case _Transition.fade:
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween(begin: 0.985, end: 1.0).animate(curved),
                child: child,
              ),
            );
          case _Transition.slideUp:
            return SlideTransition(
              position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
                  .animate(curved),
              child: fade,
            );
          case _Transition.slideRight:
            return SlideTransition(
              position: Tween(begin: const Offset(0.12, 0), end: Offset.zero)
                  .animate(curved),
              child: fade,
            );
        }
      },
    );
  }
}
