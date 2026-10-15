import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_motion.dart';
import '../core/constants/app_text_styles.dart';

/// Field input dengan label terlihat di atasnya, ikon yang menyala saat
/// fokus, tombol lihat/sembunyikan kata sandi, dan validasi inline.
class AppTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final bool requiredField;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool dense;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.requiredField = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.maxLines = 1,
    this.maxLength,
    this.onFocusChange,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.dense = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focused == _focusNode.hasFocus) return;
      setState(() => _focused = _focusNode.hasFocus);
      widget.onFocusChange?.call(_focused);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showLabel = widget.label.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          AnimatedDefaultTextStyle(
            duration: AppMotion.fast,
            style: AppTextStyles.heading3.copyWith(
              color: _focused ? AppColors.primaryLight : AppColors.textPrimary,
            ),
            child: Text.rich(
              TextSpan(
                text: widget.label,
                children: [
                  if (widget.requiredField)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.primary),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: widget.validator,
          obscureText: widget.isPassword && _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: 1,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          autovalidateMode: AutovalidateMode.onUnfocus,
          style: AppTextStyles.bodyLarge.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hintText,
            isDense: widget.dense,
            counterText: '',
            contentPadding: widget.dense
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 14)
                : null,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: 22),
            suffixIcon: widget.isPassword
                ? IconButton(
                    tooltip: _obscured
                        ? 'Tampilkan kata sandi'
                        : 'Sembunyikan kata sandi',
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: AnimatedSwitcher(
                      duration: AppMotion.fast,
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        _obscured
                            ? AppIcons.visibilityOff
                            : AppIcons.visibility,
                        key: ValueKey(_obscured),
                        size: 22,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
