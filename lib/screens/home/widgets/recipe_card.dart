import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/string_formatter.dart';
import '../../../data/models/recipe_model.dart';

enum RecipeCardLayout { grid, list }

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final RecipeCardLayout layout;
  final VoidCallback onTap;
  final bool isFavorited;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.layout = RecipeCardLayout.grid,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    return layout == RecipeCardLayout.grid ? _buildGrid() : _buildList();
  }

  Widget _buildGrid() {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _recipeImage(),
                  Positioned(
                      top: 8,
                      left: 8,
                      child: _CategoryBadge(text: recipe.category)),
                  Positioned(
                      top: 8,
                      right: 8,
                      child: _DisabledLoveIcon(isFavorited: isFavorited)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: AppTextStyles.heading3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(AppIcons.schedule,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        StringFormatter.cookingTime(recipe.cookingTimeMinutes),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _UploaderRow(
                      name: recipe.uploader.name,
                      avatar: recipe.uploader.profileImage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(width: 88, height: 88, child: _recipeImage()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBadge(text: recipe.category),
                  const SizedBox(height: 6),
                  Text(
                    recipe.name,
                    style: AppTextStyles.heading3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(AppIcons.schedule,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        StringFormatter.cookingTime(recipe.cookingTimeMinutes),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _UploaderRow(
                      name: recipe.uploader.name,
                      avatar: recipe.uploader.profileImage),
                ],
              ),
            ),
            _DisabledLoveIcon(isFavorited: isFavorited),
          ],
        ),
      ),
    );
  }

  Widget _recipeImage() {
    return Image.asset(
      recipe.image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.surfaceElevated,
        child: const Icon(Icons.restaurant,
            color: AppColors.disabledForeground, size: 28),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String text;

  const _CategoryBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.75),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _DisabledLoveIcon extends StatelessWidget {
  final bool isFavorited;

  const _DisabledLoveIcon({this.isFavorited = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(
        AppIcons.favoriteBorder,
        size: 16,
        fill: isFavorited ? 1 : 0,
        color: isFavorited ? AppColors.primary : AppColors.disabledForeground,
      ),
    );
  }
}

class _UploaderRow extends StatelessWidget {
  final String name;
  final String avatar;

  const _UploaderRow({required this.name, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 9,
          backgroundColor: AppColors.surfaceElevated,
          backgroundImage: AssetImage(avatar),
          onBackgroundImageError: (_, __) {},
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
