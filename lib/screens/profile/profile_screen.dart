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
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/cute_avatar.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/pressable.dart';
import '../../widgets/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: CuteAvatar(data: CuteAvatarData.presets[3], size: 72),
        title: const Text('Keluar dari akun?'),
        content: const Text(
            'Kamu bisa masuk lagi kapan saja untuk melihat resep favoritmu.'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final navigator = Navigator.of(context);
      await UserStore.instance.logout();
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    }
  }

  void _openAvatarPicker(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AvatarPickerSheet(),
    ).then((saved) {
      // Ditutup tanpa menekan Simpan → kembalikan avatar sebelumnya.
      if (saved != true) UserStore.instance.discardAvatarPreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gutter = Breakpoints.gutter(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          const CustomBottomNav(currentIndex: CustomBottomNav.indexProfile),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 32),
          child: ResponsiveCenter(
            maxWidth: 560,
            child: Column(
              children: [
                FadeSlideIn(
                  beginScale: 0.9,
                  child:
                      _ProfileAvatar(onEdit: () => _openAvatarPicker(context)),
                ),
                const SizedBox(height: 18),
                FadeSlideIn(
                  delay: AppMotion.staggerFor(1),
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: UserStore.instance.user,
                        builder: (context, _, __) => Column(
                          children: [
                            Text(
                              UserStore.instance.name,
                              style: AppTextStyles.heading1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              UserStore.instance.email,
                              style: AppTextStyles.subtitle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ValueListenableBuilder<int>(
                        valueListenable: UserStore.instance.avatarIndex,
                        builder: (context, _, __) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(AppIcons.sparkle,
                                  size: 14, color: AppColors.primary, fill: 1),
                              const SizedBox(width: 6),
                              Text(
                                'Karakter: ${UserStore.instance.avatar.name}',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.primaryLight),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: AppMotion.staggerFor(2),
                  child: const _StatsRow(),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  delay: AppMotion.staggerFor(3),
                  child: const _InfoCard(),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: AppMotion.staggerFor(4),
                  child: AppButton(
                    label: 'Keluar',
                    icon: AppIcons.logout,
                    variant: AppButtonVariant.danger,
                    onPressed: () => _confirmLogout(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final VoidCallback onEdit;

  const _ProfileAvatar({required this.onEdit});

  static const double _diameter = 140;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _diameter + 8,
      height: _diameter + 8,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: AppColors.glow(AppColors.primary, strength: 0.3),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: UserStore.instance.avatarIndex,
                builder: (context, _, __) => AnimatedSwitcher(
                  duration: AppMotion.medium,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale:
                        CurvedAnimation(parent: anim, curve: AppMotion.bounce),
                    child: child,
                  ),
                  child: CuteAvatar(
                    key: ValueKey(UserStore.instance.avatarIndex.value),
                    data: UserStore.instance.avatar,
                    size: _diameter - 14,
                    semanticLabel: 'Avatarmu, ketuk untuk menyapa',
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Tooltip(
              message: 'Ganti avatar',
              child: Pressable(
                onTap: onEdit,
                semanticLabel: 'Ganti avatar',
                borderRadius: BorderRadius.circular(24),
                hoverScale: 1.1,
                pressedScale: 0.88,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 3),
                  ),
                  child: const Icon(AppIcons.edit,
                      size: 20, color: Colors.white, fill: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final store = RecipeStore.instance;

    return ValueListenableBuilder<List<RecipeModel>>(
      valueListenable: store.recipes,
      builder: (context, recipes, _) => ValueListenableBuilder<Set<String>>(
        valueListenable: store.favoriteIds,
        builder: (context, favs, _) {
          final userId = UserStore.instance.user.value?.id;
          final mine = recipes.where((r) => r.uploader.id == userId).length;
          final stats = [
            (AppIcons.receipt, '$mine', 'Resep Saya'),
            (AppIcons.favorite, '${favs.length}', 'Favorit'),
            (AppIcons.fire, '${recipes.length}', 'Resep Total'),
          ];
          return Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(stats[i].$1,
                            size: 22, color: AppColors.primary, fill: 1),
                        const SizedBox(height: 6),
                        TweenAnimationBuilder<double>(
                          tween: Tween(end: double.parse(stats[i].$2)),
                          duration: AppMotion.slow,
                          curve: AppMotion.enter,
                          builder: (context, v, _) => Text(
                            v.round().toString(),
                            style:
                                AppTextStyles.heading1.copyWith(fontSize: 22),
                          ),
                        ),
                        Text(stats[i].$3, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: ValueListenableBuilder(
        valueListenable: UserStore.instance.user,
        builder: (context, user, _) => Column(
          children: [
            _InfoRow(
              icon: AppIcons.call,
              label: 'Nomor Telepon',
              value: user?.phone,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _InfoRow(
              icon: AppIcons.locationOn,
              label: 'Alamat',
              value: user?.address,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _InfoRow(
              icon: AppIcons.cake,
              label: 'Tanggal Lahir',
              value: user?.birthDate == null
                  ? null
                  : StringFormatter.date(user!.birthDate!),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  /// Kosong/null berarti pengguna belum mengisi data ini.
  final String? value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackbar.show(context, '$label disalin', type: AppSnackbarType.success);
  }

  @override
  Widget build(BuildContext context) {
    final text = value?.trim() ?? '';
    final filled = text.isNotEmpty;

    return Tooltip(
      message: filled ? 'Ketuk untuk menyalin' : '$label belum diisi',
      child: Pressable(
        onTap: filled ? () => _copy(context, text) : null,
        semanticLabel:
            filled ? '$label: $text. Ketuk untuk menyalin' : '$label belum diisi',
        hoverScale: 1.0,
        pressedScale: 0.98,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      filled ? text : 'Belum diisi',
                      style: filled
                          ? AppTextStyles.valueBold
                          : AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPickerSheet extends StatefulWidget {
  const _AvatarPickerSheet();

  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  final store = UserStore.instance;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await store.saveAvatar();
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackbar.show(context, e.message, type: AppSnackbarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ValueListenableBuilder<int>(
          valueListenable: store.avatarIndex,
          builder: (context, selected, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Karakter', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              const Text('Avatarmu akan tampil di Beranda & Profil.',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: CuteAvatarData.presets.length,
                itemBuilder: (context, i) {
                  final data = CuteAvatarData.presets[i];
                  final isSelected = i == selected;
                  return FadeSlideIn(
                    delay: AppMotion.staggerFor(i),
                    beginScale: 0.8,
                    beginOffset: Offset.zero,
                    child: Pressable(
                      onTap: () => store.avatarIndex.value = i,
                      selected: isSelected,
                      semanticLabel: data.name,
                      hoverScale: 1.05,
                      child: AnimatedContainer(
                        duration: AppMotion.medium,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryPale
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: FittedBox(
                                child: CuteAvatar(
                                  data: data,
                                  size: 72,
                                  happy: isSelected,
                                  interactive: false,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Simpan',
                icon: AppIcons.check,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
