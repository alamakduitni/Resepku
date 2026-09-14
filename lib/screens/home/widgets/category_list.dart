import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/category_model.dart';

class CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoryList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isFeatured = index == 0;
          final category = categories[index];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isFeatured ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: isFeatured ? null : Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.categoryIcon(category.icon),
                  size: 18,
                  color: isFeatured
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: AppTextStyles.button.copyWith(
                    color: isFeatured
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
