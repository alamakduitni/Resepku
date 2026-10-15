import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/api/api_client.dart';
import '../../data/models/recipe_model.dart';
import '../../data/stores/recipe_store.dart';
import '../../data/stores/user_store.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/cute_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/pressable.dart';
import '../../widgets/responsive.dart';
import 'widgets/carousel_banner.dart';
import 'widgets/category_list.dart';
import 'widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String allCategory = 'Semua';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeStore _store = RecipeStore.instance;
  late Future<void> _loadFuture;
  bool _isGridView = true;
  String _selectedCategory = HomeScreen.allCategory;
  bool _readArgs = false;

  @override
  void initState() {
    super.initState();
    _loadFuture = _store.ensureLoaded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_readArgs) return;
    _readArgs = true;
    // Kategori awal bisa dikirim dari halaman Cari.
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.isNotEmpty) _selectedCategory = arg;
  }

  void _retry() => setState(() => _loadFuture = _store.ensureLoaded());

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
        bottom: false,
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError) {
              return EmptyState(
                avatar: CuteAvatarData.presets[4],
                title: 'Gagal memuat data resep',
                message: snapshot.error is ApiException
                    ? (snapshot.error as ApiException).message
                    : 'Ada kendala saat membaca data. Coba muat ulang ya.',
                actionLabel: 'Coba Lagi',
                onAction: _retry,
              );
            }
            return ValueListenableBuilder<List<RecipeModel>>(
              valueListenable: _store.recipes,
              builder: (context, recipes, _) => _buildContent(recipes),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<RecipeModel> recipes) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = Breakpoints.gutter(width);
    final filtered = _selectedCategory == HomeScreen.allCategory
        ? recipes
        : recipes.where((r) => r.category == _selectedCategory).toList();

    final banners = <BannerItem>[
      for (final (id, caption) in _store.banners)
        if (_store.byId(id) case final recipe?)
          BannerItem(recipe: recipe, caption: caption),
    ];

    Widget padded(Widget child) => Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: child,
        );

    return ResponsiveCenter(
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        children: [
          padded(const FadeSlideIn(child: _GreetingRow())),
          const SizedBox(height: 18),
          padded(FadeSlideIn(
            delay: AppMotion.staggerFor(1),
            child: _SearchShortcut(
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.search),
            ),
          )),
          const SizedBox(height: 20),
          if (banners.isNotEmpty)
            FadeSlideIn(
              delay: AppMotion.staggerFor(2),
              child: CarouselBanner(
                items: banners,
                onTap: _openDetail,
                height: (width * 0.48).clamp(180.0, 280.0),
              ),
            ),
          const SizedBox(height: 22),
          padded(FadeSlideIn(
            delay: AppMotion.staggerFor(3),
            child: const Text('Kategori', style: AppTextStyles.heading2),
          )),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: AppMotion.staggerFor(3),
            beginOffset: const Offset(0.05, 0),
            child: CategoryList(
              categories: _store.categories,
              selected: _selectedCategory,
              padding: EdgeInsets.symmetric(horizontal: gutter),
              onSelected: (name) => setState(() => _selectedCategory = name),
            ),
          ),
          const SizedBox(height: 26),
          padded(_TrendingHeader(
            count: filtered.length,
            isGridView: _isGridView,
            onChanged: (value) => setState(() => _isGridView = value),
          )),
          const SizedBox(height: 14),
          padded(AnimatedSwitcher(
            duration: AppMotion.medium,
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [
                // Matikan Hero pada konten lama agar tag tidak bentrok.
                for (final p in previous) HeroMode(enabled: false, child: p),
                if (current != null) current,
              ],
            ),
            child: KeyedSubtree(
              key: ValueKey(
                  '$_isGridView-$_selectedCategory-${filtered.length}'),
              child: filtered.isEmpty
                  ? EmptyState(
                      avatar: CuteAvatarData.presets[3],
                      title: 'Belum ada resep di sini',
                      message:
                          'Kategori "$_selectedCategory" masih kosong. Yuk jadi yang pertama berbagi resep!',
                      actionLabel: 'Tambah Resep',
                      actionIcon: AppIcons.add,
                      onAction: () =>
                          Navigator.of(context).pushNamed(AppRoutes.addRecipe),
                    )
                  : _RecipeCollection(
                      recipes: filtered,
                      isGrid: _isGridView,
                      onTapRecipe: _openDetail,
                    ),
            ),
          )),
        ],
      ),
    );
  }
}

