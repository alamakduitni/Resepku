import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/category_model.dart';
import '../../data/models/recipe_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'widgets/carousel_banner.dart';
import 'widgets/category_list.dart';
import 'widgets/recipe_card.dart';

class _HomeData {
  final List<RecipeModel> recipes;
  final List<CategoryModel> categories;

  const _HomeData({required this.recipes, required this.categories});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<_HomeData> _dataFuture;
  bool _isGridView = true;

  static const String _currentUserName = 'Sari';

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    final recipesRaw =
        await rootBundle.loadString('lib/data/dummy/dummy_recipes.json');
    final categoriesRaw =
        await rootBundle.loadString('lib/data/dummy/dummy_categories.json');

    final recipesJson = json.decode(recipesRaw) as List;
    final categoriesJson = json.decode(categoriesRaw) as List;

    return _HomeData(
      recipes: recipesJson
          .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: categoriesJson
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  void _openDetail(RecipeModel recipe) {
    Navigator.of(context).pushNamed(AppRoutes.detail, arguments: recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          const CustomBottomNav(currentIndex: CustomBottomNav.indexHome),
      body: SafeArea(
        child: FutureBuilder<_HomeData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text('Gagal memuat data resep',
                    style: AppTextStyles.bodyMedium),
              );
            }

            final data = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                const _GreetingRow(userName: _currentUserName),
                const SizedBox(height: 18),
                const CarouselBanner(),
                const SizedBox(height: 22),
                CategoryList(categories: data.categories),
                const SizedBox(height: 26),
                _TrendingHeader(
                  isGridView: _isGridView,
                  onChanged: (value) => setState(() => _isGridView = value),
                ),
                const SizedBox(height: 14),
                _isGridView
                    ? _RecipeGrid(
                        recipes: data.recipes, onTapRecipe: _openDetail)
                    : _RecipeListView(
                        recipes: data.recipes, onTapRecipe: _openDetail),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GreetingRow extends StatelessWidget {
  final String userName;

  const _GreetingRow({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Halo, $userName 👋', style: AppTextStyles.heading2),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const Icon(AppIcons.notifications,
              size: 20, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _TrendingHeader extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool> onChanged;

  const _TrendingHeader({required this.isGridView, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Sedang Tren', style: AppTextStyles.heading2),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _ToggleButton(
                icon: AppIcons.gridView,
                isActive: isGridView,
                onTap: () => onChanged(true),
              ),
              _ToggleButton(
                icon: AppIcons.viewList,
                isActive: !isGridView,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton(
      {required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  final List<RecipeModel> recipes;
  final ValueChanged<RecipeModel> onTapRecipe;

  const _RecipeGrid({required this.recipes, required this.onTapRecipe});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          recipe: recipe,
          layout: RecipeCardLayout.grid,
          onTap: () => onTapRecipe(recipe),
        );
      },
    );
  }
}

class _RecipeListView extends StatelessWidget {
  final List<RecipeModel> recipes;
  final ValueChanged<RecipeModel> onTapRecipe;

  const _RecipeListView({required this.recipes, required this.onTapRecipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final recipe in recipes) ...[
          RecipeCard(
            recipe: recipe,
            layout: RecipeCardLayout.list,
            onTap: () => onTapRecipe(recipe),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
