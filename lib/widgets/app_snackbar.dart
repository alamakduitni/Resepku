import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_text_styles.dart';

enum AppSnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastCard(
        message: message,
        type: type,
        onDismissed: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted) entry.remove();
    });
  }

  static void showComingSoon(BuildContext context) {
    show(context, 'Fitur akan segera hadir', type: AppSnackbarType.info);
  }
}

class _ToastCard extends StatefulWidget {
  final String message;
  final AppSnackbarType type;
  final VoidCallback onDismissed;

  const _ToastCard({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  (Color, IconData) get _style {
    switch (widget.type) {
      case AppSnackbarType.success:
        return (AppColors.success, AppIcons.success);
      case AppSnackbarType.error:
        return (AppColors.error, AppIcons.error);
      case AppSnackbarType.warning:
        return (AppColors.warning, AppIcons.warning);
      case AppSnackbarType.info:
        return (AppColors.info, AppIcons.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _style;
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 12,
      right: 16,
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, -0.3),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(color: color, width: 4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
