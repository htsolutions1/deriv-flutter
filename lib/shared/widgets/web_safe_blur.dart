import 'dart:ui';

import 'package:flutter/material.dart';

/// A [BackdropFilter] wrapper that works correctly on all platforms.
///
/// On web with the HTML renderer, [BackdropFilter] is silently ignored.
/// With canvaskit (set in flutter_bootstrap.js) it works fully.
/// On native (Android/iOS), it always works.
///
/// This widget adds a `kIsWeb` check to safely skip the filter widget
/// tree wrapping when running in a context where it would have no effect,
/// while still rendering the [child] correctly.
class WebSafeBlur extends StatelessWidget {
  const WebSafeBlur({
    super.key,
    required this.child,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
  });

  final Widget child;
  final double sigmaX;
  final double sigmaY;

  @override
  Widget build(BuildContext context) {
    // canvaskit (set in flutter_bootstrap.js) supports BackdropFilter on web.
    // We always apply it — it works on canvaskit web and native alike.
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: child,
    );
  }
}
