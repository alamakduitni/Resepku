import 'package:flutter/material.dart';
import '../screens/add_recipe/add_recipe_placeholder_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/detail/recipe_detail_screen.dart';
import '../screens/favorite/favorite_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/splash/splash_screen.dart';

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
  static const String addRecipe = '/add-recipe';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
            builder: (_) => const SplashScreen(), settings: settings);
      case onboarding:
        return MaterialPageRoute(
            builder: (_) => const OnboardingScreen(), settings: settings);
      case login:
        return MaterialPageRoute(
            builder: (_) => const LoginScreen(), settings: settings);
      case register:
        return MaterialPageRoute(
            builder: (_) => const RegisterScreen(), settings: settings);
      case home:
        return MaterialPageRoute(
            builder: (_) => const HomeScreen(), settings: settings);
      case detail:
        return MaterialPageRoute(
            builder: (_) => const RecipeDetailScreen(), settings: settings);
      case search:
        return MaterialPageRoute(
            builder: (_) => const SearchScreen(), settings: settings);
      case favorite:
        return MaterialPageRoute(
            builder: (_) => const FavoriteScreen(), settings: settings);
      case profile:
        return MaterialPageRoute(
            builder: (_) => const ProfileScreen(), settings: settings);
      case addRecipe:
        return MaterialPageRoute(
          builder: (_) => const AddRecipePlaceholderScreen(),
          settings: settings,
        );
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
}
