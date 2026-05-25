import 'package:flutter/material.dart';

class AnimatedEntry extends StatelessWidget {
  const AnimatedEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 18),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final rawProgress =
            (value * (420 + delay.inMilliseconds) - delay.inMilliseconds) / 420;
        final progress = rawProgress.clamp(0.0, 1.0);

        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1 - progress),
              offset.dy * (1 - progress),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
