import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/string_formatter.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showLabel;

  static const int _starCount = 5;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (rating / _starCount).clamp(0.0, 1.0);
    final spacing = size * 0.15;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size,
          child: Stack(
            children: [
              _StarRow(
                  size: size,
                  spacing: spacing,
                  color: AppColors.disabledForeground),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction,
                  child: _StarRow(
                      size: size, spacing: spacing, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            StringFormatter.rating(rating),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  final double size;
  final double spacing;
  final Color color;

  const _StarRow(
      {required this.size, required this.spacing, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < RatingStars._starCount; i++)
          Padding(
            padding: EdgeInsets.only(
                right: i == RatingStars._starCount - 1 ? 0 : spacing),
            child: Icon(AppIcons.star, size: size, fill: 1, color: color),
          ),
      ],
    );
  }
}
