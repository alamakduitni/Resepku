import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/string_formatter.dart';
import '../../../data/models/recipe_model.dart';
import '../../../widgets/favorite_button.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/recipe_image.dart';

enum RecipeCardLayout { grid, list }

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final RecipeCardLayout layout;
  final VoidCallback onTap;

  /// Tag Hero untuk transisi gambar ke halaman detail. Null = tanpa Hero.
  final String? heroTag;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.layout = RecipeCardLayout.grid,
    this.heroTag,
  });

  static String heroTagFor(RecipeModel recipe) => 'recipe-image-${recipe.id}';

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Buka resep ${recipe.name}',
      hoverGlowColor: AppColors.primary,
      pressedScale: 0.97,
      borderRadius: BorderRadius.circular(20),
      child: layout == RecipeCardLayout.grid ? _buildGrid() : _buildList(),
    );
  }

  Widget _image({double iconSize = 32}) {
    final image = RecipeImage(path: recipe.image, iconSize: iconSize);
    return heroTag == null ? image : Hero(tag: heroTag!, child: image);
  }

  Widget _buildGrid() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _image(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [Color(0x99000000), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 52,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _CategoryBadge(text: recipe.category),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: FavoriteButton(recipeId: recipe.id, size: 34),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _RatingPill(rating: recipe.rating),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
                _TimeRow(minutes: recipe.cookingTimeMinutes),
                const SizedBox(height: 8),
                _UploaderRow(
                    name: recipe.uploader.name,
                    avatar: recipe.uploader.profileImage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: 96, height: 96, child: _image(iconSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                        child: _CategoryBadge(
                            text: recipe.category, subtle: true)),
                    const SizedBox(width: 8),
                    _RatingPill(rating: recipe.rating, subtle: true),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  recipe.name,
                  style: AppTextStyles.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _TimeRow(minutes: recipe.cookingTimeMinutes),
                const SizedBox(height: 6),
                _UploaderRow(
                    name: recipe.uploader.name,
                    avatar: recipe.uploader.profileImage),
              ],
            ),
          ),
          FavoriteButton(
            recipeId: recipe.id,
            size: 36,
            background: AppColors.surfaceElevated,
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String text;
  final bool subtle;

  const _CategoryBadge({required this.text, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: subtle
            ? AppColors.primaryMuted
            : AppColors.background.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: subtle ? AppColors.primaryLight : AppColors.textPrimary,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  final bool subtle;

  const _RatingPill({required this.rating, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: subtle
            ? AppColors.surfaceElevated
            : AppColors.background.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(rating == 0 ? AppIcons.sparkle : AppIcons.star,
              size: 13, fill: 1, color: AppColors.star),
          const SizedBox(width: 3),
          Text(
            // Resep baru belum punya penilaian.
            rating == 0 ? 'Baru' : StringFormatter.rating(rating),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final int minutes;

  const _TimeRow({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(AppIcons.schedule, size: 14, color: AppColors.primaryLight),
        const SizedBox(width: 4),
        Text(
          StringFormatter.cookingTime(minutes),
          style: AppTextStyles.caption,
        ),
      ],
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
        UploaderAvatar(name: name, image: avatar, radius: 9),
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