class _GreetingRow extends StatelessWidget {
  const _GreetingRow();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: UserStore.instance.avatarIndex,
          builder: (context, _, __) => Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: CuteAvatar(
              data: UserStore.instance.avatar,
              size: 50,
              semanticLabel: 'Avatarmu, ketuk untuk menyapa',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_greeting,', style: AppTextStyles.bodyMedium),
              ValueListenableBuilder(
                valueListenable: UserStore.instance.user,
                builder: (context, _, __) => Text(
                    'Halo, ${UserStore.instance.firstName} 👋',
                    style: AppTextStyles.heading2.copyWith(fontSize: 20)),
              ),
            ],
          ),
        ),
        const _BellButton(),
      ],
    );
  }
}

class _BellButton extends StatefulWidget {
  const _BellButton();

  @override
  State<_BellButton> createState() => _BellButtonState();
}

class _BellButtonState extends State<_BellButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wiggle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!AppMotion.reduced(context)) _wiggle.forward(from: 0);
    AppSnackbar.show(context, 'Belum ada notifikasi baru',
        type: AppSnackbarType.info);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Notifikasi',
      child: Pressable(
        onTap: _onTap,
        semanticLabel: 'Notifikasi',
        borderRadius: BorderRadius.circular(24),
        hoverScale: 1.08,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _wiggle,
                builder: (context, child) {
                  final t = _wiggle.value;
                  return Transform.rotate(
                    angle: math.sin(t * math.pi * 6) * 0.3 * (1 - t),
                    alignment: Alignment.topCenter,
                    child: child,
                  );
                },
                child: const Icon(AppIcons.notifications,
                    size: 22, color: AppColors.textPrimary),
              ),
              Positioned(
                top: 12,
                right: 13,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchShortcut extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchShortcut({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Buka halaman cari resep',
      hoverScale: 1.01,
      pressedScale: 0.98,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(AppIcons.search, color: AppColors.textMuted, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Mau masak apa hari ini?',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textMuted)),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(AppIcons.sparkle,
                  size: 18, color: AppColors.primary, fill: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingHeader extends StatelessWidget {
  final int count;
  final bool isGridView;
  final ValueChanged<bool> onChanged;

  const _TrendingHeader({
    required this.count,
    required this.isGridView,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sedang Tren', style: AppTextStyles.heading2),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Text(
                  '$count resep',
                  key: ValueKey(count),
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              // Pil oranye yang meluncur di belakang ikon aktif.
              AnimatedAlign(
                duration: AppMotion.medium,
                curve: AppMotion.emphasized,
                alignment:
                    isGridView ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToggleButton(
                    icon: AppIcons.gridView,
                    label: 'Tampilan grid',
                    isActive: isGridView,
                    onTap: () => onChanged(true),
                  ),
                  _ToggleButton(
                    icon: AppIcons.viewList,
                    label: 'Tampilan daftar',
                    isActive: !isGridView,
                    onTap: () => onChanged(false),
                  ),
                ],
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
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Pressable(
        onTap: onTap,
        selected: isActive,
        semanticLabel: label,
        borderRadius: BorderRadius.circular(10),
        pressedScale: 0.88,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            fill: isActive ? 1 : 0,
            color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RecipeCollection extends StatelessWidget {
  final List<RecipeModel> recipes;
  final bool isGrid;
  final ValueChanged<RecipeModel> onTapRecipe;

  const _RecipeCollection({
    required this.recipes,
    required this.isGrid,
    required this.onTapRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.textScalerOf(context).scale(1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: recipes.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        // Grid: 2 kolom di HP, bertambah otomatis di tablet/desktop.
        // Daftar: 1 kolom di HP, 2 kolom di layar lebar.
        maxCrossAxisExtent: isGrid ? 250 : 560,
        mainAxisExtent: isGrid ? 190 + 80 * s : 24 + 116 * s,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return FadeSlideIn(
          delay: AppMotion.staggerFor(index),
          child: RecipeCard(
            recipe: recipe,
            layout: isGrid ? RecipeCardLayout.grid : RecipeCardLayout.list,
            heroTag: RecipeCard.heroTagFor(recipe),
            onTap: () => onTapRecipe(recipe),
          ),
        );
      },
    );
  }
}
