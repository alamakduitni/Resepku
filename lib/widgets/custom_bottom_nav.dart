import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_text_styles.dart';
import '../routes/app_routes.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  static const int indexHome = 0;
  static const int indexSearch = 1;
  static const int indexAdd = 2;
  static const int indexFavorite = 3;
  static const int indexProfile = 4;

  void _onItemTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case indexHome:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case indexSearch:
        Navigator.of(context).pushReplacementNamed(AppRoutes.search);
        break;
      case indexFavorite:
        Navigator.of(context).pushReplacementNamed(AppRoutes.favorite);
        break;
      case indexProfile:
        Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
        break;
      case indexAdd:
        Navigator.of(context).pushNamed(AppRoutes.addRecipe);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: AppIcons.home,
                label: 'Beranda',
                isActive: currentIndex == indexHome,
                onTap: () => _onItemTap(context, indexHome),
              ),
              _NavItem(
                icon: AppIcons.search,
                label: 'Cari',
                isActive: currentIndex == indexSearch,
                onTap: () => _onItemTap(context, indexSearch),
              ),
              _AddButton(onTap: () => _onItemTap(context, indexAdd)),
              _NavItem(
                icon: AppIcons.favoriteBorder,
                label: 'Favorit',
                isActive: currentIndex == indexFavorite,
                onTap: () => _onItemTap(context, indexFavorite),
              ),
              _NavItem(
                icon: AppIcons.person,
                label: 'Profil',
                isActive: currentIndex == indexProfile,
                onTap: () => _onItemTap(context, indexProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: isActive
                  ? AppTextStyles.navLabelActive
                  : AppTextStyles.navLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -14),
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(AppIcons.add,
              color: AppColors.textOnPrimary, size: 28),
        ),
      ),
    );
  }
}
