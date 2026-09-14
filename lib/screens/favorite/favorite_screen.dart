import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/recipe_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../home/widgets/recipe_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  static const List<String> _favoriteRecipeIds = [
    'recipe_001',
    'recipe_005',
    'recipe_002'
  ];

  Future<List<RecipeModel>> _loadFavorites() async {
    final raw =
        await rootBundle.loadString('lib/data/dummy/dummy_recipes.json');
    final allRecipes = (json.decode(raw) as List)
        .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return _favoriteRecipeIds
        .map((id) => allRecipes.firstWhere((r) => r.id == id))
        .toList();
  }

  void _openDetail(BuildContext context, RecipeModel recipe) {
    Navigator.of(context).pushNamed(AppRoutes.detail, arguments: recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          const CustomBottomNav(currentIndex: CustomBottomNav.indexFavorite),
      body: SafeArea(
        child: FutureBuilder<List<RecipeModel>>(
          future: _loadFavorites(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text('Gagal memuat resep favorit',
                    style: AppTextStyles.bodyMedium),
              );
            }

            final favorites = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resep Favorit', style: AppTextStyles.heading1),
                  const SizedBox(height: 4),
                  Text('${favorites.length} resep tersimpan',
                      style: AppTextStyles.subtitle),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.66,
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final recipe = favorites[index];
                      return RecipeCard(
                        recipe: recipe,
                        isFavorited: true,
                        onTap: () => _openDetail(context, recipe),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
