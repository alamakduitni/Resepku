import 'package:flutter/material.dart';

import '../core/constants/app_motion.dart';

/// Animasi masuk: konten muncul memudar sambil bergeser naik.
/// Delay dibuat lewat [Interval] (bukan Timer) supaya tidak ada timer
/// menggantung saat widget dibuang.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final double beginScale;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.slow,
    this.beginOffset = const Offset(0, 0.08),
    this.beginScale = 1,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    final start = total.inMicroseconds == 0
        ? 0.0
        : widget.delay.inMicroseconds / total.inMicroseconds;
    _controller = AnimationController(vsync: this, duration: total);
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: AppMotion.enter),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position:
            Tween(begin: widget.beginOffset, end: Offset.zero).animate(_curve),
        child: widget.beginScale == 1
            ? widget.child
            : ScaleTransition(
                scale:
                    Tween(begin: widget.beginScale, end: 1.0).animate(_curve),
                child: widget.child,
              ),
      ),
    );
  }
}
