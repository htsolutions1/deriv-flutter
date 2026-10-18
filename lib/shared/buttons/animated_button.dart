import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A wrapper widget that adds entrance and press animations to any button.
///
/// On mount the child fades in and slides up via [flutter_animate].
/// While pressed, the child scales down to 95 % to give tactile feedback,
/// then springs back on release.
///
/// Wrap [PrimaryButton] or [SecondaryButton] with this widget on screens that
/// need animated call-to-action buttons (e.g. LoginScreen).
///
/// Requirements: 10.3, 11.3
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
  });

  /// The button widget to animate.
  final Widget child;

  /// Tap callback fired when the user lifts their finger (onTapUp).
  final VoidCallback? onTap;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
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
      // Transparent hit test so the inner button's InkWell still responds
      behavior: HitTestBehavior.translucent,
      child: widget.child
          // Entrance animation: fade in + slide up
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(
            begin: 0.2,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          )
          // Press animation: scale down when _isPressed
          .animate(target: _isPressed ? 1.0 : 0.0)
          .scaleXY(
            end: 0.95,
            duration: 80.ms,
            curve: Curves.easeIn,
          ),
    );
  }
}
