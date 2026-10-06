import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_motion.dart';

/// Pembungkus interaktif serbaguna: memberi efek membesar saat di-hover
/// (web/desktop), mengecil saat ditekan, getaran halus, kursor tangan,
/// cincin fokus keyboard, dan semantics tombol untuk pembaca layar.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final double hoverScale;
  final BorderRadius borderRadius;

  /// Jika diisi, kartu memancarkan bayangan berwarna saat di-hover.
  final Color? hoverGlowColor;
  final String? semanticLabel;
  final bool haptic;
  final bool? selected;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.hoverScale = 1.02,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.hoverGlowColor,
    this.semanticLabel,
    this.haptic = true,
    this.selected,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!_enabled) return;
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reduced(context);
    final scale = !_enabled || reduce
        ? 1.0
        : _pressed
            ? widget.pressedScale
            : _hovered
                ? widget.hoverScale
                : 1.0;
    final showGlow = widget.hoverGlowColor != null && _hovered && _enabled;

    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor:
            _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handleTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _enabled ? _handleTap : null,
          onLongPress: widget.onLongPress,
          child: AnimatedScale(
            scale: scale,
            duration: _pressed ? AppMotion.press : AppMotion.medium,
            curve: _pressed ? Curves.easeOut : AppMotion.bounce,
            child: AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.enter,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                boxShadow: showGlow
                    ? AppColors.glow(widget.hoverGlowColor!, strength: 0.28)
                    : const [],
              ),
              foregroundDecoration: _focused
                  ? BoxDecoration(
                      borderRadius: widget.borderRadius,
                      border:
                          Border.all(color: AppColors.primaryLight, width: 2),
                    )
                  : null,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
