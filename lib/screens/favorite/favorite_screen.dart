import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/recipe_model.dart';
import '../../data/stores/recipe_store.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/cute_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/responsive.dart';
import '../home/widgets/recipe_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final RecipeStore _store = RecipeStore.instance;
  late Future<void> _loadFuture = _store.ensureLoaded();

  void _openDetail(RecipeModel recipe) {
    Navigator.of(context).pushNamed(AppRoutes.detail, arguments: recipe);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = Breakpoints.gutter(width);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          const CustomBottomNav(currentIndex: CustomBottomNav.indexFavorite),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError) {
              return EmptyState(
                avatar: CuteAvatarData.presets[4],
                title: 'Gagal memuat resep favorit',
                message: 'Coba muat ulang halaman ini.',
                actionLabel: 'Coba Lagi',
                onAction: () =>
                    setState(() => _loadFuture = _store.ensureLoaded()),
              );
            }

            return ValueListenableBuilder<Set<String>>(
              valueListenable: _store.favoriteIds,
              builder: (context, _, __) {
                final favorites = _store.favorites;

                return ResponsiveCenter(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 32),
                    children: [
                      FadeSlideIn(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Resep Favorit',
                                      style: AppTextStyles.display
                                          .copyWith(fontSize: 28)),
                                  const SizedBox(height: 4),
                                  AnimatedSwitcher(
                                    duration: AppMotion.fast,
                                    child: Text(
                                      '${favorites.length} resep tersimpan',
                                      key: ValueKey(favorites.length),
                                      style: AppTextStyles.subtitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CuteAvatar(
                              data: CuteAvatarData.presets[1],
                              size: 56,
                              happy: favorites.isNotEmpty,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (favorites.isNotEmpty)
                        Text(
                          'Ketuk ikon hati untuk menghapus dari favorit.',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: AppMotion.medium,
                        child: favorites.isEmpty
                            ? EmptyState(
                                key: const ValueKey('empty'),
                                avatar: CuteAvatarData.presets[3],
                                title: 'Belum ada favorit',
                                message:
                                    'Simpan resep yang kamu suka dengan menekan ikon hati, nanti muncul di sini.',
                                actionLabel: 'Jelajahi Resep',
                                actionIcon: AppIcons.restaurantMenu,
                                onAction: () => Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.home),
                              )
                            : _FavoriteGrid(
                                key: const ValueKey('grid'),
                                favorites: favorites,
                                onTap: _openDetail,
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FavoriteGrid extends StatelessWidget {
  final List<RecipeModel> favorites;
  final ValueChanged<RecipeModel> onTap;

  const _FavoriteGrid(
      {super.key, required this.favorites, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.textScalerOf(context).scale(1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisExtent: 190 + 80 * s,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final recipe = favorites[index];
        return FadeSlideIn(
          key: ValueKey(recipe.id),
          delay: AppMotion.staggerFor(index),
          child: RecipeCard(
            recipe: recipe,
            heroTag: RecipeCard.heroTagFor(recipe),
            onTap: () => onTap(recipe),
          ),
        );
      },
    );
  }
}
