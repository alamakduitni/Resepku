import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_motion.dart';
import '../core/constants/app_text_styles.dart';
import '../routes/app_routes.dart';
import 'pressable.dart';

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
      decoration: BoxDecoration(
        color: AppColors.surface,
        border:
            const Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SizedBox(
              height: 68,
              child: Row(
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
                  Expanded(
                    child:
                        _AddButton(onTap: () => _onItemTap(context, indexAdd)),
                  ),
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
    return Expanded(
      child: Pressable(
        onTap: onTap,
        selected: isActive,
        semanticLabel: label,
        pressedScale: 0.9,
        hoverScale: 1.06,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.emphasized,
              width: isActive ? 56 : 40,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryMuted : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: isActive ? 1 : 0),
                duration: AppMotion.medium,
                builder: (context, t, _) => Icon(
                  icon,
                  size: 24,
                  fill: t,
                  color:
                      Color.lerp(AppColors.textSecondary, AppColors.primary, t),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: AppMotion.fast,
              style: isActive
                  ? AppTextStyles.navLabelActive
                  : AppTextStyles.navLabel,
              child: Text(label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  double _turns = 0;

  void _handleTap() {
    setState(() => _turns += 0.25);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -14),
        child: Tooltip(
          message: 'Tambah resep',
          child: Pressable(
            onTap: _handleTap,
            semanticLabel: 'Tambah resep',
            pressedScale: 0.88,
            hoverScale: 1.08,
            borderRadius: BorderRadius.circular(30),
            hoverGlowColor: AppColors.primary,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 4),
                boxShadow: AppColors.glow(AppColors.primary, strength: 0.45),
              ),
              child: AnimatedRotation(
                turns: _turns,
                duration: AppMotion.slow,
                curve: AppMotion.bounce,
                child: const Icon(AppIcons.add,
                    color: AppColors.textOnPrimary, size: 28, weight: 600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
