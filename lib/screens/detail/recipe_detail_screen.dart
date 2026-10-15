import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/string_formatter.dart';
import '../../data/api/api_client.dart';
import '../../data/models/recipe_model.dart';
import '../../data/stores/recipe_store.dart';
import '../../data/stores/user_store.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/cute_avatar.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/pressable.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/responsive.dart';
import '../home/widgets/recipe_card.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final ScrollController _scroll = ScrollController();
  final Set<int> _checkedIngredients = {};
  final Set<int> _doneSteps = {};
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final collapsed = _scroll.hasClients && _scroll.offset > 220;
      if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toggle(Set<int> set, int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!set.remove(index)) set.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments as RecipeModel?;

    if (arg == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Data resep tidak ditemukan',
              style: AppTextStyles.bodyMedium),
        ),
      );
    }

    // Ambil versi terbaru dari store agar rating baru langsung tampil.
    return ValueListenableBuilder<List<RecipeModel>>(
      valueListenable: RecipeStore.instance.recipes,
      builder: (context, _, __) =>
          _buildRecipe(context, RecipeStore.instance.byId(arg.id) ?? arg),
    );
  }

  Widget _buildRecipe(BuildContext context, RecipeModel recipe) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= Breakpoints.medium;
    final gutter = Breakpoints.gutter(size.width);
    final allDone =
        recipe.steps.isNotEmpty && _doneSteps.length == recipe.steps.length;

    final ingredients = _Section(
      title: 'Bahan-Bahan',
      icon: AppIcons.basket,
      progress: '${_checkedIngredients.length}/${recipe.ingredients.length}',
      hint: 'Ketuk bahan yang sudah siap',
      child: _IngredientsCard(
        ingredients: recipe.ingredients,
        checked: _checkedIngredients,
        onToggle: (i) => _toggle(_checkedIngredients, i),
      ),
    );

    final steps = _Section(
      title: 'Langkah-Langkah',
      icon: AppIcons.listNumbered,
      progress: '${_doneSteps.length}/${recipe.steps.length}',
      hint: 'Tandai langkah yang sudah selesai',
      child: _StepsTimeline(
        steps: recipe.steps,
        done: _doneSteps,
        onToggle: (i) => _toggle(_doneSteps, i),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: (size.height * 0.42).clamp(260.0, 420.0),
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leadingWidth: 64,
            leading: Center(
              child: _RoundIconButton(
                icon: AppIcons.back,
                tooltip: 'Kembali',
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            title: AnimatedOpacity(
              opacity: _collapsed ? 1 : 0,
              duration: AppMotion.fast,
              child: Text(recipe.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FavoriteButton(recipeId: recipe.id, size: 42),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: RecipeCard.heroTagFor(recipe),
                    child: RecipeImage(path: recipe.image, iconSize: 48),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x8C000000),
                          Colors.transparent,
                          Colors.transparent,
                          AppColors.background,
                        ],
                        stops: [0, 0.3, 0.6, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ResponsiveCenter(
              maxWidth: 1000,
              child: Padding(
                padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideIn(child: _Header(recipe: recipe)),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      delay: AppMotion.staggerFor(2),
                      child: _StatsRow(recipe: recipe),
                    ),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delay: AppMotion.staggerFor(4),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 4, child: ingredients),
                                const SizedBox(width: 24),
                                Expanded(flex: 6, child: steps),
                              ],
                            )
                          : Column(
                              children: [
                                ingredients,
                                const SizedBox(height: 28),
                                steps,
                              ],
                            ),
                    ),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delay: AppMotion.staggerFor(5),
                      child: _RatingCard(recipe: recipe),
                    ),
                    AnimatedSwitcher(
                      duration: AppMotion.slow,
                      switchInCurve: AppMotion.bounce,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: allDone
                          ? const Padding(
                              key: ValueKey('done'),
                              padding: EdgeInsets.only(top: 24),
                              child: _CelebrationCard(),
                            )
                          : const SizedBox.shrink(key: ValueKey('progress')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final RecipeModel recipe;

  const _Header({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(recipe.category,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primaryLight)),
        ),
        const SizedBox(height: 10),
        Text(recipe.name, style: AppTextStyles.display.copyWith(fontSize: 28)),
        const SizedBox(height: 14),
        Row(
          children: [
            UploaderAvatar(
              name: recipe.uploader.name,
              image: recipe.uploader.profileImage,
              radius: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resep oleh', style: AppTextStyles.caption),
                  Text(
                    recipe.uploader.name,
                    style: AppTextStyles.valueBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (recipe.rating == 0)
              const Text('Belum ada rating', style: AppTextStyles.caption)
            else ...[
              RatingStars(rating: recipe.rating, size: 16),
              if (recipe.ratingCount > 0) ...[
                const SizedBox(width: 4),
                Text('(${recipe.ratingCount})', style: AppTextStyles.caption),
              ],
            ],
          ],
        ),
      ],
    );
  }
}

/// Kartu untuk memberi rating 1-5. Bintang langsung terisi saat diketuk,
/// lalu dikembalikan jika server gagal menyimpan.
class _RatingCard extends StatefulWidget {
  final RecipeModel recipe;

  const _RatingCard({required this.recipe});

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  static const _labels = ['Kurang', 'Lumayan', 'Enak', 'Enak banget', 'Juara!'];

  int? _pending;

  Future<void> _rate(int score) async {
    if (_pending != null || score == widget.recipe.myRating) return;
    HapticFeedback.selectionClick();
    setState(() => _pending = score);
    try {
      await RecipeStore.instance.rateRecipe(widget.recipe.id, score);
      if (!mounted) return;
      AppSnackbar.show(context, 'Terima kasih atas ratingnya!',
          type: AppSnackbarType.success);
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, e.message, type: AppSnackbarType.error);
    } finally {
      if (mounted) setState(() => _pending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final isOwn = recipe.uploader.id.isNotEmpty &&
        recipe.uploader.id == UserStore.instance.user.value?.id;
    final shown = _pending ?? recipe.myRating ?? 0;

    final String subtitle;
    if (isOwn) {
      subtitle = 'Ini resepmu. Rating diberikan oleh pengguna lain.';
    } else if (_pending != null) {
      subtitle = 'Menyimpan rating...';
    } else if (recipe.myRating != null) {
      subtitle = 'Rating kamu: ${_labels[recipe.myRating! - 1]}. '
          'Ketuk bintang untuk mengubah.';
    } else {
      subtitle = 'Sudah mencoba resep ini? Ketuk bintang untuk menilai.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.star,
                  color: AppColors.primary, size: 22, fill: 1),
              const SizedBox(width: 8),
              Expanded(
                child: Text(isOwn ? 'Rating Resep' : 'Beri Rating',
                    style: AppTextStyles.heading2),
              ),
              if (recipe.ratingCount > 0)
                Text(
                  '${StringFormatter.rating(recipe.rating)} '
                  'dari ${recipe.ratingCount} penilaian',
                  style: AppTextStyles.caption,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodyMedium),
          if (!isOwn) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  Tooltip(
                    message: _labels[i - 1],
                    excludeFromSemantics: true,
                    child: Pressable(
                      onTap: _pending == null ? () => _rate(i) : null,
                      selected: i <= shown,
                      semanticLabel: 'Beri $i bintang, ${_labels[i - 1]}',
                      hoverScale: 1.15,
                      pressedScale: 0.85,
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox.square(
                        dimension: 48,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: i <= shown ? 1 : 0),
                          duration: AppMotion.medium,
                          builder: (context, fill, _) => Icon(
                            AppIcons.star,
                            size: 34,
                            fill: fill,
                            color: Color.lerp(AppColors.disabledForeground,
                                AppColors.primary, fill),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (shown > 0)
                  Expanded(
                    child: Text(
                      _labels[shown - 1],
                      style: AppTextStyles.valueBold
                          .copyWith(color: AppColors.primaryLight),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final RecipeModel recipe;

  const _StatsRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        AppIcons.timer,
        StringFormatter.cookingTime(recipe.cookingTimeMinutes),
        'Waktu'
      ),
      (AppIcons.basket, '${recipe.ingredients.length} item', 'Bahan'),
      (AppIcons.listNumbered, '${recipe.steps.length} langkah', 'Langkah'),
    ];

    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryMuted,
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(stats[i].$1, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(stats[i].$2,
                      style: AppTextStyles.valueBold,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(stats[i].$3, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final String progress;
  final String hint;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.progress,
    required this.hint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: AppTextStyles.heading2)),
            AnimatedSwitcher(
              duration: AppMotion.fast,
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Container(
                key: ValueKey(progress),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(progress,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textPrimary)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(hint,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        semanticLabel: tooltip,
        borderRadius: BorderRadius.circular(24),
        hoverScale: 1.08,
        pressedScale: 0.9,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, size: 22, color: Colors.white),
        ),
      ),
    );
  }
}

class _IngredientsCard extends StatelessWidget {
  final List<Ingredient> ingredients;
  final Set<int> checked;
  final ValueChanged<int> onToggle;

  const _IngredientsCard({
    required this.ingredients,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < ingredients.length; i++) ...[
            _CheckRow(
              checked: checked.contains(i),
              onTap: () => onToggle(i),
              label: ingredients[i].name,
              trailing: ingredients[i].amount,
            ),
            if (i != ingredients.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  final String label;
  final String trailing;

  const _CheckRow({
    required this.checked,
    required this.onTap,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      child: Pressable(
        onTap: onTap,
        semanticLabel: '$label, $trailing',
        hoverScale: 1.0,
        pressedScale: 0.98,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _CheckDot(checked: checked),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: AppMotion.fast,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 15,
                    color:
                        checked ? AppColors.textMuted : AppColors.textPrimary,
                    decoration: checked ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted,
                  ),
                  child: Text(label),
                ),
              ),
              Text(
                trailing,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: checked ? AppColors.textMuted : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckDot extends StatelessWidget {
  final bool checked;

  const _CheckDot({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.bounce,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: checked ? AppColors.primaryGradient : null,
        border: Border.all(
          color: checked ? Colors.transparent : AppColors.borderStrong,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: checked ? 1 : 0,
        duration: AppMotion.medium,
        curve: AppMotion.bounce,
        child: const Icon(AppIcons.check,
            size: 16, color: Colors.white, weight: 700),
      ),
    );
  }
}

class _StepsTimeline extends StatelessWidget {
  final List<String> steps;
  final Set<int> done;
  final ValueChanged<int> onToggle;

  const _StepsTimeline({
    required this.steps,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: AppMotion.medium,
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: done.contains(i)
                              ? AppColors.primaryGradient
                              : null,
                          color: done.contains(i)
                              ? null
                              : AppColors.surfaceElevated,
                          border: Border.all(
                            color: done.contains(i)
                                ? Colors.transparent
                                : AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: AppMotion.fast,
                          transitionBuilder: (c, a) =>
                              ScaleTransition(scale: a, child: c),
                          child: done.contains(i)
                              ? const Icon(AppIcons.check,
                                  key: ValueKey('c'),
                                  size: 18,
                                  color: Colors.white,
                                  weight: 700)
                              : Text(
                                  '${i + 1}',
                                  key: const ValueKey('n'),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      if (i != steps.length - 1)
                        Expanded(
                          child: AnimatedContainer(
                            duration: AppMotion.medium,
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: done.contains(i)
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 12),
                    child: Semantics(
                      checked: done.contains(i),
                      child: Pressable(
                        onTap: () => onToggle(i),
                        semanticLabel: 'Langkah ${i + 1}',
                        hoverScale: 1.01,
                        pressedScale: 0.98,
                        hoverGlowColor: AppColors.primary,
                        child: AnimatedContainer(
                          duration: AppMotion.medium,
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: done.contains(i)
                                ? AppColors.primaryPale
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: done.contains(i)
                                  ? AppColors.primary.withValues(alpha: 0.4)
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            steps[i],
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontSize: 15,
                              color: done.contains(i)
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.25),
            AppColors.surface,
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CuteAvatar(data: CuteAvatarData.presets[0], size: 72, happy: true),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hore, masakan selesai!', style: AppTextStyles.heading2),
                SizedBox(height: 4),
                Text('Selamat menikmati hasil masakanmu.',
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
