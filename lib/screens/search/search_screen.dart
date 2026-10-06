import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/recipe_model.dart';
import '../../data/stores/recipe_store.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/cute_avatar.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/responsive.dart';
import '../home/widgets/recipe_card.dart';
import 'widgets/category_chip_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const List<_CategoryItem> _foodCategories = [
    _CategoryItem(
        label: 'Olahan Nasi',
        icon: AppIcons.ramenDining,
        color: AppColors.butter),
    _CategoryItem(
        label: 'Cemilan', icon: AppIcons.cookie, color: AppColors.peach),
    _CategoryItem(
        label: 'Olahan Ayam',
        icon: AppIcons.lunchDining,
        color: AppColors.blush),
    _CategoryItem(
        label: 'Olahan Ikan', icon: AppIcons.setMeal, color: AppColors.sky),
  ];

  // Semua minuman ada di kategori "Minuman" pada data resep.
  static const List<_CategoryItem> _drinkCategories = [
    _CategoryItem(
        label: 'Jus',
        icon: AppIcons.localDrink,
        color: AppColors.mint,
        target: 'Minuman'),
    _CategoryItem(
        label: 'Kopi',
        icon: AppIcons.coffee,
        color: AppColors.peach,
        target: 'Minuman'),
    _CategoryItem(
        label: 'Teh',
        icon: AppIcons.emojiFoodBeverage,
        color: AppColors.lilac,
        target: 'Minuman'),
  ];

  final Future<void> _loadFuture = RecipeStore.instance.ensureLoaded();

  void _openCategory(_CategoryItem item) {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.home,
      arguments: item.target ?? item.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gutter = Breakpoints.gutter(MediaQuery.sizeOf(context).width);
    var i = 0;
    Duration next() => AppMotion.staggerFor(i++);
    const foodStart = 3;
    final drinkStart = foodStart + _foodCategories.length + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          const CustomBottomNav(currentIndex: CustomBottomNav.indexSearch),
      body: SafeArea(
        bottom: false,
        child: ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 32),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideIn(
                      delay: next(),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cari Resep',
                                    style: AppTextStyles.display
                                        .copyWith(fontSize: 28)),
                                const SizedBox(height: 6),
                                const Text(
                                  'Temukan resep makanan & minuman favoritmu',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          CuteAvatar(data: CuteAvatarData.presets[2], size: 64),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                        delay: next(), child: _buildDisabledSearchBar()),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delay: next(),
                      child: const Text('Kategori Makanan',
                          style: AppTextStyles.heading2),
                    ),
                    const SizedBox(height: 14),
                    _buildCategoryGrid(_foodCategories, foodStart),
                    const SizedBox(height: 26),
                    FadeSlideIn(
                      delay: next(),
                      child: const Text('Kategori Minuman',
                          style: AppTextStyles.heading2),
                    ),
                    const SizedBox(height: 14),
                    _buildCategoryGrid(_drinkCategories, drinkStart),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delay: next(),
                      child: const Row(
                        children: [
                          Icon(AppIcons.bolt,
                              color: AppColors.primary, fill: 1, size: 22),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text('Siap Kurang dari 20 Menit',
                                style: AppTextStyles.heading2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              FutureBuilder<void>(
                future: _loadFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      snapshot.hasError) {
                    return const SizedBox(height: 120);
                  }
                  return ValueListenableBuilder<List<RecipeModel>>(
                    valueListenable: RecipeStore.instance.recipes,
                    builder: (context, recipes, _) {
                      final quick = recipes
                          .where((r) => r.cookingTimeMinutes <= 20)
                          .toList()
                        ..sort((a, b) => a.cookingTimeMinutes
                            .compareTo(b.cookingTimeMinutes));
                      return _QuickRecipes(recipes: quick, gutter: gutter);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledSearchBar() {
    // Search bar sengaja dinonaktifkan sesuai keputusan brief.
    return _DisabledTapArea(
      onTap: () => AppSnackbar.showComingSoon(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.disabledBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            const Icon(AppIcons.search, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Cari resep favoritmu...',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textMuted)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.block,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('Segera hadir',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<_CategoryItem> categories, int startIndex) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisExtent: 104 * MediaQuery.textScalerOf(context).scale(1),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final c = categories[index];
        return FadeSlideIn(
          delay: AppMotion.staggerFor(startIndex + index),
          beginScale: 0.92,
          child: CategoryChipCard(
            label: c.label,
            icon: c.icon,
            accent: c.color,
            onTap: () => _openCategory(c),
          ),
        );
      },
    );
  }
}

/// Area non-aktif yang tetap memberi umpan balik saat diketuk.
class _DisabledTapArea extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _DisabledTapArea({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: false,
      label: 'Pencarian belum tersedia',
      child: GestureDetector(onTap: onTap, child: child),
    );
  }
}

class _QuickRecipes extends StatelessWidget {
  final List<RecipeModel> recipes;
  final double gutter;

  const _QuickRecipes({required this.recipes, required this.gutter});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.textScalerOf(context).scale(1);
    return SizedBox(
      height: 190 + 80 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: gutter),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return SizedBox(
            width: 190,
            child: FadeSlideIn(
              delay: AppMotion.staggerFor(index + 4),
              beginOffset: const Offset(0.1, 0),
              child: RecipeCard(
                recipe: recipe,
                heroTag: RecipeCard.heroTagFor(recipe),
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.detail, arguments: recipe),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;
  final Color color;

  /// Nama kategori di data resep, bila berbeda dari label.
  final String? target;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
    this.target,
  });
}
