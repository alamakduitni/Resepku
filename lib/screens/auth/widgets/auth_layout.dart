import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/cute_avatar.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/responsive.dart';

/// Kerangka halaman Masuk/Daftar: maskot + gelembung sapaan di atas form.
/// Di layar lebar, maskot pindah ke panel kiri.
class AuthLayout extends StatelessWidget {
  final CuteAvatarData mascot;
  final bool coverEyes;
  final String bubbleText;
  final String title;
  final String subtitle;
  final Widget form;
  final Widget? leading;

  const AuthLayout({
    super.key,
    required this.mascot,
    required this.bubbleText,
    required this.title,
    required this.subtitle,
    required this.form,
    this.coverEyes = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.isWide(context);

    final header = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: wide ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CuteAvatar(
              data: mascot,
              size: wide ? 180 : 92,
              coverEyes: coverEyes,
            ),
            const SizedBox(width: 12),
            Flexible(child: _SpeechBubble(text: bubbleText)),
          ],
        ),
      ],
    );

    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) leading!,
        if (!wide) ...[
          FadeSlideIn(child: header),
          const SizedBox(height: 28),
        ],
        FadeSlideIn(
          delay: AppMotion.staggerFor(1),
          child: Text(title, style: AppTextStyles.display),
        ),
        const SizedBox(height: 8),
        FadeSlideIn(
          delay: AppMotion.staggerFor(2),
          child: Text(subtitle, style: AppTextStyles.subtitle),
        ),
        const SizedBox(height: 28),
        FadeSlideIn(delay: AppMotion.staggerFor(3), child: form),
      ],
    );

    final scrollForm = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: formColumn,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: RadialGradient(
                          colors: [
                            mascot.background.withValues(alpha: 0.28),
                            AppColors.surface,
                          ],
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: FadeSlideIn(beginScale: 0.9, child: header),
                    ),
                  ),
                  Expanded(child: scrollForm),
                ],
              )
            : scrollForm,
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;

  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.medium,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SizeTransition(
            sizeFactor: anim,
            axis: Axis.horizontal,
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ),
        child: Text(
          text,
          key: ValueKey(text),
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
