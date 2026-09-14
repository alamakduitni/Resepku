import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/string_formatter.dart';
import '../../data/models/recipe_model.dart';
import '../../widgets/rating_stars.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipe = ModalRoute.of(context)?.settings.arguments as RecipeModel?;

    if (recipe == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Data resep tidak ditemukan',
              style: AppTextStyles.bodyMedium),
        ),
      );
    }

    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  recipe.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Icon(Icons.restaurant,
                        color: AppColors.disabledForeground, size: 48),
                  ),
                ),
                Positioned(
                  top: topInset + 12,
                  left: 16,
                  child: _RoundIconButton(
                    icon: AppIcons.back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: topInset + 12,
                  right: 16,
                  child: const _RoundIconButton(icon: AppIcons.favoriteBorder),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.name, style: AppTextStyles.heading1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.surfaceElevated,
                      backgroundImage: AssetImage(recipe.uploader.profileImage),
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recipe.uploader.name,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    RatingStars(rating: recipe.rating, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(AppIcons.schedule,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      StringFormatter.cookingTime(recipe.cookingTimeMinutes),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Bahan-Bahan', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                _IngredientsCard(ingredients: recipe.ingredients),
                const SizedBox(height: 24),
                Text('Langkah-Langkah', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                _StepsCard(steps: recipe.steps),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDisabled ? AppColors.disabledForeground : Colors.white,
        ),
      ),
    );
  }
}

class _IngredientsCard extends StatelessWidget {
  final List<Ingredient> ingredients;

  const _IngredientsCard({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < ingredients.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(ingredients[i].name,
                        style: AppTextStyles.bodyLarge),
                  ),
                  Text(
                    ingredients[i].amount,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (i != ingredients.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  final List<String> steps;

  const _StepsCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(steps[i], style: AppTextStyles.bodyLarge),
                ),
              ],
            ),
          ),
          if (i != steps.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
