import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../widgets/pressable.dart';

/// Chip kategori yang bisa dipilih untuk menyaring resep.
class CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsets padding;

  const CategoryList({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        clipBehavior: Clip.none,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category.name == selected;

          return Pressable(
            onTap: () => onSelected(category.name),
            selected: isActive,
            semanticLabel: 'Kategori ${category.name}',
            borderRadius: BorderRadius.circular(24),
            hoverScale: 1.04,
            child: AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.emphasized,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.primaryGradient : null,
                color: isActive ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isActive ? Colors.transparent : AppColors.border,
                ),
                boxShadow: isActive
                    ? AppColors.glow(AppColors.primary, strength: 0.25)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.15 : 1,
                    duration: AppMotion.medium,
                    curve: AppMotion.bounce,
                    child: Icon(
                      AppIcons.categoryIcon(category.icon),
                      size: 18,
                      fill: isActive ? 1 : 0,
                      color: isActive
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      color: isActive
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
