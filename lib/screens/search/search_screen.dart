import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'widgets/category_chip_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const List<_CategoryItem> _foodCategories = [
    _CategoryItem(label: 'Cemilan', icon: AppIcons.cookie),
    _CategoryItem(label: 'Olahan Ayam', icon: AppIcons.lunchDining),
    _CategoryItem(label: 'Olahan Ikan', icon: AppIcons.setMeal),
  ];

  static const List<_CategoryItem> _drinkCategories = [
    _CategoryItem(label: 'Jus', icon: AppIcons.localDrink),
    _CategoryItem(label: 'Kopi', icon: AppIcons.coffee),
    _CategoryItem(label: 'Teh', icon: AppIcons.emojiFoodBeverage),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          const CustomBottomNav(currentIndex: CustomBottomNav.indexSearch),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cari Resep',
                  style: AppTextStyles.heading1.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                'Temukan resep makanan & minuman favoritmu',
                style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
              ),
              const SizedBox(height: 20),
              _buildDisabledSearchBar(),
              const SizedBox(height: 10),
              _buildDisabledBadge(),
              const SizedBox(height: 28),
              Text('Kategori Makanan', style: AppTextStyles.heading2),
              const SizedBox(height: 14),
              _buildCategoryRow(_foodCategories),
              const SizedBox(height: 24),
              Text('Kategori Minuman', style: AppTextStyles.heading2),
              const SizedBox(height: 14),
              _buildCategoryRow(_drinkCategories),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.disabledBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: TextField(
        enabled: false, // sengaja dinonaktifkan sesuai keputusan brief
        style:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        decoration: InputDecoration(
          hintText: 'Cari resep favoritmu...',
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          prefixIcon: const Icon(AppIcons.search, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDisabledBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.block, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text('Search bar non-aktif',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(List<_CategoryItem> categories) {
    return Row(
      children: categories
          .map(
            (c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CategoryChipCard(label: c.label, icon: c.icon),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;

  const _CategoryItem({required this.label, required this.icon});
}
