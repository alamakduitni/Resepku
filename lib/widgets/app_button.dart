import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_motion.dart';
import '../core/constants/app_text_styles.dart';
import 'pressable.dart';

enum AppButtonVariant { primary, outline, ghost, danger }

/// Tombol utama aplikasi: gradien, efek tekan/hover, dan status loading.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonVariant variant;
  final double height;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.height = 56,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final (Color fg, BoxDecoration deco) = switch (variant) {
      AppButtonVariant.primary => (
          AppColors.textOnPrimary,
          BoxDecoration(
            gradient: enabled ? AppColors.primaryGradient : null,
            color: enabled ? null : AppColors.primaryPale,
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? AppColors.glow(AppColors.primary, strength: 0.3)
                : null,
          ),
        ),
      AppButtonVariant.outline => (
          AppColors.primary,
          BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1.4),
          ),
        ),
      AppButtonVariant.ghost => (
          AppColors.textPrimary,
          BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
        ),
      AppButtonVariant.danger => (
          AppColors.error,
          BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
          ),
        ),
    };

    final content = AnimatedSwitcher(
      duration: AppMotion.fast,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: anim, child: child),
      ),
      child: loading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 20, color: enabled ? fg : AppColors.textMuted),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 16,
                      color: enabled ? fg : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
    );

    return Pressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      hoverScale: 1.015,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        height: height,
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        decoration: deco,
        child: content,
      ),
    );
  }
}
