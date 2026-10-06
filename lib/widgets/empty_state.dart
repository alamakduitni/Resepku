import 'package:flutter/material.dart';

import '../core/constants/app_text_styles.dart';
import 'app_button.dart';
import 'cute_avatar.dart';
import 'fade_slide_in.dart';

/// Tampilan kosong yang ramah: avatar lucu + pesan + aksi lanjutan.
class EmptyState extends StatelessWidget {
  final CuteAvatarData avatar;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.avatar,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CuteAvatar(data: avatar, size: 112),
                const SizedBox(height: 20),
                Text(title,
                    style: AppTextStyles.heading2, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(message,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 24),
                  AppButton(
                    label: actionLabel!,
                    icon: actionIcon,
                    onPressed: onAction,
                    expand: false,
                    height: 50,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
