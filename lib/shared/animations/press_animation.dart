import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps [child] with a press-scale animation.
///
/// On tap down the child scales to 95% over 80 ms; on tap up or cancel it
/// springs back to full size. [onTap] fires on tap up.
class PressAnimation extends StatefulWidget {
  const PressAnimation({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressAnimation> createState() => _PressAnimationState();
}

class _PressAnimationState extends State<PressAnimation> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: widget.child
          .animate(target: _isPressed ? 1.0 : 0.0)
          .scaleXY(end: 0.95, duration: 80.ms, curve: Curves.easeIn),
    );
  }
}
