import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps [child] with a staggered fade+slide entrance animation.
///
/// The delay is calculated as [baseDelay] × [index], where [index] is clamped
/// to a maximum of 6 so the total entrance sequence never exceeds 830 ms
/// (6 × 80 ms delay + 350 ms animation).
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = const Duration(milliseconds: 80),
  });

  final Widget child;
  final int index;
  final Duration baseDelay;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: baseDelay * index.clamp(0, 6))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}
